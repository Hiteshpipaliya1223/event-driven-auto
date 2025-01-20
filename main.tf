module "sns" {
  source = "./modules/sns"
  sub_email = "np4757138@gmail.com"
}

module "iam_policy" {
  source  = "./modules/iam-policy"
  arn_filler = module.sns.sns_arn
}




#IAM ROLE 

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


module "lambda" {
  source         = "./modules/lambda"
  sns_arn        = module.sns.sns_arn
  api_key        = var.sports_api_key
  lambda_role_arn = aws_iam_role.lambda_role.arn
}

module "eventbridge" {
  source         = "./modules/eventbridge"
  sns_arn        = module.sns.sns_arn
  lambda_role_arn = aws_iam_role.lambda_role.arn
}
