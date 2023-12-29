output "dynamodb_local_table_arn" {
  value = aws_dynamodb_table.local_table.arn
}

output "dynamodb_global_table_arn" {
  value = aws_dynamodb_table.global_table.arn
}

output "dynamodb_actions_table_arn" {
  value = aws_dynamodb_table.actions_table.arn
}
