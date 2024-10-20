variable "project" {
  description = "Project name"
  type = string
}

variable "candidate" {
  description = "Candidate name"
  type = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}
