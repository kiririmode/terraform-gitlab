resource "aws_eip" "nat_gateway" {
  count = length(var.public_subnets)

  domain = "vpc"

  tags = merge({
    "Name" = format("%s EIP for NAT Gateway %d", var.service_name, count.index + 1)
  }, var.tags)
}

resource "aws_nat_gateway" "natgw" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge({
    "Name" = format("%s NAT Gateway %d", var.service_name, count.index + 1)
  }, var.tags)
}

resource "aws_route" "private" {
  count = length(var.public_subnets)

  destination_cidr_block = "0.0.0.0/0"

  route_table_id = element(aws_route_table.private.*.id, count.index)
  nat_gateway_id = element(aws_nat_gateway.natgw.*.id, count.index)
}
