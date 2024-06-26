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

resource "aws_s3_bucket" "lab4-s3-bucket" {
  bucket        = var.bucket
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "lab4-s3-block-public-access" {
  bucket                  = aws_s3_bucket.lab4-s3-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_sqs_queue" "lab4-sqs-dlq" {
  name = "dead-letter-queue"
}

resource "aws_sqs_queue" "lab4-sqs-queue" {
  name                      = "image-resize-requests"
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue_redrive_policy" "lab4-sqs-queue" {
  queue_url      = aws_sqs_queue.lab4-sqs-queue.url
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.lab4-sqs-dlq.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "lab4-sqs-dlq" {
  queue_url            = aws_sqs_queue.lab4-sqs-dlq.url
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.lab4-sqs-queue.arn]
  })
}

module "fn-image-upload" {
  source      = "./modules/image-upload"
  bucket_arn  = aws_s3_bucket.lab4-s3-bucket.arn
  bucket_name = aws_s3_bucket.lab4-s3-bucket.bucket
  depends_on  = [aws_s3_bucket.lab4-s3-bucket]
}

module "fn-image-resize-dispatch" {
  source          = "./modules/image-resize-dispatch"
  bucket_id       = aws_s3_bucket.lab4-s3-bucket.id
  bucket_arn      = aws_s3_bucket.lab4-s3-bucket.arn
  bucket_name     = aws_s3_bucket.lab4-s3-bucket.bucket
  queue_arn       = aws_sqs_queue.lab4-sqs-queue.arn
  queue_url       = aws_sqs_queue.lab4-sqs-queue.url
  thumbnail_sizes = var.thumbnail_sizes
  depends_on      = [aws_s3_bucket.lab4-s3-bucket, aws_sqs_queue.lab4-sqs-queue]
}

module "fn-image-resize" {
  source      = "./modules/image-resize"
  bucket_arn  = aws_s3_bucket.lab4-s3-bucket.arn
  bucket_name = aws_s3_bucket.lab4-s3-bucket.bucket
  queue_arn   = aws_sqs_queue.lab4-sqs-queue.arn
  depends_on  = [aws_s3_bucket.lab4-s3-bucket, aws_sqs_queue.lab4-sqs-queue]
}
