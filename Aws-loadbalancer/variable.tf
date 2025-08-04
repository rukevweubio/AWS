variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "CIDR block for subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_2_cidr" {
  description = "CIDR block for subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "key_pair_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
  default     = "~/.ssh/my_aws_key.pub"
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN for HTTPS listener"
  type        = string
  default     = ""  # you should override this during deployment or in tfvars file
}
