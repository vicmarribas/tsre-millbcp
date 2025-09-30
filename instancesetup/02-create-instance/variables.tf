variable "teams" {
  type = map(
    object({
      name                    = string
      dd_api_key              = string
      dd_app_key              = string
    }
  ))
}

variable cthulhu_url {
  type = string
}

variable multiship_dd_api_key {
  type = string
}

variable event_name {
  type = string
}

variable event_shortname {
  type = string
}

variable event_description {
  type = string
}

variable ctf_url {
  type = string
}

variable aws_access_key {
  type = string
}

variable "microservices_version" {
    type = string
}

variable aws_secret_key {
  type = string
}

variable "domain" {
  type = string
}