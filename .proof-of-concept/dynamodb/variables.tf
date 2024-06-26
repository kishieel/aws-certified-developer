variable "region" {
  type        = string
  description = "The region where resources will be provisioned"
  default     = "eu-central-1"
}

variable "dynamodb_replica_regions" {
  type        = set(string)
  description = "The list of regions where replicas of dynamodb will be created"
  default     = ["eu-west-2"]
}
