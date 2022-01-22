# -------------------------------
# Terraform Configuration
# -------------------------------
terraform {
  required_version = ">=1.0.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
  backend "s3" {
    bucket = "my-devops"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# -------------------------------
# Provider
# -------------------------------
provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
}