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

variable "aws_key_pair_name" {
  description = "AWS Key Pair Name"
}
