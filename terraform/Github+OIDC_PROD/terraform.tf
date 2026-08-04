terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84.0"
    }
  }
} # <-- This closing brace was missing

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}
