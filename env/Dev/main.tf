module "aws-dev" {
  source = "../../infra"
  instance = "t2.micro"
  aws_region = "us-east-1"
  key = "IaC-DEV"
    secutity_group_name = "general_access_dev"
  security_group_description = "Devs group"
}

output "IP" {
  value = module.aws-dev.public_IP
}