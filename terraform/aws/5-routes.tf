resource "aws_route_table" "llamacpp-private-rtb" {
  vpc_id = aws_vpc.llamacpp-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.llamacpp-nat-gateway.id
  }

  tags = {
    Name = "llamacpp-private-rtb"
  }
}

resource "aws_route_table" "llamacpp-public-rtb" {
  vpc_id = aws_vpc.llamacpp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.llamacpp-internet-gateway.id
  }

  tags = {
    Name = "llamacpp-public-rtb"
  }
}

resource "aws_route_table_association" "llamacpp-private-subnet-01" {
  subnet_id      = aws_subnet.llamacpp-private-subnet-01.id
  route_table_id = aws_route_table.llamacpp-private-rtb.id
}

resource "aws_route_table_association" "llamacpp-private-subnet-02" {
  subnet_id      = aws_subnet.llamacpp-private-subnet-02.id
  route_table_id = aws_route_table.llamacpp-private-rtb.id
}

resource "aws_route_table_association" "llamacpp-public-subnet-01" {
  subnet_id      = aws_subnet.llamacpp-public-subnet-01.id
  route_table_id = aws_route_table.llamacpp-public-rtb.id
}

resource "aws_route_table_association" "llamacpp-public-subnet-02" {
  subnet_id      = aws_subnet.llamacpp-public-subnet-02.id
  route_table_id = aws_route_table.llamacpp-public-rtb.id
}
