terraform {
  backend "s3" {
    key    = "data-lake"
    region = "eu-central-1"
    bucket = "data-mesh-bootstrap-kmok-terraform-state"
    dynamodb_table = "data-mesh-bootstrap-kmok-terraform-lock"
    profile = "twdu-europe"
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "twdu-europe"
}

data "aws_caller_identity" "current" {}
