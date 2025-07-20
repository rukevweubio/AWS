variable "aws_region" {
  description = "AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_block_subnet_1" {
  description = "The CIDR block for subnet 1"
  default     = "10.0.1.0/24"
}

variable "vpc_cidr_block_subnet_2" {
  description = "The CIDR block for subnet 2"
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair to use for EC2 instances"
  default     = "my-key"
}

variable "public_key_path" {
  description = "Local path to your public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}
