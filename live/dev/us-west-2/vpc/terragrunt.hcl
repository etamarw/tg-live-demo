# Include all settings from the root terragrunt.hcl file
include "root" {
  path = find_in_parent_folders()
}

# Reference the VPC module from the modules repository
terraform {
  source = "git::https://github.com/etamarw/tg-modules-demo.git//modules/vpc?ref=v1.1.0"
}

# Specify the inputs for the VPC module
inputs = {
  name = "dev-vpc"
  cidr = "10.0.0.0/16"
  
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = false
  
  tags = merge(
    var.common_tags,
    {
      Name = "dev-vpc"
      Tier = "network"
    }
  )
}