#/modules/us-east-1/main.tf

variable "region" {}
variable "vpc_cidr" {}
variable "subnet_cidr_d" {}
variable "aws_vpc_id" {}
variable "aws_route_table_id" {}

resource "aws_subnet" "subnet_d" {
  vpc_id = var.aws_vpc_id
  cidr_block = var.subnet_cidr_d
  availability_zone = "${var.region}d"
}
resource "aws_route_table_association" "subnet_d_route_table_association" {
  subnet_id = aws_subnet.subnet_d.id
  route_table_id = var.aws_route_table_id
}

# Copy AMI since it doesn't exist in us-east-1
resource "aws_ami_copy" "ami_us-east-1" {
  name              = "copy of ami-cdbfa4ab from eu-west-1"
  description       = "A copy of ami-cdbfa4ab from eu-west-1"
  source_ami_id     = "ami-cdbfa4ab"
  source_ami_region = "eu-west-1"

  tags = {
    Name = "copy of ami-cdbfa4ab from eu-west-1"
  }
}

