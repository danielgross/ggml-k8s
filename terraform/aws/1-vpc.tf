resource "aws_vpc" "llamacpp-vpc" {
  cidr_block = "10.0.0.0/16"

  # Must be enabled for EFS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "llamacpp-vpc"
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value      = aws_vpc.llamacpp-vpc.id
}