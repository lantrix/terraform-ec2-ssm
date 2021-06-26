terraform {
  backend "s3" {
    workspace_key_prefix = "ec2-ssm"
  }
}

provider "aws" {
  profile = "techdebug"
  region = "ap-southeast-2"
}

module "ec2" {
  source  = "./modules/services/ec2"
  region  = var.region
}