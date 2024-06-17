# Fruit Project Infra

Provisions AWS resources coded in Terraform for Fruit Project

## Resources provisioned

- [3 AWS Dynamo DB tables](./terraform/modules/dynamo_db/main.tf): These are target Dynamo DB tables, which scraped records from external APIs are pushed to for the project.

## Run Terraform via GitHub Actions

- Review Github Actions workflow [here](.github/workflows/main_workflow.yml) to see steps for provisioning resources
- Basically, a Terraform plan is raised when a pr is raised and the pr is decorated with the plan for review
- When a pr is merged, a Terraform plan, fllowed by Terraform apply is run with an auto-approve option. If it fails, raise another pr to resolve the bug.

## Run Terraform locally

### Prerequisittes

- Terraform version: v1.8.5
- Ability to set AWS context, e.g. with [aws-vault](https://github.com/99designs/aws-vault)

### Steps for running code locally

1. Navigate to `./terraform`
2. Set aws context e.g. `aws-vault exec <profile>`
3. `terraform init`
4. `terraform plan ---var-file terraform.tfvars.json` - Ensure to review environment variables set in `./src/terraform/terraform.tfvars.json` before you run this. Once you run the command, review the plan.
5. `terraform apply ---var-file terraform.tfvars.json` - Ensure to review the plan before you apply.

Resources can be teared down with `terraform destroy`.
