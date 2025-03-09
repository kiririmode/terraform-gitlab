resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge({
    Name = format("%s public subnet", var.service_name)
  }, var.tags)
}

resource "aws_route_table" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = format("%s public route table on %s", var.service_name, var.availability_zones[count.index])
  }, var.tags)
}

resource "aws_route" "public" {
  count = length(var.public_subnets)

  route_table_id         = aws_route_table.public[count.index].id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = format("%s Internet Gateway", var.service_name)
    },
    var.tags
  )
}
