provider "aws" {
  region = "us-east-2"
  alias = "ohio"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

  }
}