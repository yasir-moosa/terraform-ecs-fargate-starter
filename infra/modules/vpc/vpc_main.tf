resource "aws_vpc" "practice_vpc" {

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = { Name = "practice-vpc", Project = "ecs-practice" }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.practice_vpc.id

  tags = { Project = "ecs-practice" }
}

resource "aws_subnet" "public_sn_2a" {
  vpc_id                  = aws_vpc.practice_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = { Name = "practice-public-2a", Project = "ecs-practice" }
}

resource "aws_subnet" "public_sn_2b" {
  vpc_id                  = aws_vpc.practice_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = { Name = "practice-public-2b", Project = "ecs-practice" }
}

resource "aws_subnet" "private_sn_2a" {
  vpc_id            = aws_vpc.practice_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-west-2a"


  tags = { Name = "practice-private-2a", Project = "ecs-practice" }
}

resource "aws_subnet" "private_sn_2b" {
  vpc_id            = aws_vpc.practice_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "eu-west-2b"


  tags = { Name = "practice-private-2b", Project = "ecs-practice" }
}
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Project = "ecs-practice" }
}

# note only one nat gateway overall however its better to either use a 
# regional nat_gw or create another nat gateway for zone public subnet 2b
resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_sn_2a.id
  tags          = { Project = "ecs-practice" }
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.practice_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Project = "ecs-practice" }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.practice_vpc.id
  route {

    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Project = "ecs-practice" }
}

resource "aws_route_table_association" "public_2a" {
  subnet_id      = aws_subnet.public_sn_2a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_sn_2b" {
  subnet_id      = aws_subnet.public_sn_2b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_2a" {
  subnet_id      = aws_subnet.private_sn_2a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2b" {
  subnet_id      = aws_subnet.private_sn_2b.id
  route_table_id = aws_route_table.private_rt.id
}
