resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "my_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_subnet_1"
  }
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_subnet_2"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "my_internet_gateway"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_route_table"
  }
}

resource "aws_route_table_association" "my_route_table_ass_1" {
  subnet_id      = aws_subnet.my_subnet_1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "my_route_table_ass_2" {
  subnet_id      = aws_subnet.my_subnet_2.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow TLS inbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  ingress {
    description = "Allow HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key-${random_id.suffix.hex}"
  public_key = file(var.key_pair_public_key_path)
}

resource "aws_instance" "my_ec2_instance" {
  ami                         = "ami-0c02fb55956c7d316"  # Amazon Linux 2 (us-east-1)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  key_name                    = aws_key_pair.my_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "my_ec2_instance"
  }
}

resource "aws_instance" "my_ec2_instance_2" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  key_name                    = aws_key_pair.my_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "my_ec2_instance_2"
  }
}

resource "aws_lb" "test" {
  name               = "test-lb-tf-${random_id.suffix.hex}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]

  enable_deletion_protection = true



  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "alb_target" {
  name     = "tf-example-lb-alb-tg-${random_id.suffix.hex}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "alb_target_group"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "target_1" {
  target_group_arn = aws_lb_target_group.alb_target.arn
  target_id        = aws_instance.my_ec2_instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "target_2" {
  target_group_arn = aws_lb_target_group.alb_target.arn
  target_id        = aws_instance.my_ec2_instance_2.id
  port             = 80
}

