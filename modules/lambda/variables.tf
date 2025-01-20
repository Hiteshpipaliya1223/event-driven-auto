variable "sns_arn" {
  description = "SNS ARN"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for Lambda"
  type        = string
}

variable "api_key" {
  description = "API Key for SportsData.io"
  type        = string
}
