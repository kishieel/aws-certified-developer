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

resource "aws_s3_bucket" "lab2-s3-bucket" {
  bucket = "lab2-s3-bucket-f47a"
  tags   = {
    Name = "lab2-bucket"
  }
}

resource "aws_s3_object" "lab2-s3-index-object" {
  bucket       = aws_s3_bucket.lab2-s3-bucket.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "lab2-s3-error-object" {
  bucket       = aws_s3_bucket.lab2-s3-bucket.id
  key          = "error.html"
  source       = "${path.module}/error.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "lab2-s3-static-website" {
  bucket = aws_s3_bucket.lab2-s3-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "lab2-s3-block-public-access" {
  bucket                  = aws_s3_bucket.lab2-s3-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "lab2-s3-bucket-policy" {
  bucket = aws_s3_bucket.lab2-s3-bucket.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.lab2-s3-bucket.arn}/*"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.lab2-cloudfront-distribution.arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_control" "lab2-oac" {
  name                              = aws_s3_bucket.lab2-s3-bucket.bucket_regional_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "lab2-cloudfront-distribution" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.lab2-s3-bucket.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.lab2-oac.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "allow-all"

    min_ttl     = 0
    max_ttl     = 86400
    default_ttl = 3600

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

