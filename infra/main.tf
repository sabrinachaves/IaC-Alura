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
  region = var.aws_region
}

resource "aws_launch_template" "machine" {
  image_id      = "ami-0261755bbcb8c4a84"
  instance_type = var.instance
  key_name      = var.key
  tags = {
    Name = "Terraform Ansible Python"
  }
  security_group_names = [var.secutity_group]
}

resource "aws_key_pair" "chaveSSH" {
  key_name   = var.key
  public_key = file("${var.key}.pub")
}

output "public_IP" {
  value = aws_instance.app_server.public_ip
} 
