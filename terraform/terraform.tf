terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.74.0"
    }
  }
}

provider "aws" {
  profile = var.environment
  region  = var.aws_region

  default_tags {
    tags = var.tags
  }
}