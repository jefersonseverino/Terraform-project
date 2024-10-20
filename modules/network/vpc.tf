// Criação da VPC (Virutal Private Network) na AWS
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-${var.candidate}-vpc"
  }
}

// Criação da subrede pública que vai contar a instância bastion
resource "aws_subnet" "bastion_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Public"
  }
}

// Criação da subrede privada que vai conter a instância debian
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-${var.candidate}-subnet"
  }
}