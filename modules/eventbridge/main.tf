provider "aws" {
  region = "eu-west-2" # Replace with your desired AWS region
}

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "example" {
  name                = "example-schedule"
  description         = "Trigger every 1 minute"
  schedule_expression = "rate(1 minute)" # Use rate-based or cron-based, not both
}

# EventBridge Target (SNS Topic)
resource "aws_cloudwatch_event_target" "example_target" {
  rule = aws_cloudwatch_event_rule.example.name
  arn  = var.sns_arn        # Target ARN (SNS ARN)
}
