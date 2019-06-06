provider "aws" {
  region = "eu-west-1"
}


# Define our VPC
resource "aws_vpc" "default" {
  cidr_block = "10.30.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "qamar-vpc"
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.30.1.0/24"

  tags = {
    Name = "Qamar Public Subnet"
  }
}

# Define the private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.30.2.0/24"

  tags = {
    Name = "Qamar Private Subnet"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "VPC INTERNET GATEWAY"
  }
}

# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "Public Subnet RT"
  }
}

resource "aws_route_table" "web-private-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "Private Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}
# Assign the route table to the private Subnet
resource "aws_route_table_association" "web-private-rt" {
  subnet_id = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_route_table.web-private-rt.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "public-sgweb" {
  name = "qamar_vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"

  tags = {
    Name = "Public SG"
  }
}

# Define the security group for public subnet
# Define the security group for private subnet
resource "aws_security_group" "private-sgdb"{
  name = "sg_test_web"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.30.1.0/24"]
  }


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.30.1.0/24"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "Private SG"
  }
}


# Define webserver inside the public subnet
resource "aws_instance" "wb" {
   ami  = "ami-0b45d039456f24807"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.team_2_keypair.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.public-sgweb.id}"]
   associate_public_ip_address = true

  tags = {
    Name = "team_2_public"
  }
}

# Define database inside the private subnet
resource "aws_instance" "db" {
   ami  = "ami-0b45d039456f24807"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.private-sgdb.id}"]
   associate_public_ip_address = false

  tags = {
    Name = "team_2_private"
  }
}

resource "aws_key_pair" "team_2_keypair" {
  key_name = "team_2_key_pair"
  public_key = "${file("~/.ssh/id_rsa.pub")}"

}
