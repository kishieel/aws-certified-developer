terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region

  default_tags {
    tags = {
      Project = "AWS Certified Developer"
      Branch  = "Compute/EC2"
    }
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_security_group" "default" {
  name   = "DefaultSecurityGroup"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin_cidr_blocks
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
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.default.id
}

resource "aws_instance" "on_demand" {
  ami                         = data.aws_ami.amazon_linux_2.image_id
  instance_type               = var.aws_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.default.id]
  subnet_id                   = aws_subnet.public.id

  user_data_base64 = base64encode(
    <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Welcome to AWS Certified Developer - Compute/EC2</h1>" > /var/www/html/index.html
    echo "<h2>On-Demand Instance</h2>" >> /var/www/html/index.html
    EOF
  )
}

resource "aws_instance" "spot" {
  ami                         = data.aws_ami.amazon_linux_2.image_id
  instance_type               = var.aws_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.default.id]
  subnet_id                   = aws_subnet.public.id

  instance_market_options {
    market_type = "spot"

    spot_options {
      max_price          = "0.03"
      spot_instance_type = "persistent"
      instance_interruption_behavior = "stop"
    }
  }

  user_data_base64 = base64encode(
    <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Welcome to AWS Certified Developer - Compute/EC2</h1>" > /var/www/html/index.html
    echo "<h2>Spot Instance</h2>" >> /var/www/html/index.html
    EOF
  )
}

resource "aws_eip" "default" {
  instance = aws_instance.on_demand.id
}
