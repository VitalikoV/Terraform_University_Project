terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  //deleted the data here due to the security reasons
  access_key = ""
  secret_key = ""
}

# MY PROJECT

resource "aws_instance" "course_server" {
  # ami-04505e74c0741db8d
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t3.micro"

  tags = {
      Name = "ubuntu"
  }
}

#Creation of the bucket
resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"

}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}


# VPC config
# 1 Create VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# 2 Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "main"
  }
}

# 3 Create route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "Prod"
  }
}

# 4 Create a subnet
resource "aws_subnet" "subnet_1"{
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Prod"
  }
}

# 5 Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# Create a security group

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web Inbound Traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


# resource "aws_instance" "course_server" {
#     # ami-04505e74c0741db8d
#   ami           = "ami-04505e74c0741db8d"
#   instance_type = "t3.micro"

#   tags = {
#       Name = "ubuntu"
#   }
# }

# resource "aws_vpc" "my_first_vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags={
#       Name="production"
#   }
# }

# resource "aws_subnet" "main" {
#   vpc_id     = aws_vpc.my_first_vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "prod-inst"
#   }
# }







