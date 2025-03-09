variable "service_name" {
  description = "Service name"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block to assign to the VPC"
  type        = string
}

variable "availability_zones" {
  description = "AZs to place the subnets in"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of CIDR blocks to assign to public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks to assign to private subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to the VPC and network resources"
  type        = map(string)
  default     = {}
}
