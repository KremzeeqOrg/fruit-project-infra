# Fruit Project Infra

Provisions AWS resources coded in Terraform for Fruit Project

## Resources provisioned

- [3 AWS Dynamo DB tables](./terraform/modules/dynamo_db/main.tf): These are target Dynamo DB tables, which scraped records from external APIs are pushed to for the project.
- 1 ECR Repository for fruit-project-api-scraper app Docker images.

## Bootstrap

This refers to resources which need to be created manually for Terraform to work with a remote state in AWS S3 bucket.

This project supports deploying to `dev` and `prod` environments hosted in 2 different AWS accounts. In these target accounts, create the following, with a tag for the `stack` name e.g. `fruit_project_foundations` :

- S3 bucket
- DynamoDB table - add a partition key e.g. `fruit_project/fruit_project_foundations` and `LockID` as the `hash_key`. The `hash_key` helps avoid different members interacting with the Terraform state at the same time.
- IAM role for GitHub Actions to assume e.g. `GitHubActions-AssumeRole`

Notice that these are referenced in the top level terraform main.tf file [here](./terraform/main.tf)
Please see Terraform docs [here](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) fo more info on setting up backend configuraion.

In relation to the IAM role, this should have a trust policy, which enables GitHub as a OIDC provider to assume the role with certain permissions. A policy should also be attached to the role, applying the pinciple of 'least privilige'. Please consult this [AWS blog](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/) for further guidance.

### Configuration for GitHub Actions

In GitHub, create 2 GitHub environments with enviornment variables and secrets for the following :

Secrets:

- AWS_ACCOUNT_ACCESS_ROLE: AWS arn for the IAM role uyou have created as part of the Bootstrap process.

Environment variables:

#### Environment variables required per a GitHub environment

<details>

| Field                    | Explanation                                                  |
| ------------------------ | ------------------------------------------------------------ |
| `ENV`                    | e.g. `feature` / `dev` / `prod`                              |
| `MINIMUM_APPROVALS`      | Mininum number of approvals required for deploying to `prod` |
| `TF_BACKEND_CONFIG_FILE` | e.g. `config-vars/backend-dev.tfvars`                        |
| `TF_VARS_FILE`           | e.g. `config-vars/tf-vars-dev.tfvars`                        |
| `TF_VERSION`             | e.g. `1.8.5`                                                 |
| `TF_WORKING_DIR`         | e.g. `terraform`                                             |

</details>

#### Secrets required per a GitHub environment

<details>

| Field                     | Explanation                                                                                                                                                                                                                                                                                                                                                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `AWS_REGION`              | Target AWS region e.g `eu-west-2`                                                                                                                                                                                                                                                                                                                                                                |
| `AWS_ACCOUNT_ACCESS_ROLE` | This is the name of the AWS IAM role with a trust policy, which enables GitHub as a OIDC provider to assume the role with certain permissions. A policy should also be attached to the role, applying the 'principle of least privilege'. Please consult this [AWS blog](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/) for further guidance. |
| `TF_PLAN_APPROVERS`       | e.g. `GitHubUser1,GitHubUser2`                                                                                                                                                                                                                                                                                                                                                                   |

</details>

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
