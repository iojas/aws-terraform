resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = local.common_tags
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = local.common_tags
}


resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "us-east-1a"

  tags = local.common_tags
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "us-east-1b"

  tags = local.common_tags
}

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = local.common_tags
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = local.common_tags
}


resource "aws_eip" "nat" {
  vpc = true

  tags = merge(
    local.common_tags,
    {"reason": "IP for NAT Gateway"}
  )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = merge(
    local.common_tags,
    {"reason": "for private subnet"}
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat.id
      carrier_gateway_id         = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      gateway_id                 = null
      instance_id                = null
      ipv6_cidr_block            = null
      local_gateway_id           = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
      vpc_peering_connection_id  = null
      core_network_arn           = null
    },
  ]

  tags = merge(
    local.common_tags,
    {"type": "private"}
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw.id
      nat_gateway_id             = null
      carrier_gateway_id         = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      instance_id                = null
      ipv6_cidr_block            = null
      local_gateway_id           = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
      vpc_peering_connection_id  = null
      core_network_arn           = null
    },
  ]

  tags = merge(
    local.common_tags,
    {"type": "public"}
  )
}

resource "aws_route_table_association" "private-rt-subnet-a1" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private-us-east-1a.id
}

resource "aws_route_table_association" "public-rt-subnet-1a" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public-us-east-1a.id
}

resource "aws_route_table_association" "private-rt-subnet-1b" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private-us-east-1b.id
}

resource "aws_route_table_association" "public-rt-subnet-1b" {
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public-us-east-1b.id
}