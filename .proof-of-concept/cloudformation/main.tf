terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_cloudformation_stack" "lab3-cloudformation" {
  name = "lab3-cloudformation"

  parameters = {
    AMI = var.ami
    AZ = var.az
    UserData = filebase64("${path.module}/setup.sh")
  }

  template_body = file("${path.module}/stack.yaml")
}
