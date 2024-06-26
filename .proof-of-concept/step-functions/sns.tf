resource "aws_sns_topic" "orders" {
  name = "Orders"
}

resource "aws_sns_topic_subscription" "orders_to_in_app_notifications" {
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.in_app_notifications.arn
  topic_arn = aws_sns_topic.orders.arn
}

resource "aws_sns_topic_subscription" "orders_to_push_notifications" {
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.push_notifications.arn
  topic_arn = aws_sns_topic.orders.arn
}
