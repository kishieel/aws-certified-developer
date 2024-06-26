variable "region" {
  type = string
  description = "The region where resources will be provisioned"
  default = "eu-central-1"
}

variable "ami" {
  type = string
  description = "The ID of Amazon Machine Image"
  default = "ami-02da8ff11275b7907"
}

variable "az" {
  type = string
  description = "The ID of Availability Zone"
  default = "eu-central-1a"
}

