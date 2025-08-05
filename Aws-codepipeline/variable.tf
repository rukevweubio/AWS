variable "region" {
    default = "us-east-1"
  
}

variable "cluster_name" {
  
  default="my_cluster_eks"
}

variable "node_group_name" {
  
  default="my_group_cluster_eks"
}


variable "desired_capacity" {
  
  default=2
}

variable "max_size" {
  
  default=2
}

variable "min_size" {
  
  default=1
}


variable "instance_type" {
  default = "t3.medium"
}