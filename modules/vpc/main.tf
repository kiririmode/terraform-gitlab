resource "aws_vpc" "this" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  enable_dns_support                   = true
  enable_network_address_usage_metrics = true
  enable_dns_hostnames                 = true

  tags = merge({
    Name = format("%s VPC", var.service_name)
  }, var.tags)
}
