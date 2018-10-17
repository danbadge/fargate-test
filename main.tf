terraform {
  backend "s3" {
    bucket = "terraform-fargate-test"
    region = "eu-central-1"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region  = "${var.aws_preferred_region}"
  version = "~>1.40"
}