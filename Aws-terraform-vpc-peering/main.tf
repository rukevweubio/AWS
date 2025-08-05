resource "aws_vpc" "vpc1" {
  provider             = aws.provider
  cidr_block           = var.vpc1_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_vpc" "vpc2" {
  provider             = aws.accepter
  cidr_block           = var.vpc2_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}


data "aws_caller_identity" "peer" {
  provider = aws.accepter
}
 resource "aws_vpc_peering_connection" "peer" {
    provider = aws.provider
   vpc_id = aws_vpc.vpc1.id
   peer_vpc_id = aws_vpc.vpc2.id
   peer_owner_id = data.aws_caller_identity.peer.account_id
   peer_region = "us-west-2"
   auto_accept   = false

  tags = {
    Name = "vpc1-to-vpc2"
    Side = "Requester"
  }

 }

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Name = "vpc2-to-vpc1"
    Side = "Accepter"
  }
}


resource "aws_vpc_peering_connection_options" "requester" {
  provider                  = aws.provider
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "route_vpc1_to_vpc2" {
  provider                  = aws.provider
  route_table_id            = aws_vpc.vpc1.default_route_table_id
  destination_cidr_block    = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "route_vpc2_to_vpc1" {
  provider                  = aws.accepter
  route_table_id            = aws_vpc.vpc2.default_route_table_id
  destination_cidr_block    = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}