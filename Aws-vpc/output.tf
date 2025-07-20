output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_1_id" {
  description = "The ID of subnet 1"
  value       = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  description = "The ID of subnet 2"
  value       = aws_subnet.public_2.id
}

output "instance_1_public_ip" {
  description = "Public IP of web instance 1"
  value       = aws_instance.web_instance_1.public_ip
}

output "instance_2_public_ip" {
  description = "Public IP of web instance 2"
  value       = aws_instance.web_instance_2.public_ip
}
