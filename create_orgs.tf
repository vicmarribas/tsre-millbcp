resource "datadog_child_organization" "teamorg" {
    for_each = toset(var.teams)
    
    # update challenge1 in CTFd with the actual name
    name = "${var.event_customer_name} | CTF ${each.key}"
}


# we now create tfvars files for the following stages: 
# 1st: Org provisioning: we need to create bunch of things in the datadog org (monitors, filters, etc.)
# 2nd: create the actual instance for the team
# as there are manual steps involved in setting up each org, we do not run this automatically but the user has to run those stages themselves

# first we create the tfvars files with the general variable values
resource "local_file" "instancecreate_tfvars" {



    content = <<-EOT
domain = "${var.domain}"
cthulhu_url = "https://${aws_route53_record.cthulhusubdomain.name}"
multiship_dd_api_key = "${var.dd_api_key}"
event_name = "${var.event_name}"
event_shortname = "${var.event_shortname}"
event_description = "${var.event_description}"
ctf_url = "http://${aws_route53_record.ctfdsubdomain.name}"
aws_access_key = "${var.aws_key}"
aws_secret_key = "${var.aws_secret}"
teams = {
%{ for org in datadog_child_organization.teamorg ~}
${regex("(CTF )(Team-[0-9]*)", org.name)[1]} = {
    name = "${regex("(CTF )(Team-[0-9]*)", org.name)[1]}"
    dd_api_key = "${org.api_key[0].key}"
    dd_app_key = "${org.application_key[0].hash}"
},
%{ endfor ~}
}
microservices_version = "${var.microservices_version}"
EOT 
    filename = "./instancesetup/02-create-instance/${var.event_shortname}.tfvars"

}

resource "local_file" "orgprovision_apply_script" {

    content = <<-EOT
#!/bin/bash
%{ for org in datadog_child_organization.teamorg ~}
# team: ${regex("(CTF )(Team-[0-9]*)", org.name)[1]}
terraform workspace new ${var.event_customer_name}-${regex("(CTF )(Team-[0-9]*)", org.name)[1]}
terraform workspace select ${var.event_customer_name}-${regex("(CTF )(Team-[0-9]*)", org.name)[1]} 
terraform apply -auto-approve \
    -var team_name="${regex("(CTF )(Team-[0-9]*)", org.name)[1]}" \
    -var dd_api_key="${org.api_key[0].key}" \
    -var dd_app_key="${org.application_key[0].hash}"\
    -var 'dd_admins=["datadog-admin@dummy.com",${join(",", [for email in var.dd_admins : format("\"%s\"", email)])}]'
%{ endfor ~}

EOT 

    filename = "./instancesetup/01-provision_org/${var.event_shortname}_apply.sh"

}


resource "local_file" "orgprovision_destroy_script" {

    content = <<-EOT
#!/bin/bash
%{ for org in datadog_child_organization.teamorg ~}
# team: ${regex("(CTF )(Team-[0-9]*)", org.name)[1]}
terraform workspace new ${regex("(CTF )(Team-[0-9]*)", org.name)[1]}
terraform workspace select ${regex("(CTF )(Team-[0-9]*)", org.name)[1]} 
terraform destroy -auto-approve \
    -var team_name="${regex("(CTF )(Team-[0-9]*)", org.name)[1]}" \
    -var dd_api_key="${org.api_key[0].key}" \
    -var dd_app_key="${org.application_key[0].hash}"\
    -var 'dd_admins=[${join(",", [for email in var.dd_admins : format("\"%s\"", email)])}]'
terraform workspace select default
terraform workspace delete ${var.event_customer_name}-${regex("(CTF )(Team-[0-9]*)", org.name)[1]} 
%{ endfor ~}

EOT 

    filename = "./instancesetup/01-provision_org/${var.event_shortname}_destroy.sh"

}

resource "local_file" "orgprovision_rename_script" {

    content = <<-EOT
#!/bin/bash
%{ for org in datadog_child_organization.teamorg ~}
# team: ${regex("(CTF )(Team-[0-9]*)", org.name)[1]}
curl -X PUT "https://api.datadoghq.com/api/v1/org/${org.public_id}" \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "DD-API-KEY: ${org.api_key[0].key}" \
-H "DD-APPLICATION-KEY: ${org.application_key[0].hash}" \
-d '{ "name": "CTF-Delete ${regex("(CTF )(Team-[0-9]*)", org.name)[1]}" }'
%{ endfor ~}

EOT 

    filename = "./instancesetup/01-provision_org/${var.event_shortname}_rename.sh"

}

 