terraform {
  backend "s3" {
    bucket  = "sk-terraform-stacks"
    encrypt = true
    key     = "deploys/emr/dev"
    region  = "eu-west-1"
  }
}

provider "aws" {
  region              = local.aws_region
  allowed_account_ids = local.aws_account_ids
}

locals {
  aws_region = "eu-west-1"
}
