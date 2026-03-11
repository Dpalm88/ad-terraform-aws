terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "ad_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name    = "ad-vpc"
    Project = "ad-terraform-aws"
  }
}

resource "aws_internet_gateway" "ad_igw" {
  vpc_id = aws_vpc.ad_vpc.id
  tags = {
    Name = "ad-igw"
  }
}

resource "aws_subnet" "ad_subnet" {
  vpc_id                  = aws_vpc.ad_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "ad-public-subnet"
  }
}

resource "aws_route_table" "ad_rt" {
  vpc_id = aws_vpc.ad_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ad_igw.id
  }
  tags = {
    Name = "ad-route-table"
  }
}

resource "aws_route_table_association" "ad_rta" {
  subnet_id      = aws_subnet.ad_subnet.id
  route_table_id = aws_route_table.ad_rt.id
}

resource "aws_security_group" "ad_sg" {
  name        = "ad-security-group"
  description = "Allow RDP inbound"
  vpc_id      = aws_vpc.ad_vpc.id
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ad-sg"
  }
}

data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "ad_server" {
  ami                    = data.aws_ami.windows_2022.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.ad_subnet.id
  vpc_security_group_ids = [aws_security_group.ad_sg.id]
  user_data              = base64encode(templatefile("userdata.ps1", {
    admin_password = var.admin_password
    domain_name    = var.domain_name
  }))
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
  tags = {
    Name    = "ad-domain-controller"
    Project = "ad-terraform-aws"
  }
}