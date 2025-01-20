resource "aws_lambda_function" "lambda_example" {
  function_name    = "example-lambda"
  runtime          = "python3.9"
  handler          = "gameday.lambda_handler"
  filename         = "${path.module}/function.zip"
  source_code_hash = filebase64sha256("${path.module}/function.zip")
  role             = var.lambda_role_arn
  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_arn
      API_KEY       = var.api_key
    }
  }
}
