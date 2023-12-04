resource "aws_internet_gateway" "llamacpp-internet-gateway" {
  vpc_id = aws_vpc.llamacpp-vpc.id

  tags = {
    Name = "llamacpp-internet-gateway"
  }
}
