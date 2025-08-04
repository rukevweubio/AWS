
output "frontend_instance_id" {
    description = "The ID of the frontend EC2 instance."
    value       = aws_instance.frontend.id
}

output "rds_instance_id" {
    description = "The ID of the RDS database instance."
    value       = aws_db_instance.mysql.id
}

output "rds_endpoint" {
  description = "The endpoint of the RDS database instance."
  value       = aws_db_instance.mysql.endpoint
}


output "public_ip" {
  description = "Public IP of the frontend EC2 instance"
  value       = aws_instance.frontend.public_ip
}