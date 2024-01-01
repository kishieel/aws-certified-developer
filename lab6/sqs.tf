resource "aws_sqs_queue" "in_app_notifications" {
  name = "InAppNotifications"
}

resource "aws_sqs_queue" "push_notifications" {
  name = "PushNotifications"
}

