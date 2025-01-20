output "sns_arn" {
  value = aws_sns_topic.sns_example.arn
  description = "The ARN of the SNS topic"
}
