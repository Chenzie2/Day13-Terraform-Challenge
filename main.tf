terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "grace-zawadi-terraform-state-2026"
    key            = "day13/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Sensitive variable with no default
variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

# Fetch secret from Secrets Manager
data "aws_secretsmanager_secret" "db_credentials" {
  name = "prod/db/credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

locals {
  db_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.db_credentials.secret_string
  )
}

# Sensitive output
output "db_username" {
  value     = local.db_credentials["username"]
  sensitive = true
}

output "secret_arn" {
  value       = data.aws_secretsmanager_secret.db_credentials.arn
  description = "ARN of the database credentials secret"
  sensitive   = false
}

output "sensitive_demo" {
  value     = var.db_password
  sensitive = true
}