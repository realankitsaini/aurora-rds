provider "aws" {
  region = var.aws_region
}

# 1. Isolated VPC Networking
resource "aws_vpc" "rds_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-rds-vpc"
    Environment = var.environment
  }
}

# 2. Subnet in Availability Zone A
resource "aws_subnet" "subnet_az1" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.environment}-private-db-az1"
    Environment = var.environment
  }
}

# 3. Subnet in Availability Zone B (Aurora requires at least 2 AZs)
resource "aws_subnet" "subnet_az2" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.environment}-private-db-az2"
    Environment = var.environment
  }
}

# 4. Strict Security Group Layer
resource "aws_security_group" "aurora_sg" {
  name        = "${var.environment}-aurora-sg"
  description = "Controls ingress and egress connection rules to the Aurora cluster"
  vpc_id      = aws_vpc.rds_vpc.id

  # Ingress rule: Allow MySQL standard traffic (3306) internally within the VPC range
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.rds_vpc.cidr_block]
  }

  # Egress rule: Allow outgoing lookups or connections freely
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/32"]
  }

  tags = {
    Name        = "${var.environment}-aurora-security-group"
    Environment = var.environment
  }
}