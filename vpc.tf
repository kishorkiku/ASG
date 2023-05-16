# VPC Creation
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "terraform-vpc"
  }
}

# Creating Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "terraform-igw"
  }
}

# Public Route Table

resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "terraform-public-route"
  }
}

# Private Route Table

resource "aws_default_route_table" "private_route" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  tags = {
    Name = "terraform-private-route-table"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = 2
  cidr_block              = "${var.public_cidrs[count.index]}"
  vpc_id                  = "${aws_vpc.main.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "terraform-public-subnet.${count.index + 1}"
  }
}

# Private Subnet

resource "aws_subnet" "private_subnet" {
  count             = 2
  cidr_block        = "${var.private_cidrs[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "terraform-private-subnet.${count.index + 1}"
  }
}

# Associate Public Subnet with Public Route Table

resource "aws_route_table_association" "public_subnet_assoc" {
 #count          = "${length(aws_subnet.public_subnet[count.index])}"
  count = length(var.public_cidrs)
  route_table_id = "${aws_route_table.public_route.id}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  depends_on     = [
                  aws_route_table.public_route,
                  aws_subnet.public_subnet,
]
}

# Associate Private Subnet with Private Route Table

resource "aws_route_table_association" "private_subnet_assoc" {
  #count          = "${length(aws_subnet.private_subnet[count.index])}"
  count = length(var.private_cidrs)
  route_table_id = "${aws_default_route_table.private_route.id}"
  subnet_id      = "${aws_subnet.private_subnet.*.id[count.index]}" 
  depends_on     = [
                  aws_default_route_table.private_route,
                  aws_subnet.private_subnet,
]
}