output "vpc1_id" {
  value = aws_vpc.vpc1.id
}

output "vpc2_id" {
  value = aws_vpc.vpc2.id
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.peer.id
}
