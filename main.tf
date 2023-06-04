terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
  key_name = "iac-key-alura"

  tags = {
    Name = "FirstInstance"
  }
}