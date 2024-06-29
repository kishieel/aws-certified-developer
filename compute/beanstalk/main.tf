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
      Branch  = "Compute/Beanstalk"
    }
  }
}

resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
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

data "aws_elastic_beanstalk_solution_stack" "nodejs" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux 2023 (.*) Node.js 20$"
}

resource "aws_elastic_beanstalk_application" "default" {
  name = "Express"
}

resource "aws_iam_instance_profile" "beanstalk" {
  name = "AWSElasticBeanstalkServiceRole"
  role = "AWSElasticBeanstalkServiceRole"
}

resource "aws_elastic_beanstalk_environment" "default" {
  application         = aws_elastic_beanstalk_application.default.name
  name                = "ExpressEnvironment"
  tier                = "WebServer"
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.nodejs.name
  cname_prefix        = "express-z010lb"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORT"
    value     = 3000
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "HOST"
    value     = "0.0.0.0"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.default.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = aws_subnet.public.id
  }
}

data "archive_file" "app_v1_0_0" {
  type        = "zip"
  source_dir  = "app"
  output_path = "app-v1.0.0.zip"
  excludes    = [
    ".git",
    ".gitignore",
    ".vscode",
    ".idea",
    ".env",
    ".env.example",
    "node_modules",
    "src",
    "tsconfig.json",
  ]
}

resource "aws_s3_bucket" "default" {
  bucket = "express-z010lb"
}

resource "aws_s3_object" "app_v1_0_0" {
  bucket = aws_s3_bucket.default.bucket
  key    = "app-v1.0.0.zip"
  source = "app-v1.0.0.zip"
}

resource "aws_elastic_beanstalk_application_version" "default" {
  application = aws_elastic_beanstalk_application.default.name
  bucket      = aws_s3_bucket.default.bucket
  key         = aws_s3_object.app_v1_0_0.key
  name        = "v1.0.0"

  depends_on = [aws_s3_object.app_v1_0_0]
}
