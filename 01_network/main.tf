terraform {
  required_version = "0.12.24"

  backend "s3" {
    bucket = "orezybsk-terraform-backend"
    key    = "aws-ecs-cicd-practice/terraform.tfstate"
    region = "ap-northeast-1"

    dynamodb_table = "orezybsk-terraform-backend-lock"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

///////////////////////////////////////////////////////////////////////////////
// VPC
//
resource "aws_vpc" "cnapp-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "cnapp-vpc"
  }
}

///////////////////////////////////////////////////////////////////////////////
// Internet Gateway
//
resource "aws_internet_gateway" "cnapp-igw" {
  vpc_id = aws_vpc.cnapp-vpc.id

  tags = {
    Name = "cnapp-igw"
  }
}

///////////////////////////////////////////////////////////////////////////////
// Route Table
//
resource "aws_route_table" "cnapp-route-internet" {
  vpc_id = aws_vpc.cnapp-vpc.id
}
resource "aws_route" "public-subnet-to-igw" {
  route_table_id         = aws_route_table.cnapp-route-internet.id
  gateway_id             = aws_internet_gateway.cnapp-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

///////////////////////////////////////////////////////////////////////////////
// Subnet (Ingress用)
//
resource "aws_subnet" "cnapp-subnet-public-ingress-1b" {
  vpc_id            = aws_vpc.cnapp-vpc.id
  availability_zone = "ap-northeast-1b"
  cidr_block        = "10.0.0.0/24"

  tags = {
    Name = "cnapp-subnet-public-ingress-1b"
  }
}
resource "aws_route_table_association" "cnapp-subnet-public-ingress-1b" {
  subnet_id      = aws_subnet.cnapp-subnet-public-ingress-1b.id
  route_table_id = aws_route_table.cnapp-route-internet.id
}
resource "aws_subnet" "cnapp-subnet-public-ingress-1c" {
  vpc_id            = aws_vpc.cnapp-vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "cnapp-subnet-public-ingress-1c"
  }
}
resource "aws_route_table_association" "cnapp-subnet-public-ingress-1c" {
  subnet_id      = aws_subnet.cnapp-subnet-public-ingress-1c.id
  route_table_id = aws_route_table.cnapp-route-internet.id
}

///////////////////////////////////////////////////////////////////////////////
// Subnet (コンテナ用)
//
resource "aws_subnet" "cnapp-subnet-private-container-1b" {
  vpc_id            = aws_vpc.cnapp-vpc.id
  availability_zone = "ap-northeast-1b"
  cidr_block        = "10.0.8.0/24"

  tags = {
    Name = "cnapp-subnet-private-container-1b"
  }
}
resource "aws_subnet" "cnapp-subnet-private-container-1c" {
  vpc_id            = aws_vpc.cnapp-vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.9.0/24"

  tags = {
    Name = "cnapp-subnet-private-container-1c"
  }
}

///////////////////////////////////////////////////////////////////////////////
// Subnet (DB用)
//
resource "aws_subnet" "cnapp-subnet-private-db-1b" {
  vpc_id            = aws_vpc.cnapp-vpc.id
  availability_zone = "ap-northeast-1b"
  cidr_block        = "10.0.16.0/24"

  tags = {
    Name = "cnapp-subnet-private-db-1b"
  }
}
resource "aws_subnet" "cnapp-subnet-private-db-1c" {
  vpc_id            = aws_vpc.cnapp-vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.17.0/24"

  tags = {
    Name = "cnapp-subnet-private-db-1c"
  }
}

///////////////////////////////////////////////////////////////////////////////
// Subnet (管理用)
//
resource "aws_subnet" "cnapp-subnet-public-management-1b" {
  vpc_id            = aws_vpc.cnapp-vpc.id
  availability_zone = "ap-northeast-1b"
  cidr_block        = "10.0.240.0/24"

  tags = {
    Name = "cnapp-subnet-public-management-1b"
  }
}
resource "aws_route_table_association" "cnapp-subnet-public-management-1b" {
  subnet_id      = aws_subnet.cnapp-subnet-public-management-1b.id
  route_table_id = aws_route_table.cnapp-route-internet.id
}
resource "aws_subnet" "cnapp-subnet-public-management-1c" {
  vpc_id            = aws_vpc.cnapp-vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.241.0/24"

  tags = {
    Name = "cnapp-subnet-public-management-1c"
  }
}
resource "aws_route_table_association" "cnapp-subnet-public-management-1c" {
  subnet_id      = aws_subnet.cnapp-subnet-public-management-1c.id
  route_table_id = aws_route_table.cnapp-route-internet.id
}
