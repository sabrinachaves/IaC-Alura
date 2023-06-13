module "aws-prod" {
  source = "../../infra"
  instance = "t2.micro"
  aws_region = "us-east-1"
  key = "IaC-Prod"
  secutity_group = "Prod"
  minimum = 1
  maximum = 10
  groupName = "ProdGroup"
}
