Here's a structured `README.md` file based on the provided details:

```markdown
# Automate Event-Driven Notifications

This project demonstrates the automation of event-driven notifications using AWS services, Terraform, Python, and SportsData.io API.

## Prerequisites

- Terraform installed with fundamental knowledge of its usage.
- An AWS Account.
- Familiarity with AWS services.
- An email address or phone number for notifications.
- GitHub repository initialized with a `.gitignore` file (Terraform template recommended).
- SportsData.io account with an API Key.
- Python script for Lambda.

**GitHub Repository:** [Event-Driven Auto](https://github.com/Hiteshpipaliya1223/event-driven-auto.git)

---

## Folder and File Setup

1. Clone your GitHub repository.
2. Open the `.gitignore` file and ensure appropriate configurations.
3. Create a `.tfvars` file and include the necessary credentials:
   ```plaintext
   sports_api_key = "<your-api-key>"
   ```
   Alternatively, export your API key using the CLI:
   ```bash
   export TF_VAR_<variable_name>="<your-api-key>"
   ```
4. Organize your files:
   - Create a Terraform directory (e.g., `aws-terraform`) with `main.tf`, `variables.tf`, and `provider.tf`.
   - Create a `modules` directory with subdirectories for `iam-policy`, `sns`, `lambda`, and `eventbridge`.

---

## Configurations

### **Provider Configuration**

In `provider.tf`:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
    }
  }
}

provider "aws" {
  region = var.region
}
```

Define variables in `variables.tf`:
```hcl
variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "sports_api_key" {
  description = "API Key for SportsData.io"
  type        = string
}
```

---

### **AWS SNS Setup**

In `modules/sns/main.tf`:
```hcl
resource "aws_sns_topic" "sns_example" {
  name = "sns_example"
}

resource "aws_sns_topic_subscription" "sns_example" {
  topic_arn = aws_sns_topic.sns_example.arn
  protocol  = "email"
  endpoint  = var.sub_email
}
```

Output the ARN in `output.tf`:
```hcl
output "sns_arn" {
  value       = aws_sns_topic.sns_example.arn
  description = "The ARN of the SNS topic"
}
```

Variable configuration in `variables.tf`:
```hcl
variable "sub_email" {
  description = "Email to subscribe to the SNS topic"
  type        = string
  default     = "hitopipaloya1223@gmail.com"
}
```

---

### **IAM Policy for SNS**

In `modules/iam-policy/main.tf`:
```hcl
resource "aws_iam_policy" "iam_sns_policy" {
  name        = "my-test-policy"
  description = "SNS Policy for Lambda function"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sns:Publish",
        Effect = "Allow",
        Resource = var.arn_filler
      },
    ]
  })
}
```

Define the placeholder variable in `variables.tf`:
```hcl
variable "arn_filler" {
  description = "ARN of the SNS topic"
  type        = string
}
```

---

### **Lambda Function**

In `modules/lambda/main.tf`:
```hcl
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
```

Python Lambda script (`lambda_code/gameday.py`):
```python
import json

def lambda_handler(event, context):
    message = {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
    return message
```

Zip the Lambda code:
```bash
zip -r function.zip gameday.py
```

---

### **EventBridge Scheduler**

In `modules/eventbridge/main.tf`:
```hcl
resource "aws_cloudwatch_event_rule" "example" {
  name                = "example-schedule"
  description         = "Trigger every 1 minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "example_target" {
  rule = aws_cloudwatch_event_rule.example.name
  arn  = var.sns_arn
}
```

Variable configuration in `variables.tf`:
```hcl
variable "sns_arn" {
  description = "SNS ARN"
  type        = string
}
```

---

### **Parent Module**

In the root `main.tf` file:
```hcl
module "sns" {
  source    = "./modules/sns"
  sub_email = "your_email@example.com"
}

module "iam_policy" {
  source     = "./modules/iam-policy"
  arn_filler = module.sns.sns_arn
}

module "lambda" {
  source          = "./modules/lambda"
  sns_arn         = module.sns.sns_arn
  api_key         = var.sports_api_key
  lambda_role_arn = aws_iam_role.lambda_role.arn
}

module "eventbridge" {
  source          = "./modules/eventbridge"
  sns_arn         = module.sns.sns_arn
  lambda_role_arn = aws_iam_role.lambda_role.arn
}
```

---

## Deployment Steps

Run the following Terraform commands:
```bash
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply
```

---

## Result

The automated notification system is now deployed and integrated with AWS SNS, Lambda, and EventBridge. Adjust the EventBridge scheduler as needed to trigger notifications at your desired intervals.
```
