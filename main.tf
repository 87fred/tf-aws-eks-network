terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Apenas um recurso de teste para validar a conexão
resource "aws_s3_bucket" "test_bucket" {
  bucket = "meu-bucket-teste-fred-2026"
}
