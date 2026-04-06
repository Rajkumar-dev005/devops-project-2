terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-2"
}

resource "aws_vpc" "project2_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "project2-vpc" }
}

resource "aws_internet_gateway" "project2_igw" {
  vpc_id = aws_vpc.project2_vpc.id
  tags = { Name = "project2-igw" }
}

resource "aws_subnet" "project2_public_subnet" {
  vpc_id                  = aws_vpc.project2_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-2a"
  map_public_ip_on_launch = true
  tags = { Name = "project2-public-subnet" }
}

resource "aws_route_table" "project2_rt" {
  vpc_id = aws_vpc.project2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project2_igw.id
  }
  tags = { Name = "project2-rt" }
}

resource "aws_route_table_association" "project2_rta" {
  subnet_id      = aws_subnet.project2_public_subnet.id
  route_table_id = aws_route_table.project2_rt.id
}

resource "aws_security_group" "project2_sg" {
  name        = "project2-jenkins-sg"
  description = "Security group for Jenkins EC2"
  vpc_id      = aws_vpc.project2_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "project2-jenkins-sg" }
}

resource "aws_iam_role" "project2_ec2_role" {
  name = "project2-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = { Name = "project2-ec2-role" }
}

resource "aws_iam_role_policy_attachment" "project2_ec2_policy" {
  role       = aws_iam_role.project2_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "project2_instance_profile" {
  name = "project2-instance-profile"
  role = aws_iam_role.project2_ec2_role.name
}

resource "aws_instance" "project2_jenkins" {
  ami                    = "ami-0b30b8602b39379e7"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.project2_public_subnet.id
  vpc_security_group_ids = [aws_security_group.project2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.project2_instance_profile.name
  tags = { Name = "project2-jenkins" }
}

output "jenkins_public_ip" {
  value       = aws_instance.project2_jenkins.public_ip
  description = "Public IP of Jenkins EC2"
}

output "vpc_id" {
  value       = aws_vpc.project2_vpc.id
  description = "VPC ID"
}
