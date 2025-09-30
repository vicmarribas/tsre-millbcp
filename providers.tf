terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  #access_key = var.aws_key
  #secret_key = var.aws_secret
  profile    = "570690476889_power-user" 
}

# Configure the Datadog provider
provider "datadog" {
  api_key = var.dd_api_key
  app_key = var.dd_app_key
}

provider "random" {
}