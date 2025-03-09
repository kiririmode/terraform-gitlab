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

module "gitlab" {
  source = "../../modules/gitlab"

  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.private_subnet_ids[0]
  availability_zone = local.availability_zones[0]
  admin_cidr_blocks = "0.0.0.0/0" # 本番環境では適切なCIDRブロックに制限すべき
  environment       = "dev"
  domain_name       = "gitlab.${local.domain_name}"

  instance_type = "t3.large"
  key_name      = "gitlab-key" # 既存のキーペア名を指定

  ebs_volume_size  = 100
  root_volume_size = 20
}
