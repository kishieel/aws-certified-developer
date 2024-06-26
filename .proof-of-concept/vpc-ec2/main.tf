terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "lab1-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "lab1-vpc"
  }
}

resource "aws_subnet" "lab1-public-1a" {
  vpc_id                  = aws_vpc.lab1-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "lab1-public-1a"
  }
}


resource "aws_subnet" "lab1-public-1b" {
  vpc_id                  = aws_vpc.lab1-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "lab1-public-1b"
  }
}


resource "aws_subnet" "lab1-private-1a" {
  vpc_id            = aws_vpc.lab1-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "lab1-private-1a"
  }
}


resource "aws_subnet" "lab1-private-1b" {
  vpc_id            = aws_vpc.lab1-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "lab1-private-1b"
  }
}

resource "aws_internet_gateway" "lab1-internet-gateway" {
  vpc_id = aws_vpc.lab1-vpc.id
  tags = {
    Name = "lab1-internet-gateway"
  }
}

resource "aws_route_table" "lab1-route-table-public" {
  vpc_id = aws_vpc.lab1-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab1-internet-gateway.id
  }

  tags = {
    Name = "lab1-route-table-public"
  }
}

resource "aws_route_table_association" "lab1-route-table-public-1a" {
  route_table_id = aws_route_table.lab1-route-table-public.id
  subnet_id      = aws_subnet.lab1-public-1a.id
}

resource "aws_route_table_association" "lab1-route-table-public-1b" {
  route_table_id = aws_route_table.lab1-route-table-public.id
  subnet_id      = aws_subnet.lab1-public-1b.id
}

resource "aws_security_group" "lab1-http-access" {
  vpc_id = aws_vpc.lab1-vpc.id

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

  tags = {
    Name = "lab1-http-access"
  }
}

resource "aws_security_group" "lab1-ssh-access" {
  vpc_id = aws_vpc.lab1-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "lab1-ssh-access"
  }
}

resource "aws_key_pair" "lab1-key-pair" {
  key_name   = "lab1-key"
  public_key = file("${path.module}/.secrets/id_rsa.pub")
  tags = {
    Name = "lab1-key-pair"
  }
}

resource "aws_launch_configuration" "lab1-lunch-configuration" {
  name          = "lab1-lunch-configuration"
  image_id      = "ami-02da8ff11275b7907"
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.lab1-http-access.id,
    aws_security_group.lab1-ssh-access.id
  ]
  key_name  = aws_key_pair.lab1-key-pair.key_name
  user_data = file("${path.module}/setup.sh")
}

resource "aws_alb_target_group" "lab1-target-group" {
  name        = "lab1-target-group"
  target_type = "instance"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = aws_vpc.lab1-vpc.id
}

resource "aws_autoscaling_group" "lab1-autoscaling-group" {
  name                      = "lab1-autoscaling-group"
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.lab1-public-1a.id, aws_subnet.lab1-public-1b.id]
  launch_configuration      = aws_launch_configuration.lab1-lunch-configuration.id
  health_check_type         = "EC2"
  health_check_grace_period = 300
  wait_for_capacity_timeout = 0
  target_group_arns         = [aws_alb_target_group.lab1-target-group.arn]
}

resource "aws_alb" "lab1-load-balancer" {
  name               = "lab1-load-balancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lab1-http-access.id]
  subnets            = [aws_subnet.lab1-public-1a.id, aws_subnet.lab1-public-1b.id]
}

resource "aws_alb_listener" "lab1-load-balancer-listener" {
  load_balancer_arn = aws_alb.lab1-load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.lab1-target-group.arn
  }
}
