module "aws-prod" {
  source = "../../infra"
  instance = "t2.micro"
  aws_region = "us-east-1"
  key = "IaC-Prod"
  secutity_group_name = "general_access_prod"
  security_group_description = "Prods group"
}

output "IP" {
  value = module.aws-prod.public_IP
}