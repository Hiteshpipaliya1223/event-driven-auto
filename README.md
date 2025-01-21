# event-driven-auto

Automate Event Driven Notifications

Prerequisites
•	Terraform installed + fundamental knowledge.
•	AWS Account
•	Comfortability with AWS services
•	An Email/number
•	GitHub repository with .gitignore file terraform template.
•	SportsData.io account + API Key
•	Python script
You can visit to my Github and download full code 

https://github.com/Hiteshpipaliya1223/event-driven-auto.git


Folder and File Setup

•	Open your IDE and clone your repository.
•	Open the .gitignore file and add
•	Create a .tfvars file and add in the necessary credential your SportsData.io API Key.

sports_api_key = "<your-api-key>"
•	Or export your API key using the CLI.

export TF_VAR_<varible.name>="<your-api-key>"
•	Next create a directory a directory for terraform (e.g. aws-terraform). Then Create files named, main.tf, variables.tf, and provider.tf.
•	Next make a directory for your modules inside the terraform directory.
•	Inside the module directory create directories, iam-policy, sns, lambda, and eventbridge.
•	Open the provider.tf file and add the AWS provider

terraform {
    required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.83.1"
    }
    }
}
provider "aws" {
    region = var.region
  
}
•	Next add the region for AWS
provider "aws" {
  region = var.region
}
•	Notice that there’s a variable in place for the region. You will be configuring that variable in the next step, or you can replace the variable.region with an actual AWS region (e.g region = “eu-west-2”).
•	Open the variables.tf file create a new variable block for the region.
•	variable "region" {
•	    type =string
•	    default = "eu-west-2"
•	  
•	}
•	
•	variable "sports_api_key" {
•	  description = "API Key for SportsData.io"
•	  type        = string
•	}

AWS SNS (Simple Notification Service)
•	Go to the sns directory and create 3 files. main.tf, output.tf, and variables.tf.
•	In the main.tf file construct a resource SNS service

•	# SNS Topic
•	resource "aws_sns_topic" "sns_example" {
•	  name = "sns_example"
•	}
•	
•	# SNS Topic Subscription
•	resource "aws_sns_topic_subscription" "sns_example" {
•	  topic_arn = aws_sns_topic.sns_example.arn
•	  protocol  = "email"
•	  endpoint  = var.sub_email
•	}
•	Now we need to create a subscriber resource. The subscriber will be the one receiving these notifications. Subscriptions must verify their email/number. (resource “aws_sns_topic_subscription” )
•	You will need to provide the topic arn (The sns topic arn), protocol (What type notification. email, sms, lambda, sms, http…), and endpoint (The endpoint will be your email/number/resource. depending on what protocol you choose).
•	Open the output file. Configure an output block to later be able to grab the sns topic’s arn.
Output.tf for SNS 

•	output "sns_arn" {
•	  value = aws_sns_topic.sns_example.arn
•	  description = "The ARN of the SNS topic"
•	}
•	Open the variables.tf file and create a variable block for the email/number.

•	variable "sub_email" {
•	  description = "Email to subscribe to the SNS topic"
•	  type        = string
•	  default     = "hitopipaloya1223@gmail.com"
•	}

Create IAM Policy for SNS 
This policy allows publishing to SNS (Simple Notification Service)
•	Go to the iam-policy directory and create 3 files. main.tf, output.tf and variables.tf.
•	Open the main.tf file and add an aws_iam_policy resource block.
•	The resource block should contain, name, path, description and policy. The policy will be in JSON format.
Main.tf
•	resource "aws_iam_policy" "iam_sns_policy" {
•	  name        = "my-test-policy"
•	  description = "SNS Policy for Lambda function"
•	
•	  
•	  policy = jsonencode({
•	    Version = "2012-10-17"
•	    Statement = [
•	      {
•	        Action = "sns:Publish",
•	        Effect   = "Allow",
•	        Resource = var.arn_filler
•	      },
•	    ]
•	  })
•	}
•	Still inside the iam-policy directory, open the variables.tf file.
•	Create a filler variable. (This variable will be replaced later, and will be used as filler for the time being)
Variable.tf

•	variable "arn_filler" {
•	    description = "ARN of the SNS topic"
•	    type        = string 
•	}

Set Up Lambda Function
•	Go to the lambda directory. Create 3 files:
•	 gameday.py, main.tf, and variables.tf.
Lambda Function Script 
•	Create another directory inside the lambda directory called lambda_code.
•	Inside the lambda_code directory create a new python file for your script.
•	Open the python file then add/update/configure your python script.
•	Using the CLI cd into the lambda_code directory. Then create a function.zip file that adds your python code into it.
Gameday.py

import json
def lambda_handler(event, context):
    message = {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
    return message

•	Open the main.tf file and add an aws_lambda_function resource block for the lambda function.
•	You will need to state the function_name, runtime, handler, filename, source_code_hash and role.

Main.tf

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

Variable.tf
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

Package Lambda Code:
Zip your Lambda code into a function.zip file.
zip -r function.zip gameday.py

 

Set Up Event Bridge Scheduler
  In the eventbridge directory, create the following files:
o	main.tf: Define the event bridge scheduler.
o	variables.tf: Define the SNS ARN variable.
main.tf
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

variables.tf:
variable "sns_arn" {
  description = "SNS ARN"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for EventBridge"
  type        = string
}


Parent Module Configuration
In the main.tf file of the root directory (parent module), configure the module blocks for each of the services:
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


Initialize and Apply Terraform

Run the following Terraform commands to initialize, validate, format, plan, and apply the configurations:
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply

