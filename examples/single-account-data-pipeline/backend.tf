terraform {
  backend "s3" {
    key    = "single-account-data-pipeline"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "twdu-europe"
}

data "aws_caller_identity" "current" {}
