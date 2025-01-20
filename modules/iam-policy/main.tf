resource "aws_iam_policy" "iam_sns_policy" {
  name        = "my-test-policy"
  description = "SNS Policy for Lambda function"

  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sns:Publish",
        Effect   = "Allow",
        Resource = var.arn_filler
      },
    ]
  })
}