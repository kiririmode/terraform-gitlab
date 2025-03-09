terraform {
  backend "s3" {
    bucket = "kiririmode-tfbackend"
    key    = "vpc.tfstate"
    region = "ap-northeast-1"
  }
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.82, < 6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn = "arn:aws:iam::629415618746:role/TerraformExecutionRole"
  }
  default_tags {
    tags = {
      Service = "GitLab"
    }
  }
}

locals {
  domain_name        = "kiririmo.de"
  availability_zones = ["ap-northeast-1a"]
}

data "aws_route53_zone" "domain" {
  name = local.domain_name
}

module "vpc" {
  source = "../../modules/vpc"

  service_name = "GitLab"

  availability_zones = local.availability_zones
  cidr_block         = "10.251.0.0/16"
  public_subnets     = ["10.251.1.0/24"]
  private_subnets    = ["10.251.2.0/24"]

  tags = {
    Environment = "dev"
  }
}
