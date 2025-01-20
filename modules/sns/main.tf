# SNS Topic
resource "aws_sns_topic" "sns_example" {
  name = "sns_example"
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "sns_example" {
  topic_arn = aws_sns_topic.sns_example.arn
  protocol  = "email"
  endpoint  = var.sub_email
}
