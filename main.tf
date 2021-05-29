provider "aws" {
  profile = "techdebug"
  region = "ap-southeast-2"
}

module "ec2" {
  source  = "./modules/services/ec2"
}