provider "aws" {
  profile = "techdebug"
  region = "ap-southeast-2"
}

module "vpc" {
  source  = "./modules/services/vpc"
}
