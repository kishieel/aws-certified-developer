output "s3-bucket-arn" {
  value = aws_s3_bucket.lab4-s3-bucket.arn
}

output "fn-image-upload-arn" {
  value = module.fn-image-upload.fn-image-upload-arn
}

output "fn-image-upload-url" {
  value = module.fn-image-upload.fn-image-upload-url
}

output "fn-image-resize-dispatch-arn" {
  value = module.fn-image-resize-dispatch.fn-image-resize-dispatch-arn
}

output "fn-image-resize-arn" {
  value = module.fn-image-resize.fn-image-resize-arn
}

output "sqs-dlq-arn" {
  value = aws_sqs_queue.lab4-sqs-dlq.arn
}

output "sqs-queue-arn" {
  value = aws_sqs_queue.lab4-sqs-queue.arn
}

