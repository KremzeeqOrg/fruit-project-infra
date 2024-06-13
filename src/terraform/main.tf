terraform {
  backend "s3" {
    bucket = "fruit-project-foundations"
    key    = "fruit-project/fruit-project-foundations"
    region = "eu-west-2"
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.52.0"
    }
  }
}

provider "aws" {
  # Configuration options
}



module "dynamo_db" {
  source = "./modules/dynamo_db"
  app = var.app
  stack = var.stack
  env = var.env
  
}