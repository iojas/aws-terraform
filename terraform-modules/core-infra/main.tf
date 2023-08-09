terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = "= 1.4.5"

    backend "s3" {
      bucket = "atlan-ojas-bucket"
      key = "atlan-infra.tfstate"
      region = "us-east-1"
    }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.11.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

locals {
  desired_tf_workspace = "core-infra"
  assert_not_required_workspace = terraform.workspace != local.desired_tf_workspace ? file("ERROR: Are you sure in the proper workspace ${local.desired_tf_workspace}") : null
}


resource "aws_s3_bucket" "state_bucket" {
  bucket = "atlan-ojas-bucket"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}