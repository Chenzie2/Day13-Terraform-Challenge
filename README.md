# Day 13: Managing Sensitive Data Securely in Terraform
30-Day Terraform Challenge

## Overview
This repository contains the complete hands-on work for Day 13 of the 30-Day Terraform Challenge.  
The focus is on understanding how secrets leak in Terraform and implementing secure practices using AWS Secrets Manager, sensitive variables/outputs, and a secure remote state backend.

## The Three Secret Leak Paths

### 1. Hardcoded in .tf files
**Vulnerable pattern:**
```bash
resource "aws_db_instance" "example" {
  username = "admin"
  password = "super-secret-password"
}
```
- Secure alternative: Never hardcode secrets. Fetch them dynamically using data sources.

### 2. Variables with Default Values
Vulnerable pattern:
```bash
variable "db_password" {
  default = "super-secret-password"
}
```
Secure alternative:
```bash
variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
```

### 3. Plaintext in Terraform State File
Even when secrets are not in code, Terraform stores sensitive attribute values in terraform.tfstate in plaintext.
Solution: Always use an encrypted remote backend with strict access controls.

### Project Setup Instructions
Follow these steps to replicate the project on your machine:

#### 1. Clone the Repository
```bash
git clone https://github.com/Chenzie2/Day13-Terraform-Challenge.git
cd Day13-Terraform-Challenge
```
#### 2. Create the Secret in AWS Secrets Manager
```bash
aws secretsmanager create-secret \
  --name "prod/db/credentials" \
  --secret-string '{"username":"dbadmin","password":"SecurePassword123!"}'
```
#### 3. Initialize Terraform
```bash
terraform init
```
#### 4. Plan and Apply
```bash
terraform plan \
  -var="db_password=SecurePassword123!" \
  -var="db_username=dbadmin"

terraform apply \
  -var="db_password=SecurePassword123!" \
  -var="db_username=dbadmin"
```
- When prompted, type yes.
#### 5. View Outputs
```bash
terraform output
terraform output db_username          # Shows (sensitive value)
terraform output -json db_username    # Reveals the value (stored in state)
```
#### 6. Cleanup
```bash
terraform destroy \
  -var="db_password=SecurePassword123!" \
  -var="db_username=dbadmin"
```
- Delete the secret:
```bash
aws secretsmanager delete-secret \
  --secret-id "prod/db/credentials" \
  --force-delete-without-recovery
```

### Files Included

* main.tf          → Backend configuration, provider, data sources, locals, and resources
* variables.tf     → Environment variable with validation
* .gitignore       → Standard Terraform ignore file

### Key Learnings
- sensitive = true prevents values from appearing in CLI output and logs, but does not hide them from the state file.
- AWS Secrets Manager integration keeps secrets out of version control.
- Remote S3 backend with encryption and least-privilege IAM is mandatory for production.
- Never commit .terraform/, *.tfstate, or *.tfvars files.

## Advanced Secrets Management Guide
Full reference guide covering AWS Secrets Manager, HashiCorp Vault, state security, and IAM policies:
→ https://github.com/Chenzie2/terraform-secrets-management-guide

🔐 Day 13 of the 30-Day Terraform Challenge — secrets management deep dive. Three ways secrets leak in Terraform configurations, how to close every one of them, and why the state file is the last line of defence. Security is not optional in production infrastructure. #30DayTerraformChallenge #TerraformChallenge #Terraform #Security #DevOps #IaC #AWSUserGroupKenya #EveOps

Made as part of the 30-Day Terraform Challenge by AWS AI/ML User Group Kenya, Meru HashiCorp User Group, and EveOps.

## Author
Grace Zawadi - Software Engineer 