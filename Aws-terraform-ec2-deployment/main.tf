

data "aws_ami" "amazon_linux_2" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

resource "aws_key_pair" "my_key" {
    key_name   = "my-key-${random_id.suffix_key.hex}"
    public_key = file(var.ssh_public_key_path)
}

resource "random_id" "suffix_key" {
  byte_length = 2
}





resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = { Name = "main-vpc" }        
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main_vpc.id
    tags = { Name = "main-igw" }
}

resource "aws_subnet" "public_subnet" {
    vpc_id                  =   aws_vpc.main_vpc.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "us-east-1a"
    tags = { Name = "public-subnet" }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}


resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = { Name = "public-route-table" }
}

resource "aws_route_table_association" "public_assoc" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
    domain   = "vpc"
    tags = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet.id
    tags = { Name = "nat-gateway" }
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main_vpc.id
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = { Name = "private-route-table" }
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "frontend_sg" {
    name   = "frontend-sg"
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        description = "SSH from trusted IP"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.ssh_cidr_block]
    }

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rds_sg" {
    name   = "rds-sg"
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [aws_security_group.frontend_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "random_id" "ec2_name_suffix" {
  byte_length = 2
  keepers = {
    # This ensures a new suffix if you want to control when it changes
    always_update = timestamp()
  }
}

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  key_name                    = aws_key_pair.my_key.key_name
  associate_public_ip_address = true
  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd php php-mysqlnd mysql
                systemctl start httpd
                systemctl enable httpd
                echo "<h1>Hello from your Apache server!</h1>" > /var/www/html/index.html
                EOF


  tags = {
    Name = "frontend-${random_id.ec2_name_suffix.hex}"
  }
}


   

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group-${random_id.suffix.hex}"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = { Name = "db-subnet-group" }
}

resource "random_id" "suffix" {
  byte_length = 2
}



resource "aws_db_instance" "mysql" {
    allocated_storage       = 20
    engine                  = "mysql"
    engine_version          = "8.0"
    instance_class          = "db.t3.micro"
    #name                   = "mydb"
    username                = "admin"
    password                = var.db_password
    db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
    vpc_security_group_ids  = [aws_security_group.rds_sg.id]
    publicly_accessible     = false
    skip_final_snapshot     = false
    deletion_protection     = false
    monitoring_interval     = 0
    enabled_cloudwatch_logs_exports = ["error", "general", "slowquery", "audit"]
}