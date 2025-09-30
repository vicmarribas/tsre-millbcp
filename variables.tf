variable "teams" {
    description = "A list of team names for each instances you would like to create."
    type = list(string)
}

variable dd_api_key {
    type = string
    description = "An API key for a Datadog master org that the team orgs should be spun off of. This is also the org we will be sending CTFd and Chtulhu datadog agent data to."
}

variable dd_app_key {
    type = string
    description = "An APP key for a Datadog master org that the team orgs should be spun off of."
}

variable "dd_admins" {
    description = "A list of admin emails for the Datadog Team orgs"
    type = list(string)
}

variable "aws_key" {
    type = string
    description = "The AWS Access key to use to provision resources."
}

variable "aws_secret" {
    type = string
    description = "The AWS Secret key to use to provision resources."
}

variable "aws_profile" {
    type = string
    description = "The AWS profile used to execute the terraform script"
}

variable "event_shortname" {
    type = string
    description = "The name of your Tears of SRE event in a form without whitespaces. Becomes a subdomain"
    default = "myevent"
}

variable "event_name" {
    type = string
    description = "The name of your Tears of SRE event"
    default = "My Event"
}

variable "event_description" {
    type = string
    description = "The description of your Tears of SRE event"
    default = "My great CTFd event"
}

variable "event_customer_name" {
    type = string
    description = "The customer name which will be used in the org name"
    default = "ENT"
}

variable "domain" {
    type = string
    description = "The domain name you want your instance to be created under."
    default = "ddctf.fr"
}

variable "team_size" {
    type = number
    description = "How many members should be in a team? Default is 5"
    default = 5
}

variable "ssh_key" {
    type = string
}

variable "ssh_passkey" {
    type = string
    default = "dash"
}

variable "ctfd_token" {
    type = string
    default = "tsreenv"
}

variable "cthulhu_version" {
    type = string
    default = "main"
    description = "Branch name for CTHULHU (https://github.com/DataDog/tsre-cthulhu) - default is main"
}

variable "ctfd_version" {
    type = string
    default = "master"
    description = "Branch name for CTFD (https://github.com/DataDog/pts-CTFd) - default is master"
}

variable "microservices_version" {
    type = string
    default = "main"
    description = "Branch name for TSRE-Microservices (https://github.com/DataDog/tsre-microservices) - default is main"
}