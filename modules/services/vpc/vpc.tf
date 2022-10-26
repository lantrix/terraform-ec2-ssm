variable "region" {}
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
resource "aws_vpc" "soapbox-vpc" {
   cidr_block = "192.168.0.0/16"
   instance_tenancy = "default"
   enable_dns_support = "true"
   enable_dns_hostnames = "true"
   tags = {
     Name = "soapbox-vpc"
   }
}
resource "aws_subnet" "soapbox-public-subnet-1" {
   vpc_id = "${aws_vpc.soapbox-vpc.id}"
   cidr_block = "192.168.1.0/24"
   map_public_ip_on_launch = "false"
   availability_zone = "${var.region}a"
   tags = {
     Name = "soapbox-public-subnet-1"
   }
}
resource "aws_subnet" "soapbox-public-subnet-2" {
   vpc_id = "${aws_vpc.soapbox-vpc.id}"
   cidr_block = "192.168.2.0/24"
   map_public_ip_on_launch = "false"
   availability_zone = "${var.region}b"
   tags = {
     Name = "soapbox-public-subnet-2"
   }
}
resource "aws_internet_gateway" "soapbox-internetgateway" {
   vpc_id = "${aws_vpc.soapbox-vpc.id}"
   tags = {
     Name = "soapbox-internetgateway"
   }
}
resource "aws_route_table" "soapbox-public-routetable" {
   vpc_id = "${aws_vpc.soapbox-vpc.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.soapbox-internetgateway.id}"
   }
   tags = {
     Name = "soapbox-public-routetable"
   }
}
resource "aws_route_table_association" "soapbox-public-1" {
   subnet_id = "${aws_subnet.soapbox-public-subnet-1.id}"
   route_table_id = "${aws_route_table.soapbox-public-routetable.id}"
}
resource "aws_route_table_association" "soapbox-public-2" {
   subnet_id = "${aws_subnet.soapbox-public-subnet-2.id}"
   route_table_id = "${aws_route_table.soapbox-public-routetable.id}"
}
resource "aws_security_group" "soapbox-ec2-sg" {
  name        = "soapbox-ec2-sg"
  description = "Allow only ansible traffic in"
  vpc_id = "${aws_vpc.soapbox-vpc.id}"
  ingress {
    description      = "SSH from local"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    description      = "HTTP from local"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["${chomp(data.http.myip.response_body)}/32"]
  }
  ingress {
    description      = "HTTPS from local"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["${chomp(data.http.myip.response_body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
     Name = "soapbox-ec2-sg"
   }
}
