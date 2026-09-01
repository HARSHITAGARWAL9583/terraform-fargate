resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr  //aws api call //vpc created on AWS

  tags = {
    Name        = "${var.project_name}-vpc" //   ex- myapp-vpc
    Environment = var.environment   // terraform-dev
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs) // we have two public subnet cidr so 

  vpc_id                  = aws_vpc.main.id   // Subnet ko VPC ke andar banana hai toh subnet ko pata hona chahiye ki mujhe kis VPC mein banana ha
  cidr_block              = var.public_subnet_cidrs[count.index]   //because we creaate te two public subnet so  we need the   cide 10.10 karke  or matlab alag lag avaivable zone mai 
  availability_zone       = var.availability_zones[count.index] //  do done hai  na toh dono mai alag alag cidr 
  map_public_ip_on_launch = true //Jab bhi koi EC2 instance ya resource is public subnet mein launch hoga, AWS automatically usse ek public IP de dega

  tags = {
    Name        = "${var.project_name}-public-${count.index + 1}" //  first wla ka  myapp-public-1 , myapp-public-2
    Environment = var.environment //terraform dev
    ManagedBy   = "terraform"
    Tier        = "public"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs) // we have two private subnet cidr 

  vpc_id            = aws_vpc.main.id // Subnet ko VPC ke andar banana hai toh subnet ko pata hona chahiye ki mujhe kis VPC mein banana ha
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project_name}-private-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "terraform"
    Tier        = "private"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
    ManagedBy   = "terraform"
    Tier        = "public"
  }
}

# Route all public traffic through the internet gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
