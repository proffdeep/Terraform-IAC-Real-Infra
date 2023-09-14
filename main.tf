provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create two public subnets in different AZs
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Change to your desired AZ
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b" # Change to your desired AZ
  map_public_ip_on_launch = true
}

# Create a private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create private subnets in different AZs
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a" # Change to your desired AZ
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b" # Change to your desired AZ
}


# Associate private route table with private subnets
resource "aws_route_table_association" "private_subnet_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "public_subnet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0" 
  gateway_id = aws_internet_gateway.my_igw.id
}

# Create a security group for instances in private subnets (adjust rules as needed)
resource "aws_security_group" "private_sg" {
  name_prefix = "private_sg_"

  vpc_id = aws_vpc.my_vpc.id

    egress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

# Create a security group for instances in public subnets (adjust rules as needed)
resource "aws_security_group" "public_sg" {
    name_prefix = "public_sg_"

  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }


}

# Create EC2 instances in private subnets
resource "aws_instance" "private_instance_1" {
  ami             = "ami-053b0d53c279acc90" # Specify your desired AMI ID
  instance_type   = "t2.micro"     # Specify your desired instance type
  subnet_id       = aws_subnet.private_subnet_1.id
  key_name        = "EC2 Tutorial" # Specify your key pair name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
}


resource "aws_instance" "private_instance_2" {
  ami             = "ami-053b0d53c279acc90" # Specify your desired AMI ID
  instance_type   = "t2.micro"     # Specify your desired instance type
  subnet_id       = aws_subnet.private_subnet_2.id
  key_name        = "EC2 Tutorial" # Specify your key pair name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
}

# Create a bastion host in the public subnet
resource "aws_instance" "bastion_host" {
  ami             = "ami-053b0d53c279acc90" # Specify your desired AMI ID
  instance_type   = "t2.micro"     # Specify your desired instance type
  subnet_id       = aws_subnet.public_subnet_1.id
  key_name        = "EC2 Tutorial" # Specify your key pair name
  vpc_security_group_ids  = [aws_security_group.public_sg.id]
}

# Create a NAT gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

resource "aws_eip" "my_eip" {
  domain = "vpc"
}

# Create a route in the private route table to send internet-bound traffic through the NAT gateway
resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway.id
}