output "ec2_public_ip" {
  description = "Public IP address for EC2"
  value       = aws_instance.debian_ec2.public_ip
}