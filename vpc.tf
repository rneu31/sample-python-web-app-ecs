resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"   
  enable_dns_hostnames = true

  tags = {
    Name = "dots-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dots-igw"
  }
}

resource "aws_subnet" "dots_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dots-subnet-1"
  }
}

resource "aws_route_table" "public_1a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "dots_1a" {
  subnet_id      = aws_subnet.dots_1a.id
  route_table_id = aws_route_table.public_1a.id
}

resource "aws_subnet" "dots_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dots-subnet-2"
  }
}

resource "aws_route_table" "public_1b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "dots_1b" {
  subnet_id      = aws_subnet.dots_1b.id
  route_table_id = aws_route_table.public_1b.id
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg-allow-80"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all traffic from the load balancer
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1 # all
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1 # all
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "allow_80"
  }

}