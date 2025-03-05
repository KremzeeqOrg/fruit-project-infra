terraform {
  backend "s3" {
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.52.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

module "dynamo_db" {
  source = "./modules/dynamo_db"
  app    = var.app
  stack  = var.stack
  env    = var.env

}

resource "aws_ecr_repository" "web_scraper_repo" {
  name                 = var.web_scraper_app
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "example" {
   provisioner "local-exec" {
   command = "echo hello"
   }
}

resource "aws_s3_bucket" "example" {
  bucket = "silvanas-bucket-${var.env}-x"

  tags = {
    created-by        = "terraform"
    env               = var.env
  }
}