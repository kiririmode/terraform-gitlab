variable "vpc_id" {
  description = "VPC ID where GitLab will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where GitLab EC2 instance will be deployed"
  type        = string
}

variable "admin_cidr_blocks" {
  description = "CIDR block for SSH access to GitLab server"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for EBS volume"
  type        = string
  default = "ap-northeast-1a"
}

variable "ebs_volume_size" {
  description = "Size of GitLab data EBS volume in GB"
  type        = number
  default     = 100
}

variable "root_volume_size" {
  description = "Size of root EBS volume in GB"
  type        = number
  default     = 20
}

variable "instance_type" {
  description = "EC2 instance type for GitLab server"
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "Name of SSH key pair for GitLab instance"
  type        = string
}

variable "domain_name" {
  description = "Domain name for GitLab server"
  type        = string
}
