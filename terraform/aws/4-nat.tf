resource "aws_eip" "llamacpp-nat-gateway" {
  tags = {
    Name = "llamacpp-nat-gateway"
  }
}

resource "aws_nat_gateway" "llamacpp-nat-gateway" {
  allocation_id = aws_eip.llamacpp-nat-gateway.id
  subnet_id     = aws_subnet.llamacpp-public-subnet-01.id

  tags = {
    Name = "llamacpp-nat-gateway"
  }

  depends_on = [aws_internet_gateway.llamacpp-internet-gateway]
}
