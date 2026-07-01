provider "aws" {
  region = var.aws_region
}

# 1. Isolated VPC Networking
resource "aws_vpc" "rds_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${terraform.workspace}-rds-vpc" 
    
    Environment = lookup(var.environment_names, terraform.workspace, "development")
  }
}

# 2. Subnet in Availability Zone A
resource "aws_subnet" "subnet_az1" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${terraform.workspace}-private-db-az1"
    Environment = lookup(var.environment_names, terraform.workspace, "development")
  }
}

# 3. Subnet in Availability Zone B (Aurora requires at least 2 AZs)
resource "aws_subnet" "subnet_az2" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${terraform.workspace}-private-db-az2"
    Environment = lookup(var.environment_names, terraform.workspace, "development")
  }
}

# 4. Strictly-Scoped Security Group Layer
resource "aws_security_group" "aurora_sg" {
  name        = "${terraform.workspace}-aurora-sg"
  description = "Controls connection rules to the Aurora cluster"
  vpc_id      = aws_vpc.rds_vpc.id

  # Ingress rule: Allow MySQL traffic (3306) internally within the VPC range
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.rds_vpc.cidr_block]
  }

  # Egress rule: Allow outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${terraform.workspace}-aurora-security-group"
    Environment = lookup(var.environment_names, terraform.workspace, "development")
  }
}