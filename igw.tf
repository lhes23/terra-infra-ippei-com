resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terravpc.id
}