# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.terravpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
}

resource "aws_route_table_association" "public_association" {
  count          = length(var.vpc_az)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public.id
}
