module "aws-dev" {
  source = "../../infra"
  instance = "t2.micro"
  aws_region = "us-east-1"
  key = "IaC-DEV"
  secutity_group = "Dev"
  minimum = 0
  maximum = 1
  groupName = "DevGroup"
}

output "IP" {
  value = module.aws-dev.public_IP
}