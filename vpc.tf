resource "aws_vpc" "terravpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terravpc"
  }
}