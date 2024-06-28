variable "aws_access_key" {
  description = "AWS Access Key"
  sensitive = true
  nullable = true
  default = null
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  sensitive = true
  nullable = true
  default = null
}

variable "aws_region" {
  description = "AWS Region"
  default = "eu-central-1"
}

variable "aws_instance_type" {
  description = "AWS Instance Type"
  default = "t2.micro"
}

variable "admin_cidr_blocks" {
  description = "List of CIDR blocks to allow SSH access"
  type = list(string)
  default = []
}
