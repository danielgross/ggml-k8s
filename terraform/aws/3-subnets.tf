resource "aws_subnet" "llamacpp-private-subnet-01" {
  vpc_id            = aws_vpc.llamacpp-vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "${var.aws_region}a"

  tags = {
    "Name"                                      = "llamacpp-private-subnet-01"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Project"                                   = "llamacpp"
  }
}

resource "aws_subnet" "llamacpp-private-subnet-02" {
  vpc_id            = aws_vpc.llamacpp-vpc.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "${var.aws_region}b"

  tags = {
    "Name"                                      = "llamacpp-private-subnet-02"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Project"                                   = "llamacpp"
  }
}

resource "aws_subnet" "llamacpp-public-subnet-01" {
  vpc_id                  = aws_vpc.llamacpp-vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "llamacpp-public-subnet-01"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Project"                                   = "llamacpp"
  }
}

resource "aws_subnet" "llamacpp-public-subnet-02" {
  vpc_id                  = aws_vpc.llamacpp-vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "llamacpp-public-subnet-02"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Project"                                   = "llamacpp"
  }
}
