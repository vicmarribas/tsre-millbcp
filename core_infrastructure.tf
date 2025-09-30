# this is the terraform file for all CTF core infrastructure, namely: 
# the CTFd instance, hosting CTFd
# the Cthulhu instance, hosting our game control server

### Create CTFd instance
# Get latest Amazon Linux AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "random_pet" "ctfname" {
  keepers = {
    uuid = var.event_name
  }
  prefix = "ctfd"
}

resource "aws_vpc" "tsre_vpc" {
  cidr_block = "172.31.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.event_shortname}-vpc"
    createdBy = "Terraform Script"
    event = "${var.event_name}"
    ctf = "true"
  }
}

output "tsre_vpc" {
    value = aws_vpc.tsre_vpc.id
    description = "TSRE VPC id"
}

variable "subnets" {
  description = "List of subnets for the TSRE_VPC"
  type = list(object({
    cidr_block = string
    availability_zone = string
  }))
  default = [
    { cidr_block = "172.31.16.0/20", availability_zone = "us-east-1a" },
    { cidr_block = "172.31.32.0/20", availability_zone = "us-east-1b" },
    { cidr_block = "172.31.0.0/20", availability_zone = "us-east-1c" },
    { cidr_block = "172.31.80.0/20", availability_zone = "us-east-1d" },
  ]
}

resource "aws_subnet" "tsre_subnet" {
  count = length(var.subnets)

  vpc_id            = aws_vpc.tsre_vpc.id
  cidr_block        = var.subnets[count.index].cidr_block
  availability_zone = var.subnets[count.index].availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.event_shortname}-subnet-${count.index}"
    createdBy = "Terraform Script"
    event = "${var.event_name}"
    ctf = "true"
  }
}

resource "aws_security_group" "tsre_sg" {
  name        = "tsre_sg"
  description = "Allow SSH from anywhere, and HTTP on 8080"
  vpc_id      = aws_vpc.tsre_vpc.id  

  # Inbound rules
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.200.51.236/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.event_shortname}-sg"
    createdBy = "Terraform Script"
    event = "${var.event_name}"
    ctf = "true"
  }
}

resource "aws_instance" "ctfd" {
  ami           = "${data.aws_ami.al2023.id}"
  instance_type = "t3.2xlarge"
  key_name      = "tsre-key"   #create a key pair in AWS console with this name, import the 1password key
  subnet_id     = aws_subnet.tsre_subnet[0].id

  vpc_security_group_ids = [aws_security_group.tsre_sg.id]

  root_block_device {
    volume_size = 8
  }

  user_data = <<-END
#!/bin/bash

# Install docker and deps
yum update -y
yum install docker git unzip wget -y
service docker start 
systemctl enable docker
usermod -a -G docker ec2-user

# Install docker-compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Set hostname
hostnamectl set-hostname ${random_pet.ctfname.id}

# Install agent 
DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true DD_API_KEY=${var.dd_api_key} DD_SITE="datadoghq.com" DD_ENV=dev bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"
# Enable logs in Datadog
sed -i 's/^# logs_enabled: false/logs_enabled: true/' /etc/datadog-agent/datadog.yaml
sed -i 's/^# logs_config/logs_config/' /etc/datadog-agent/datadog.yaml
sed -i 's/# container_collect_all: false/container_collect_all: true/' /etc/datadog-agent/datadog.yaml
service datadog-agent restart

usermod -a -G docker dd-agent

cat <<EOI > /tmp/initinstance.sh
#!/bin/bash

## Run as ec2-user when EC2 instance as been booted up and pre-config
# Go to home directory
cd /home/ec2-user

echo "export CTFD_HOST='http://${var.event_shortname}.${var.domain}'" >>.bashrc
echo "export CTFD_TOKEN='${var.ctfd_token}'" >>.bashrc
source .bashrc

git clone --single-branch --branch ${var.ctfd_version} https://github.com/DataDog/pts-CTFd.git 
cd pts-CTFd

wget https://dpn-learning-center-files.s3.amazonaws.com/data-vanilla.tar.bz2
tar -xvf data-vanilla.tar.bz2

docker-compose up -d
EOI

chown ec2-user /tmp/initinstance.sh
chmod u+x /tmp/initinstance.sh
su - ec2-user -c "/tmp/initinstance.sh > /tmp/initinstance.log"
systemctl restart datadog-agent


END

  tags = {
    Name = random_pet.ctfname.id
    event = "${var.event_name}"
    ctf = "true"
  }
}

output "ctfd_url" {
    value = "http://${var.event_shortname}.${var.domain}"
    description = "Public URL for CTFd"
}

output "ctfd_ip_addr" {
    value = "${aws_instance.ctfd.public_ip}"
    description = "Public IP for CTFd"
}


#### AWS RESOURCES for dns exposure
resource "aws_internet_gateway" "tsre_igw" {
  vpc_id = aws_vpc.tsre_vpc.id

  tags = {
    createdBy = "Terraform Script"
    event = "${var.event_name}"
    ctf = "true"
  }
}

resource "aws_route_table" "tsre_rt" {
  vpc_id = aws_vpc.tsre_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tsre_igw.id
  }

  tags = {
    Name = "${var.event_shortname}-rt"
    createdBy = "Terraform Script"
    event = "${var.event_name}"
    ctf = "true"
  }
}

resource "aws_route_table_association" "tsre_rta" {
  count = length(aws_subnet.tsre_subnet)

  subnet_id      = aws_subnet.tsre_subnet[count.index].id
  route_table_id = aws_route_table.tsre_rt.id
}

resource "aws_lb_target_group" "ctfd" {

  name       = "ctfd-${substr(random_pet.name.id, 0, 23)}-tg"
  target_type= "instance"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.tsre_vpc.id

  tags = {
      targetinstance = "${aws_instance.ctfd.id}"
  }

  health_check {
    enabled             = true
    port                = 80
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "ctfd" {

  target_group_arn = "${aws_lb_target_group.ctfd.arn}"
  target_id        = "${aws_lb_target_group.ctfd.tags.targetinstance}"
  port             = 80

}

resource "aws_lb" "ctfd" {

  name               = "ctfd-${substr(random_pet.name.id, 0, 23)}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tsre_sg.id]

  subnets = [
    aws_subnet.tsre_subnet[0].id,
    aws_subnet.tsre_subnet[1].id
  ]

  tags = {
      targettg = "${aws_lb_target_group.ctfd.arn}"
  }

}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.ctfd.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb.ctfd.tags.targettg
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

  load_balancer_arn = aws_lb.ctfd.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = data.aws_acm_certificate.domain_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb.ctfd.tags.targettg
  }
}

# Define the Route 53 Zone data source from the domain name
data "aws_route53_zone" "selected_route53_zone" {
  name         = "${var.domain}"
  private_zone = false
}

# Output the Domain used for Route 53 for verification
output "selected_route53_zone_domain" {
  value       = "${var.domain}"
  description = "The domain used for to select Route 53 hosted zone"
}

# Output the Zone ID for verification
output "selected_route53_zone_id" {
  value       = data.aws_route53_zone.selected_route53_zone.zone_id
  description = "The Zone ID of the selected Route 53 hosted zone"
}

# set up the domain name for the alb
resource "aws_route53_record" "ctfdsubdomain" {
  zone_id = data.aws_route53_zone.selected_route53_zone.zone_id
  name    = "${var.event_shortname}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ctfd.dns_name
    zone_id                = aws_lb.ctfd.zone_id
    evaluate_target_health = true
  }
}


### Create Cthulhu instance
resource "random_pet" "name" {
  keepers = {
    uuid = var.event_name
  }
  prefix = "cthulhu"
}

resource "aws_instance" "cthulhu" {
  ami           = "${data.aws_ami.al2023.id}"
  instance_type = "t3.2xlarge"
  key_name      = "tsre-key"  #create a key pair in AWS console with this name
  subnet_id     = aws_subnet.tsre_subnet[0].id

  vpc_security_group_ids = [aws_security_group.tsre_sg.id]

  root_block_device {
    volume_size = 8
  }

  user_data = <<EOF
#!/bin/bash

yum update -y
yum install docker git unzip wget -y
service docker start 
systemctl enable docker
usermod -a -G docker ec2-user

# Set hostname
hostnamectl set-hostname ${random_pet.name.id}

# Add DD agent
DD_LOGS_ENABLED=true DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true DD_API_KEY=${var.dd_api_key} DD_SITE="datadoghq.com" DD_APM_INSTRUMENTATION_ENABLED=host DD_ENV=dev bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"

mkdir /etc/datadog-agent/conf.d/nodejs.d

echo "init_config:" > /etc/datadog-agent/conf.d/nodejs.d/conf.yaml
echo "" >> /etc/datadog-agent/conf.d/nodejs.d/conf.yaml
echo "instances:" >> /etc/datadog-agent/conf.d/nodejs.d/conf.yaml
echo "##Log section" >> /etc/datadog-agent/conf.d/nodejs.d/conf.yaml
echo "logs:" >> /etc/datadog-agent/conf.d/nodejs.d/conf.yaml
echo "  - type: file" >> /etc/datadog-agent/conf.d/nodejs.d/conf.yaml
echo "    path: "/home/ec2-user/cthulhu/backend/app.log"" >> /etc/datadog-agent/conf.d/nodejs.d/conf.yaml
echo "    service: cthulhu" >> /etc/datadog-agent/conf.d/nodejs.d/conf.yaml
echo "    source: nodejs" >> /etc/datadog-agent/conf.d/nodejs.d/conf.yaml
echo "    sourcecategory: sourcecode" >> /etc/datadog-agent/conf.d/nodejs.d/conf.yaml

chown dd-agent:dd-agent -R /etc/datadog-agent/conf.d

# Enable logs in Datadog
sed -i 's/^# logs_enabled: false/logs_enabled: true/' /etc/datadog-agent/datadog.yaml

# Restart datadog service
systemctl restart datadog-agent

# Give capability to read in ec2-user to dd-agent
chmod go+x /home/ec2-user

cat <<EOL > /home/ec2-user/.ssh/ctfkey
${var.ssh_key}
EOL

chown ec2-user:ec2-user /home/ec2-user/.ssh/ctfkey
chmod go-r /home/ec2-user/.ssh/ctfkey

## now run stuff as ec2-user: 
cat <<EOI > /tmp/initinstance.sh
#!/bin/bash

## Run as ec2-user when EC2 instance as been booted up and pre-config

# Add key to ssh
eval \`ssh-agent -s\`
# add github.com to known hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts
ssh-add ~/.ssh/ctfkey
{ sleep .1; echo ${var.ssh_passkey}; } | script -q /dev/null -c 'ssh-add ~/.ssh/ctfkey'

# Install Cthulhu binaries
git clone --single-branch --branch ${var.cthulhu_version} git@github.com:DataDog/tsre-cthulhu.git
mv tsre-cthulhu cthulhu
cd cthulhu
cd -

# build image for attackbox
cd cthulhu/attackbox 
docker build . -t attackbox
cd -

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.bashrc
nvm install --lts

echo "NPM install"
# prep npm
cd cthulhu/frontend
npm install
npm run build
cd ../backend
npm install
npm install -g pm2

# Set up config
cat <<EOL > .env
PORT=3000
LOG=debug
FINAL_CHALLENGE=30
SSH_KEY="ctfkey"
TOKEN="${var.ctfd_token}"
# TOKEN="ctfd_873253749a7cfb57100bfa99a0204bb30285a5e87ffbca95f2566d3430e16f19"
AUTH="DARKEN7monday_copperas.revenge"
API_URL="https://${aws_route53_record.ctfdsubdomain.name}/api/v1"
DD_ENV=${var.event_shortname}
MY_URL="https://cthulhu-${var.event_shortname}.${var.domain}"
EOL

# Run Cthulhu
npm run prod

EOI

chown ec2-user /tmp/initinstance.sh
chmod u+x /tmp/initinstance.sh
su - ec2-user -c "/tmp/initinstance.sh > /tmp/initinstance.log"

EOF

  tags = {
    Name = random_pet.name.id
    ctf = "true"
  }
}

output "cthuhlhu_url" {
    value = "https://cthulhu-${var.event_shortname}.${var.domain}"
    description = "Public URL for CTFD"
}


output "cthulhu_ip_addr" {
    value = "${aws_instance.cthulhu.public_ip}"
    description = "Public IP for Cthulhu"
}


#### AWS RESOURCES for dns exposure
resource "aws_lb_target_group" "cthulhu" {

  name       = "${random_pet.name.id}-lb"
  target_type= "instance"
  port       = 3000
  protocol   = "HTTP"
  vpc_id     = aws_vpc.tsre_vpc.id

  tags = {
      targetinstance = "${aws_instance.cthulhu.id}"
  }

  health_check {
    enabled             = true
    port                = 3000
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "cthulhu" {

  target_group_arn = "${aws_lb_target_group.cthulhu.arn}"
  target_id        = "${aws_lb_target_group.cthulhu.tags.targetinstance}"
  port             = 3000

}

resource "aws_lb" "cthulhu" {

  name               = "${random_pet.name.id}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tsre_sg.id]

  subnets = [
    aws_subnet.tsre_subnet[0].id,
    aws_subnet.tsre_subnet[1].id
  ]

  tags = {
      targettg = "${aws_lb_target_group.cthulhu.arn}"
  }

}

resource "aws_lb_listener" "http-ctulhu" {

  load_balancer_arn = aws_lb.cthulhu.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb.cthulhu.tags.targettg
  }
}

resource "aws_lb_listener" "https-ctulhu" {

  load_balancer_arn = aws_lb.cthulhu.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = data.aws_acm_certificate.domain_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb.cthulhu.tags.targettg
  }
}

# set up the domain name for the alb
resource "aws_route53_record" "cthulhusubdomain" {
  zone_id = data.aws_route53_zone.selected_route53_zone.zone_id
  name    = "cthulhu-${var.event_shortname}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.cthulhu.dns_name
    zone_id                = aws_lb.cthulhu.zone_id
    evaluate_target_health = true
  }
}