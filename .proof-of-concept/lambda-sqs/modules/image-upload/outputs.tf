output "fn-image-upload-arn" {
  description = "The ARN of image upload function"
  value       = aws_lambda_function.fn-image-upload.arn
}

output "fn-image-upload-url" {
  description = "The base URL for image upload function"
  value       = aws_apigatewayv2_stage.fn-image-upload-stage.invoke_url
}
