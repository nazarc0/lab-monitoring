# 1. Створюємо сам VPC (спільний адресний простір)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab-vpc"
  }
}
# ==========================================
# 2. Створюємо Subnets (Підмережі)
# ==========================================
# Публічна підмережа А (AZ: eu-central-1a)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true # Автоматично видавати публічні IP
  tags = { Name = "public-subnet-a" }
}

# Публічна підмережа B (AZ: eu-central-1b)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-b" }
}

# Приватна підмережа А (для ECS-задач, без публічних IP)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "eu-central-1a"
  tags = { Name = "private-subnet-a" }
}

# Приватна підмережа B (для ECS-задач)
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-central-1b"
  tags = { Name = "private-subnet-b" }
}

# ==========================================
# 3. Шлюзи (Gateways)
# ==========================================

# Internet Gateway (для виходу публічних сабнетів в інтернет)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "lab-igw" }
}

# Elastic IP для NAT Gateway (NAT не може працювати без статичної IP)
resource "aws_eip" "nat_ip" {
  domain = "vpc"
}

# NAT Gateway (для виходу приватних сабнетів в інтернет) - РОЗМІЩУЄТЬСЯ В ПУБЛІЧНІЙ ПІДМЕРЕЖІ!
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public_a.id # Ставимо один NAT у першу публічну зону
  
  # Бажано дочекатися створення IGW перед підняттям NAT
  depends_on = [aws_internet_gateway.igw] 
  tags = { Name = "lab-nat" }
}

# ==========================================
# 4. Таблиці маршрутизації (Route Tables)
# ==========================================

# Публічна таблиця (весь незнайомий трафік йде в Internet Gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-route-table" }
}

# Приватна таблиця (весь незнайомий трафік йде в NAT Gateway)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-route-table" }
}

# ==========================================
# 5. Прив'язка таблиць до підмереж (Associations)
# ==========================================

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}