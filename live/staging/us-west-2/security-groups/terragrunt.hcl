# Include all settings from the root terragrunt.hcl file
include "root" {
  path = find_in_parent_folders()
}

# Reference the security-groups module from the modules repository
terraform {
  source = "git::https://github.com/etamarw/tg-modules-demo.git//modules/security-groups?ref=v1.0.0"
}

# Create explicit dependency on VPC
dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    vpc_id = "vpc-00000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

# Specify the inputs for the security-groups module
inputs = {
  name_prefix = "staging"
  vpc_id      = dependency.vpc.outputs.vpc_id
  
  web_ingress_cidr_blocks = ["10.0.0.0/8"]  # More restrictive for staging
  
  tags = merge(
    var.common_tags,
    {
      Name = "staging-security-groups"
      Tier = "security"
    }
  )
}