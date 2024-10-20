variable "project" {
  description = "Project name"
  type        = string
}

variable "candidate" {
  description = "Candidate name"
  type        = string
}

variable "ami_owner" {
  description = "Owner ID of the AMI"
  type        = string
  default     = "679593333241" 
}

variable "instance_type" {
  description = "Instace type of EC2"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID"
  type = string
}

variable "sg_name" {
  description = "Security Group Name"
  type = string
}

variable "bastion_security_group_id" {
  description = "Bastion security group name"
  type = string
}

variable "bastion_subnet_id" {
  description = "Bastion subnet"
  type = string
}

variable "private_key_path" {
  description = "Private key path"
  type = string
  default = "~/.ssh/my_ec2_key"
}

variable "public_key_path" {
  description = "Public key path"
  type = string
  default = "~/.ssh/my_ec2_key.pub"
}