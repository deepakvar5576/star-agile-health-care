#Initialize Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "ap-south-1"
}
# Create VPC

resource "aws_vpc" "myvpc9" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc9"
  }
}

# Create Subnet 

resource "aws_subnet" "mysubnet9" {
  vpc_id     = aws_vpc.myvpc9.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mysubnet9"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "mygw9" {
  vpc_id = aws_vpc.myvpc9.id

  tags = {
    Name = "mygw9"
  }
}

# Route Table

resource "aws_route_table" "myrt9" {
  vpc_id = aws_vpc.myvpc9.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygw9.id
  }

  tags = {
    Name = "myrt9"
  }
}

# Route Table Association

resource "aws_route_table_association" "myrta9" {
  subnet_id      = aws_subnet.mysubnet9.id
  route_table_id = aws_route_table.myrt9.id
}

# Security Groups

resource "aws_security_group" "mysg9" {
  name        = "mysg9"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.myvpc9.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mysg9"
  }
}



# Creating an ubuntu EC2 instance
resource "aws_instance" "Prod-Server" {
 ami = "ami-0a7cf821b91bcccbc"
 instance_type = "t2.micro"
 availability_zone = "ap-south-1b"
 key_name = "newaccount"
 

  
 user_data  = <<-EOF
 #!/bin/bash
     sudo apt-get update -y
     sudo apt install docker.io -y
     sudo systemctl enable docker
     sudo docker run -itd -p 8087:8082 deepakvarshney5576/health-project:1.0
     sudo docker start $(docker ps -aq)
 EOF
 tags = {
 Name = "Terraform-Server"
 }
}
