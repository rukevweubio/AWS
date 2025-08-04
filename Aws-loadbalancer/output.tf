output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main_vpc.id
}

output "subnet_1_id" {
  description = "ID of subnet 1"
  value       = aws_subnet.my_subnet_1.id
}

output "subnet_2_id" {
  description = "ID of subnet 2"
  value       = aws_subnet.my_subnet_2.id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the first EC2 instance"
  value       = aws_instance.my_ec2_instance.public_ip
}

output "ec2_instance_2_public_ip" {
  description = "Public IP of the second EC2 instance"
  value       = aws_instance.my_ec2_instance_2.public_ip
}

output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.test.dns_name
}
