output "aws_vpc" {
  value = aws_vpc.vpc.id
}

output "aws_route_table_id" {
  value = aws_route_table.subnet_route_table.id
}

output "elb" {
  value = aws_elb.elb.dns_name
}

output "nginx_domain" {
  value = aws_instance.instance.public_dns
}

