# Root Terragrunt configuration for live infrastructure
# This file contains common settings shared across all environments

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "etamarw-terraform-state-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks-${local.aws_region}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Define common locals that can be used across all configurations
locals {
  # Parse the file path to determine environment and region
  # Expected path: live/{environment}/{region}/{service}/
  parsed_path = regex(".*/live/(?P<environment>[^/]+)/(?P<region>[^/]+)/(?P<service>[^/]+)/?", get_terragrunt_dir())
  environment = local.parsed_path.environment
  region      = local.parsed_path.region
  service     = local.parsed_path.service
  aws_region  = local.region

  # Common tags applied to all resources
  common_tags = {
    Terraform   = "true"
    Environment = local.environment
    Region      = local.region
    Service     = local.service
    Project     = "tg-live-demo"
    ManagedBy   = "terragrunt"
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = var.common_tags
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
EOF
}

# Configure root level variables that all resources can inherit
inputs = {
  aws_region  = local.aws_region
  common_tags = local.common_tags
}