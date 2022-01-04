provider "aws" {
  region = "us-west-2"
}

# Check available Availabilty Zones

data "aws_availability_zones" "available" {}

# VPC Creation

resource "aws_vpc" "my-vpc" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {

    Name = "my-vpc-us-west-dev"
  }

}

# Creating Internet Gateway

resource "aws_internet_gateway" "my-igw" {

  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-igw-us-west-dev"
  }
}

# Public Routing Table

resource "aws_route_table" "my-public-route" {

  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id

  }

  tags = {

    Name = "my-private-route-table"
  }
}

# Private Routing Table

resource "aws_default_route_table" "my-private-route" {

  default_route_table_id = aws_vpc.my-vpc.default_route_table_id

  tags = {
    Name = "my-private-route-table"
  }

}

# Public Subnet

resource "aws_subnet" "public_subnet" {

  count                   = 2
  cidr_block              = var.public_cidrs[count.index]
  vpc_id                  = aws_vpc.my-vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "my-public-subnet.${count.index + 1}"
  }
}

# Private Subnet

resource "aws_subnet" "private_subnet" {
  count             = 2
  cidr_block        = var.private_cidrs[count.index]
  vpc_id            = aws_vpc.my-vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {

    Name = "my-private-subnet.${count.index + 1}"
  }

}

# Associate Public Subnet with Public Route Table

resource "aws_route_table_association" "public-subnet-association" {
  count          = 2
  route_table_id = aws_route_table.my-public-route.id
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  depends_on     = [aws_route_table.my-public-route, aws_subnet.public_subnet]

}

# Associate Private Subnet with Private Route Table

resource "aws_route_table_association" "private-subnet-association" {

  count          = 2
  route_table_id = aws_default_route_table.my-private-route.id
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  depends_on     = [aws_default_route_table.my-private-route, aws_subnet.private_subnet]

}

# Security Group Creation Ingress/egress

resource "aws_security_group" "my-sg" {
  vpc_id = aws_vpc.my-vpc.id
  name   = join("", ["my-sg", "1"])
  dynamic "ingress" {
    for_each = var.ingress-rules
    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "My-Security-Group"
  }
}



