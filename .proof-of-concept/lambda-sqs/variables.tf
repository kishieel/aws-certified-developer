variable "region" {
  type        = string
  description = "The region where resources will be provisioned"
  default     = "eu-central-1"
}

variable "bucket" {
  type        = string
  description = "The name of the S3 bucket"
  default     = "lab4-s3-bucket-f47a"
}

variable "thumbnail_sizes" {
  type        = list(string)
  description = "List of thumbnail sizes to which the image is to be resized"
  default     = ["100x100", "300x300", "600x600"]
}
