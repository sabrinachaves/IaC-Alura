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
  user_data            = var.production ? filebase64("ansible.sh") : ""
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
  target_group_arns = var.production ? [aws_lb_target_group.loadBalancerTarget[0].arn] : []
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
  count = var.production ? 1 : 0
}

resource "aws_lb_target_group" "loadBalancerTarget" {
  name     = "targetsMachine"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
  count = var.production ? 1 : 0
}

resource "aws_default_vpc" "default" {
}

resource "aws_lb_listener" "loadBalancerInput" {
  load_balancer_arn = aws_lb.loadBalancer[0].arn
  port = "8000"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.loadBalancerTarget[0].arn
  }
  count = var.production ? 1 : 0
}

resource "aws_autoscaling_policy" "prod-scale" {
  name = "terraform-scale"
  autoscaling_group_name = var.groupName
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
  count = var.production ? 1 : 0
}
