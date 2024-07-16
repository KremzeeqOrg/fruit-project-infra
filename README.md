# Fruit Project Infra

Provisions AWS resources coded in Terraform for Fruit Project

## Contents

<details>

- [Resources provisioned](#resources-provisioned)
- [Bootstrap](#bootstrap)
- [Configuration for GitHub Actions](#configuration-for-github-actions)
  - [Environment variables required per a GitHub environment](#environment-variables-required-per-a-github-environment)
  - [Secrets required per a GitHub environment](#secrets-required-per-a-github-environment)
- [Run Terraform via GitHub Actions](#run-terraform-via-github-actions)
- [Run Terraform locally](#run-terraform-locally)
  - [Prerequisittes](#prerequisittes)
  - [Steps for running code locally](#steps-for-running-code-locally) -[Appendix](#appendix) -[Validating your Terraform configuration](#validating-your-terraform-configuration)

</details>

## Resources provisioned

- [3 AWS Dynamo DB tables](./terraform/modules/dynamo_db/main.tf): These are target DynamoDB tables, which scraped records from external APIs are pushed to for the project.
- 1 ECR Repository for fruit-project-api-scraper app Docker images.

## Bootstrap

<details>

This refers to resources which need to be created manually for Terraform to work with a remote state in AWS S3 bucket.

This project supports deploying to `dev` and `prod` environments hosted in 2 different AWS accounts.

In these target accounts, maually create the following:

- S3 bucket: This should be uniquely named per an environment e.g. `fruit-project-foundations-<env>`
- DynamoDB table: Create a table e.g. `fruit-project-foundations` and add `LockID` as the Partition key. This helps avoid different users interacting with the Terraform state at the same time.

In the Terraform backend files at `/terraform/config-vars/backend-<env>.tfvars`, review and update the values. You can read more about validating your Terraform setup [here](#validating-your-terraform-configuration)

In the target accounts, you will also need to created an AWS IAM role which can be assumed by GitHub actions workflows.

In relation to the IAM role, this should have a trust policy, which enables GitHub as a OIDC provider to assume the role with certain permissions. A policy should also be attached to the role, applying the 'principle of least privilige'. Please consult this [AWS blog](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/) for further guidance.

Following this, it is necessary to setup environment variables and secrets per a GitHub environment for your repo.

</details>

## Configuration for GitHub Actions

### Environment variables required per a GitHub environment

<details>

| Field                    | Explanation                                                  |
| ------------------------ | ------------------------------------------------------------ |
| `ENV`                    | e.g. `dev` / `prod`                                          |
| `MINIMUM_APPROVALS`      | Mininum number of approvals required for deploying to `prod` |
| `TF_BACKEND_CONFIG_FILE` | e.g. `config-vars/backend-dev.tfvars`                        |
| `TF_VARS_FILE`           | e.g. `config-vars/tf-vars-dev.tfvars`                        |
| `TF_VERSION`             | e.g. `1.8.5`                                                 |
| `TF_WORKING_DIR`         | e.g. `terraform`                                             |

</details>

### Secrets required per a GitHub environment

<details>

| Field                     | Explanation                                                                 |
| ------------------------- | --------------------------------------------------------------------------- |
| `AWS_REGION`              | Target AWS region e.g `eu-west-2`                                           |
| `AWS_ACCOUNT_ACCESS_ROLE` | AWS arn for the IAM role you have created as part of the Bootstrap process. |
| `TF_PLAN_APPROVERS`       | e.g. `GitHubUser1,GitHubUser2`                                              |

</details>

## Run Terraform via GitHub Actions

<details>

- Review Github Actions workflow [here](.github/workflows/main_workflow.yml) to see steps for provisioning resources
- Basically, a Terraform plan is raised when a PR is raised and the PR is decorated with the plan for review
- When a PR is merged, a Terraform plan, followed by Terraform apply is run with an auto-approve option. If it fails, raise another PR to resolve the bug.

</details>

## Run Terraform locally

<details>

### Prerequisittes

- Terraform version: v1.8.5
- Ability to set AWS context, e.g. with [aws-vault](https://github.com/99designs/aws-vault)

### Steps for running code locally

These steps relate to running Terraform commands in relation to the `dev` environment

1. Navigate to `./terraform`
2. Set aws context e.g. `aws-vault exec <profile>`
3. `terraform init -backend-config=./config-vars/backend-dev.tfvars`
4. `terraform plan -var-file=./config-vars/tf-vars-dev.tfvars  -out=.tfplanfile` - Ensure to review environment variables before you run this. Once you run the command, review the plan.
5. `terraform apply ---var-file terraform.tfvars.json` - Ensure to review the plan before you apply.

Resources can be teared down with `terraform destroy -var-file=./config-vars/tf-vars-dev.tfvars`.

</details>

## Appendix

## Validating your Terraform configuration

If you set the `key` as `state/terraform.tfstate`, you will see that under `LockID`, the partition key will show as `<your-bucket>/state/terraform.tfstate-md5` when the state is first automatically created from running GitHub Actions workflows. In the S3 bucket, the Terraform state would be found under `state`. The `entity tag` (`Etag`) for the state in the S3 will align with the `Digest` listed alongside the corresponding partition key. By also checking `Last modified` for the state file in S3 bucket, you can confirm that the terraform setup is correctly configured.

Please see Terraform docs [here](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) for more info on setting up backend configuraion.
