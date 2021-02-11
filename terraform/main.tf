# main.tf
module "us-east-1-common" {
  source = "./modules/multi-region/"
  region = "us-east-1"
  vpc_cidr = "172.16.0.0/16"
  subnet_cidr_a = "172.16.1.0/24"
  subnet_cidr_b = "172.16.2.0/24"
  subnet_cidr_c = "172.16.3.0/24"
  ami = module.us-east-1.aws_ami_us-east-1
  providers = {
    aws = aws
  }

}
module "eu-west-1-common" {
  source = "./modules/multi-region/"
  region = "eu-west-1"
  vpc_cidr = "10.10.0.0/16"
  subnet_cidr_a = "10.10.1.0/24"
  subnet_cidr_b = "10.10.2.0/24"
  subnet_cidr_c = "10.10.3.0/24"
  ami = "ami-cdbfa4ab"
  providers = {
    aws = aws.eu-west-1
  }

}

module "us-east-1" {
  source = "./modules/us-east-1"
  region = "us-east-1"
  vpc_cidr = "172.16.0.0/16"
  subnet_cidr_d = "172.16.4.0/24"
  aws_vpc_id = module.us-east-1-common.aws_vpc
  aws_route_table_id = module.us-east-1-common.aws_route_table_id
  providers = {
    aws = aws
  }

}


