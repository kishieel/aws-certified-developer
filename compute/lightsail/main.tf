terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.0"
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
      Branch  = "Compute/Lightsail"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_image_puller" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        aws_lightsail_container_service.default.private_registry_access[0].ecr_image_puller_role[0].principal_arn
      ]
    }

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
  }
}

resource "aws_ecr_repository" "default" {
  name         = "my-ecr-repository"
  force_delete = true
}

resource "aws_ecr_repository_policy" "default" {
  repository = aws_ecr_repository.default.name
  policy     = data.aws_iam_policy_document.ecr_image_puller.json
}

resource "null_resource" "build_and_push_containers" {
  provisioner "local-exec" {
    command     = "./build_and_push_containers.sh"
    environment = {
      AWS_REGION      = var.aws_region
      AWS_ACCOUNT_ID  = data.aws_caller_identity.current.account_id
      REPOSITORY_NAME = aws_ecr_repository.default.name
    }
    on_failure = fail
  }

  depends_on = [aws_ecr_repository.default]
}

resource "aws_lightsail_container_service" "default" {
  name  = "my-container-service"
  power = "micro"
  scale = "1"

  private_registry_access {
    ecr_image_puller_role {
      is_active = true
    }
  }
}

resource "aws_lightsail_container_service_deployment_version" "backend" {
  service_name = aws_lightsail_container_service.default.name

  container {
    container_name = "backend"
    image          = "${aws_ecr_repository.default.repository_url}:latest"
    environment    = {
      HOST = "0.0.0.0"
      PORT = "3000"
    }
    ports = {
      "3000" = "HTTP"
    }
  }

  public_endpoint {
    container_name = "backend"
    container_port = 3000
    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/api"
    }
  }

  depends_on = [null_resource.build_and_push_containers]
}

# [x] lightsail containers (auto scaling if possible)
# lightsail storage
# lightsail database
# lightsail load balancer
# lightsail networking
# lightsail cdn
