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
  user_data            = filebase64("ansible.sh")
}

resource "aws_key_pair" "chaveSSH" {
  key_name   = var.key
  public_key = file("${var.key}.pub")
}

resource "aws_autoscaling_group" "group" {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
  name               = var.groupName
  max_size           = var.maximum
  min_size           = var.minimum
  launch_template {
    id      = aws_launch_template.machine.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.loadBalancerTarget.arn]
}

resource "aws_default_subnet" "subnet_1" {
  availability_zone = "${var.aws_region}a"
}

resource "aws_default_subnet" "subnet_2" {
  availability_zone = "${var.aws_region}b"
}

resource "aws_lb" "loadBalancer" {
  internal = false
  subnets  = [aws_default_subnet.subnet_1.id, aws_default_subnet.subnet_2.id]
}

resource "aws_lb_target_group" "loadBalancerTarget" {
  name     = "targetsMachine"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_default_vpc" "default" {
}

resource "aws_lb_listener" "loadBalancerInput" {
  load_balancer_arn = aws_lb.loadBalancer.arn
  port = "8000"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.loadBalancerTarget.arn
  }
}
