resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#()-_=+:?"
}

data "aws_vpc" "tsre_vpc" {
  tags = {
    Name = "${var.event_shortname}-vpc"
  }
}

data "aws_subnets" "tsre_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.tsre_vpc.id]
  }
}

data "aws_subnet" "tsre_subnet" {
  for_each = toset(data.aws_subnets.tsre_subnets.ids)

  id = each.value
}

data "aws_security_group" "tsre_sg" {
  tags = {
    Name = "${var.event_shortname}-sg"
  }
}

## create an instance for each team
resource "aws_instance" "swagstore" {
  for_each = var.teams

  ami           = "ami-06ca3ca175f37dd66"
  instance_type = "t3.2xlarge" # Don't change it for a smaller SKU, it needs 6 cpu at least to start
  key_name      = "tsre-emea"
  subnet_id     = data.aws_subnet.tsre_subnet[data.aws_subnets.tsre_subnets.ids[0]].id
  vpc_security_group_ids = [data.aws_security_group.tsre_sg.id]

  root_block_device {
    volume_size = 30
  }

  user_data = <<-EOL
#!/bin/bash -xe

yum update -y
yum install docker -y
service docker start 
systemctl enable docker
usermod -a -G docker ec2-user

# Set hostname
TEAM_NAME=${each.value.name}
hostnamectl set-hostname ${each.value.name}

# Send to Cthulhu that you are ready
IP=$(ip --brief address show | grep ens5 | awk '{print $3}' | sed 's/...$//')
HOST=$(cat /etc/hostname)
EXTERNAL=$(curl ifconfig.me)
curl -X POST -H "Content-Type: application/json" -d "{\"name\": \"$HOST\", \"internal\":\"$IP\", \"external\":\"$EXTERNAL\", \"password\": \"${random_password.password.result}\", \"apikey\": \"${each.value.dd_api_key}\", \"appkey\": \"${each.value.dd_app_key}\"}" ${var.cthulhu_url}/register


# Set message of the day for participants
rm /etc/motd
cat <<EOT > /etc/motd
Welcome to the ${var.event_description}
MMMMMMMMMMMMMMMMMMMMMMMMMMMMWk’...oXMMMMMMMMMMMMMM
MMMWN0xoxKWMMMMMMWNXNWWMMMWXd.  ’..;kWMMMMMMMMMMMM
MNOc..   ‘o0NWNKkl’‘,;:clc:'    :c. .lXMMMMMMMMMMM
Kl.      ...‘;’.              ..,xl.  lNMMMMMMMMMM
;        ’,                    .:ONO:.‘OMMMMMMMMMM
.        .c,                    .cKWWK0NMMMMMMMMMM
:         co.                  .ccl0MMMMMMMMMMMMMM
Nd.      .xO’     ,ldo’        ,KWkxNMMMMMMMMMMMMM
MWKd;..’:kXx.    cNMMWx.        ’c:cKMMMMMMMMMMMMM
MMMMXdcodo;.     ;kOxo,             :KWMMMMMMMMMMM
MMMMX;                               ‘kWMMMMMMMMMM
MMMMWo                         ‘:lodc..OMMMMMMMMMM
MMMMM0’                       .dNMMNd. oWMMMMMMMMM
MMMMMNd’                        ‘cl;. .xMMMMMMMMMM
MMMMMMWXd,       .‘,.            ,’  .lXMWNXK0kxON
MMMMMMMMWXl        .:ll;’... .‘cxOd:::cc:,’..   ‘O
MMMMMMMMMM0,      ,lcokkkkkkOOOd;.            ...k
MMMMMMMMMMK,      lO;.  ...‘’'.              .xo.d
MMMMMMMMMXc       ;k;                .‘.    .xWk.l
MMMMMMMXx’        .kc               .xNKd;..xWM0':
MMMMWKo’  ...     .dd.             ,OWMMMWKKWMMK;,
MMWKl.    ..,::.   lx.      ‘:,...:KMMMMMMMMMMMNc.
MWk’         .:xc. ;k,    .lXWWXK0NMMMMMMMMMMMMWo.
MX:            ,Oo..xc  .:xNMMMMMMMMMMMMMMMWNXKOc.
MNo.            c0kkXd.’OWWMMMMMWNXK0kxollc::::ccl
MMNO:.          .OMMMk.:OOkxdolccc::cclodxO0KXNWMM
MMMMWk.         ’OMMMKc;ccllodxO0KXNWMMMMMMMMMMMMM
MMMMMWO,       .dNMMMWWNWWMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMWKl.   .,kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
As a reminder, here’s the most important information:
1. You have to solve a number of challenges. These challenges are waiting for you at ${var.ctf_url}
2. This machine is running a local minikube kubernetes cluster hosting an application. There’s no need to change the cluster for any challenges.
3. To see the application, check out /home/ec2-user/microservices-demo, it contains all the files used for the deployment.
4. You can restart the deployment using: /home/ec2-user/microservices-demo/update.sh (Please note that the stack is already running)
5. The machine and application is monitored using Datadog. For your Datadog credentials, see below.
Important URLs
==============
CTF (Capture the Flag) access:
${var.ctf_url}

Datadog access: 
https://app.datadoghq.com 
You have already received an invitation to join the org.

Should you need API access to datadog, you can use these credentials: 
https://api.datadoghq.com
DD_API_KEY=${each.value.dd_api_key}
DD_APP_KEY=${each.value.dd_app_key}
These are also already set as environment variables for you. 
If you ever need to see this message again, just enter "creds".

Should you have any issues, please raise your hand. One of our TAs will then come to you to help you out. 
Have fun!
EOT

# set passwd for the ec2-user
echo "${random_password.password.result}" | passwd --stdin ec2-user

## now run stuff as ec2-user: 
cat <<EOI > /tmp/initinstance.sh
#!/bin/bash

## Run as ec2-user when EC2 instance as been booted up and pre-config

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin

# Install minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin

# Install git and conntrack and nginx (for reverse proxy)
sudo yum install -y git conntrack nginx

# Install Skaffold
sudo curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
sudo install skaffold /usr/local/bin/
rm -f skaffold

# install helm
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Git clone project
git clone --single-branch --branch ${var.microservices_version} https://github.com/DataDog/tsre-microservices.git

# Renaming tsre-microservice repo 
mv tsre-microservices microservices-demo-multiarch 

# Getting in the repo
cd microservices-demo-multiarch

# Add Cthulhu url into paymentservice yaml
sed -i "s#cthulhu#${var.cthulhu_url}#" /home/ec2-user/microservices-demo-multiarch/kubernetes-manifests/paymentservice.yaml #Commenting this out as we will pull from Docker Anonymously


# Install agent
helm repo add datadog https://helm.datadoghq.com
helm repo add stable https://charts.helm.sh/stable 
helm repo update


# Add POD Agent pod address
cd
echo "alias datadog-status='kubectl exec \\$AGENT_POD -- agent status'" >> .bashrc

# add Flag to ENV
echo "export DD_CTF='ZELDA_TEARSOFTHESRE'" >> .bashrc
echo "export DD_API_KEY='${each.value.dd_api_key}'" >>  .bashrc
echo "export DD_APP_KEY='${each.value.dd_app_key}'" >>  .bashrc
echo "export CTHULHU_URL='${var.cthulhu_url}'" >>.bashrc
echo "alias creds='cat /etc/motd'" >> .bashrc
source .bashrc

# Set API and APP
echo "using \$DD_API_KEY and \$DD_APP_KEY"

if [ -x "$(command -v jq)" ]; then
  # check to see if RUM app exists
  export RUMNAME=swagstore
  echo "Creating RUM app"

  # create RUM app
  export DDRUMINFO=\$(curl -sX POST "https://api.datadoghq.com/api/v1/rum/projects" -H "Content-Type: application/json" -H "DD-API-KEY: \$DD_API_KEY" -H "DD-APPLICATION-KEY: \$DD_APP_KEY" -d '{"name": "'\$RUMNAME'","type": "browser"}')  
  echo "RUM app Created"
  
  echo \$DDRUMINFO
  export DD_APPLICATION_ID=\$(echo \$DDRUMINFO|jq -r .application_id)
  export DD_CLIENT_TOKEN=\$(echo \$DDRUMINFO|jq -r .hash)
  echo "export DD_APPLICATION_ID=\$(echo \$DDRUMINFO|jq -r .application_id)" >> .bashrc
  echo "export DD_CLIENT_TOKEN=\$(echo \$DDRUMINFO|jq -r .hash)" >> .bashrc

  # Add DD_RUM_ID to the footer for RUM usage
  sed -e "s/RUM_APP_ID/\$DD_APPLICATION_ID/" /home/ec2-user/microservices-demo-multiarch/src/frontend/templates/header-template.html | sed -e "s/RUM_CLIENT_TOKEN/\$DD_CLIENT_TOKEN/" > /home/ec2-user/microservices-demo-multiarch/src/frontend/templates/header.html
  echo "Fronted footer updated"
else
  echo "jq not installed"
fi

# now fire up the stack
cd /home/ec2-user/microservices-demo-multiarch
./ctf/microservices/start.sh 
EOI

chown ec2-user /tmp/initinstance.sh
chmod u+x /tmp/initinstance.sh
su - ec2-user -c "/tmp/initinstance.sh > /tmp/initinstance.log"

# enable password-based ssh logins
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo service sshd restart

source .bashrc
EOL

  tags = {
    Name = "${var.event_shortname}-${each.value.name}"
  }
}

output "swagstore_instance_public_ips" {
  description = "Public IP addresses of the instances"
  value = {
    for k, instance in aws_instance.swagstore :
    k => instance.public_ip
  }
}

output "ec2_user_password" {
    value = random_password.password.result
    description = "To view ec2_user password run this command: terraform output ec2_user_password"
    sensitive = true
}

#### AWS RESOURCES

resource "aws_lb_target_group" "swagstore" {
  
  for_each = aws_instance.swagstore

  name       = "${each.value.tags.Name}-tg"
  target_type= "instance"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = data.aws_vpc.tsre_vpc.id

  tags = {
      targetinstance = "${each.value.id}"
      team = "${each.value.tags.Name}"
  }

  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/health"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "swagstore" {
  for_each = aws_lb_target_group.swagstore

  # one target for each target group

  target_group_arn = "${each.value.arn}"
  target_id        = "${each.value.tags.targetinstance}"
  port             = 80

}

resource "aws_lb" "swagstore" {
  for_each = aws_lb_target_group.swagstore

  # one lb for each target group
  name               = "${each.value.name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.tsre_sg.id]

  subnets = [
    data.aws_subnet.tsre_subnet[data.aws_subnets.tsre_subnets.ids[0]].id,
    data.aws_subnet.tsre_subnet[data.aws_subnets.tsre_subnets.ids[1]].id
  ]

  tags = {
      targettg = "${each.value.arn}"
      team = "${each.value.tags.team}"
  }

}

resource "aws_lb_listener" "http" {
  # one listener for each lb
  for_each = aws_lb.swagstore

  load_balancer_arn = each.value.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = each.value.tags.targettg
  }
}

# Define the data source for the ACM certificate
data "aws_acm_certificate" "domain_cert" {
  domain   = "*.${var.domain}"
  statuses = ["ISSUED"]

  # If there are multiple certificates for the same domain, this will take the most recent one.
  most_recent = true
}

resource "aws_lb_listener" "https" {
  # one listener for each lb
  for_each = aws_lb.swagstore

  load_balancer_arn = each.value.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = data.aws_acm_certificate.domain_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = each.value.tags.targettg
  }
}

# Define the Route 53 Zone data source from the domain name
data "aws_route53_zone" "selected_route53_zone" {
  name         = "${var.domain}"
  private_zone = false
}

# set up the domain name for the alb
resource "aws_route53_record" "subdomain-team" {
  for_each = aws_lb.swagstore
  zone_id = data.aws_route53_zone.selected_route53_zone.zone_id
  name    = "${each.value.tags.team}"
  type    = "A"

  alias {
    name                   = each.value.dns_name
    zone_id                = each.value.zone_id
    evaluate_target_health = true
  }
}