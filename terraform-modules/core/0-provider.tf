terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = "= 1.4.5"

  backend "s3" {
    bucket = "atlan-ojas-bucket"
    key    = "atlan-infra.tfstate"
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
  desired_tf_workspace          = "core"
  assert_not_required_workspace = terraform.workspace != local.desired_tf_workspace ? file("ERROR: Are you sure in the proper workspace ${local.desired_tf_workspace}") : null
  common_tags = {
    project = "atlan"
  }
}


