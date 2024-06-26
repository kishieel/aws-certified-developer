data "aws_iam_policy_document" "orders_to_notifications" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [
      aws_sqs_queue.in_app_notifications.arn,
      aws_sqs_queue.push_notifications.arn
    ]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.orders.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "in_app_notifications" {
  policy    = data.aws_iam_policy_document.orders_to_notifications.json
  queue_url = aws_sqs_queue.in_app_notifications.url
}

resource "aws_sqs_queue_policy" "push_notifications" {
  policy    = data.aws_iam_policy_document.orders_to_notifications.json
  queue_url = aws_sqs_queue.push_notifications.url
}
