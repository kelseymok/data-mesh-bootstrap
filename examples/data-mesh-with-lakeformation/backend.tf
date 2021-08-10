terraform {
  backend "s3" {
    key    = "data-lake"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "twdu-europe"
}

data "aws_caller_identity" "current" {}
