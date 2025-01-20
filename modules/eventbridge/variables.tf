variable "sns_arn" {
  description = "SNS ARN"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for EventBridge"
  type        = string
}
