# Fruit Project Infra

Provisions AWS resources coded in Terraform for Fruit Project

## Resources provisioned

- [3 AWS Dynamo DB tables](./terraform/modules/dynamo_db/main.tf): These are target Dynamo DB tables, which scraped records from external APIs are pushed to for the project.

## Run Terraform locally

### Prerequisittes

- Terraform version: v1.8.5
- Ability to set AWS context, e.g. with [aws-vault](https://github.com/99designs/aws-vault)

### Steps for running code locally

1. Navigate to `./src/terraform`
2. Set aws context e.g. `aws-vault exec <profile>`
3. `terraform init`
4. `terraform plan ---var-file terraform.tfvars.json` - Ensure to review environment variables set in `./src/terraform/terraform.tfvars.json` before you run this. Once you run the command, review the plan.
5. `terraform apply ---var-file terraform.tfvars.json` - Ensure to review the plan before you apply.

Resources can be teared down with `terraform destroy`.
