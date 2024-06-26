variable "bucket_id" {
  type        = string
  description = "The ID of the S3 bucket"
}

variable "bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "queue_arn" {
  type        = string
  description = "The ARN of the SQS queue"
}

variable "queue_url" {
  type        = string
  description = "The queue URL for image resize requests"
}

variable "thumbnail_sizes" {
  type        = list(string)
  description = "List of thumbnail sizes to which the image is to be resized"
}
