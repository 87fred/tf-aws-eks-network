terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    #Invente o nome da sua própria bucket
    bucket = "terraform-state-eks-savethetfstate" 
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}
