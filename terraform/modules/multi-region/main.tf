#/modules/multi-region/main.tf

variable "region" {}
variable "vpc_cidr" {}
variable "subnet_cidr_a" {}
variable "subnet_cidr_b" {}
variable "subnet_cidr_c" {}
variable "ami" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
}
resource "aws_subnet" "subnet_a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_a
  availability_zone = "${var.region}a"
}
resource "aws_subnet" "subnet_b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_b
  availability_zone = "${var.region}b"
}
resource "aws_subnet" "subnet_c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_c
  availability_zone = "${var.region}c"
}
resource "aws_route_table" "subnet_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table_association" "subnet_a_route_table_association" {
  subnet_id = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.subnet_route_table.id
}

resource "aws_route_table_association" "subnet_b_route_table_association" {
  subnet_id = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.subnet_route_table.id
}

resource "aws_route_table_association" "subnet_c_route_table_association" {
  subnet_id = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.subnet_route_table.id
}

resource "aws_instance" "instance" {
  ami = var.ami
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id = aws_subnet.subnet_a.id
  associate_public_ip_address = true
  user_data = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF
}

resource "aws_instance" "instance2" {
  ami = var.ami
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id = aws_subnet.subnet_b.id
  associate_public_ip_address = true
  user_data = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF
}


resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_elb" "elb" {
  name               = "${var.region}-elb"
  subnets = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = [aws_instance.instance.id, aws_instance.instance2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "${var.region}-elb"
  }

  security_groups = [aws_security_group.security_group.id]
}
