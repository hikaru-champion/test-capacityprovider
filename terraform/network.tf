##################################
# VPC Configure
##################################
resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "test_vpc"
  }
}

##################################
# Internet Gateway Configure
##################################
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test_igw"
  }
}

##################################
# NatGateway Configure
##################################
resource "aws_eip" "test_eip_natgateway_1a" {
  vpc = true
  tags = {
    Name = "test_eip_natgateway_1a"
  }
}

resource "aws_nat_gateway" "test_natgateway_1a" {
  allocation_id = aws_eip.test_eip_natgateway_1a.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name = "test_natgateway_1a"
  }

  depends_on = [aws_internet_gateway.test_igw]
}

resource "aws_eip" "test_eip_natgateway_1c" {
  vpc = true
  tags = {
    Name = "test_eip_natgateway_1c"
  }
}

resource "aws_nat_gateway" "test_natgateway_1c" {
  allocation_id = aws_eip.test_eip_natgateway_1c.id
  subnet_id     = aws_subnet.public_subnet_1c.id

  tags = {
    Name = "test_natgateway_1c"
  }

  depends_on = [aws_internet_gateway.test_igw]
}

##################################
# Subnet Configure
##################################
resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "test_public_subnet_1a"
  }
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "test_public_subnet_1c"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "test_private_subnet_1a"
  }
}

resource "aws_subnet" "private_subnet_1c" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "test_private_subnet_1c"
  }
}


##################################
# RouteTable Confiture
##################################
resource "aws_route_table" "public_subnet_routetable" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }

  tags = {
    Name = "test_public_subnet_routetable"
  }
}

resource "aws_route_table" "private_subnet_routetable_1a" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.test_natgateway_1a.id
  }

  tags = {
    Name = "test_private_subnet_routetable_1a"
  }
}

resource "aws_route_table" "private_subnet_routetable_1c" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.test_natgateway_1c.id
  }

  tags = {
    Name = "test_private_subnet_routetable_1c"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_subnet_routetable.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_subnet_1c.id
  route_table_id = aws_route_table.public_subnet_routetable.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_subnet_routetable_1a.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_subnet_1c.id
  route_table_id = aws_route_table.private_subnet_routetable_1c.id
}