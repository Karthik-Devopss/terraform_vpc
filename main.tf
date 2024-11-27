terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.65.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
resource "aws_vpc" "karthikvpc" {
  cidr_block       = "5.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "karthik_vpc-1"
  }
}
resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.karthikvpc.id
  cidr_block = "5.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "karthik-pubsub"
  }
}
resource "aws_subnet" "pvtsub" {
  vpc_id     = aws_vpc.karthikvpc.id
  cidr_block = "5.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "karthik-pvtsub"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.karthikvpc.id

  tags = {
    Name = "myigw"
  }
}
resource "aws_eip" "karthikeip" {
  
}
resource "aws_nat_gateway" "karthiknat" {
  allocation_id = aws_eip.karthikeip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "my-nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
}
resource "aws_route_table" "karthikrt" {
  vpc_id = aws_vpc.karthikvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "myroute"
  }
}
resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.karthikvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.karthiknat.id
  }

  tags = {
    Name = "mypvtrt"
  }
}
resource "aws_route_table_association" "pubsubrtassoc" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.karthikrt.id
}
resource "aws_route_table_association" "pvtsubrtassoc" {
  subnet_id      = aws_subnet.pvtsub.id
  route_table_id = aws_route_table.pvtrt.id
}