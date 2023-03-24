provider "aws" {
  region = "us-east-1"
}

resource aws_vpc "bookapp_vpc"{
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "bookapp_vpc"
  }
}

resource aws_subnet "bookapp_publicA" {
  vpc_id = aws_vpc.bookapp_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "bookapp_publicA"
  }
}

resource aws_subnet "bookapp_privateA"{
  vpc_id = aws_vpc.bookapp_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "bookapp_privateA"
  }
}

resource aws_subnet "bookapp_publicB"{
  vpc_id = aws_vpc.bookapp_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "bookapp_publicB"
  }
}

resource aws_subnet "bookapp_privateB"{
  vpc_id = aws_vpc.bookapp_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "bookapp_privateB"
  }
}

resource "aws_internet_gateway" "bookapp_igw" {
  vpc_id = aws_vpc.bookapp_vpc.id

  tags = {
    "Name" = "bookapp_igw"
  }
}

resource "aws_route_table" "bookapp_rtb" {
  vpc_id = aws_vpc.bookapp_vpc.id

  tags = {
    "Name" = "bookapp_rtb"
  }
}

resource "aws_route" "bookapp_rt" {
  route_table_id = aws_route_table.bookapp_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.bookapp_igw.id

}

resource "aws_route_table_association" "bookapp_rtb_assoc" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.bookapp_rtb.id
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound connections"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Allow HTTP Security Group"
  }
}

resource "aws_launch_template" "bookapp_lt" {
  name_prefix   = "bookapp"
  image_id      = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "bookapp_ag" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.bookapp_lt.id
    version = "$Latest"
  }
}
