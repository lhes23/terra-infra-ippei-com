resource "aws_subnet" "public_subnet" {
  count                   = length(var.vpc_az)
  vpc_id                  = aws_vpc.terravpc.id
  cidr_block              = cidrsubnet(aws_vpc.terravpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.vpc_az, count.index)
}