######################################## VPC #####################################################

resource "aws_vpc" "ECS" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "ECS"
  }
}

##################################### ECS_Public1 Subnet ##########################################

resource "aws_subnet" "ECS_Public1" {
  vpc_id     = "${aws_vpc.ECS.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "ECS_Public1"
  }
}

##################################### ECS_Public2 Subnet ##########################################

resource "aws_subnet" "ECS_Public2" {
  vpc_id     = "${aws_vpc.ECS.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "ECS_Public2"
  }
}

##################################### ECS_Private1 Subnet ##########################################

resource "aws_subnet" "ECS_Private1" {
  vpc_id     = "${aws_vpc.ECS.id}"
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "ECS_Private1"
  }
}

##################################### ECS_Private2 Subnet ##########################################

resource "aws_subnet" "ECS_Private2" {
  vpc_id     = "${aws_vpc.ECS.id}"
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "ECS_Private2"
  }
}

##################################### Internet Gateway ##########################################

resource "aws_internet_gateway" "ECS_IGW" {
  vpc_id = "${aws_vpc.ECS.id}"

  tags = {
    Name = "ECS_IGW"
  }
}

##################################### Public Route Table ##########################################

resource "aws_route_table" "Public_Route" {
  vpc_id = "${aws_vpc.ECS.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ECS_IGW.id}"
  }

  tags = {
    Name = "Public_Route_Table"
  }
}

####################################### Elastic IP ###############################################

resource "aws_eip" "ECS_eip" {
}

####################################### NAT Gateway ###############################################

resource "aws_nat_gateway" "ECS_Nat" {
  allocation_id = "${aws_eip.ECS_eip.id}"
  subnet_id     = "${aws_subnet.ECS_Public1.id}"
  tags = {
    Name = "ECS NAT GW"
  }
}

##################################### Private Route Table ##########################################
resource "aws_route_table" "Private_Route" {
  vpc_id = "${aws_vpc.ECS.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ECS_Nat.id}"
  }

  tags = {
    Name = "Private_Route_Table"
  }
}

##################################### Public Route Table Associations #####################################

resource "aws_route_table_association" "ECS_Public1_association" {
  subnet_id      = "${aws_subnet.ECS_Public1.id}"
  route_table_id = "${aws_route_table.Public_Route.id}"
}

resource "aws_route_table_association" "ECS_Public2_association" {
  subnet_id      = "${aws_subnet.ECS_Public2.id}"
  route_table_id = "${aws_route_table.Public_Route.id}"
}

#################################### Private Route Table Associations #####################################

resource "aws_route_table_association" "ECS_Private1_association" {
  subnet_id      = "${aws_subnet.ECS_Private1.id}"
  route_table_id = "${aws_route_table.Private_Route.id}"
}

resource "aws_route_table_association" "ECS_Private2_association" {
  subnet_id      = "${aws_subnet.ECS_Private2.id}"
  route_table_id = "${aws_route_table.Private_Route.id}"
}

########################################## LB Security Group ##########################################

resource "aws_security_group" "LB_SGS" {
  name        = "LB_SGS"
  description = "Allows http&https inbound traffic"
  vpc_id      = "${aws_vpc.ECS.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
