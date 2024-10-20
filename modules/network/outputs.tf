output "main_subnet_id" {
  description = "Main subnet ID"
  value       = aws_subnet.main_subnet.id
}

output "main_security_group_id" {
  description = "ID of the private security group with the Nginx instance"
  value       = aws_security_group.main_sg.id
}

output "main_security_group_name" {
  description = "Name of the provate security group"
  value       = aws_security_group.main_sg.name
}

output "bastion_security_group_id" {
  description = "Bastion security group name"
  value = aws_security_group.bastion_allow_ssh.id
}

output "bastion_subnet_id" {
  description = "Bastion public subnet ID"
  value = aws_subnet.bastion_subnet.id
}