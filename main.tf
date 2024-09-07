# AWS 제공자 설정
provider "aws" {
  region = "ap-northeast-2"  # 서울 리전
}

# VPC 생성
resource "aws_vpc" "main_vpc" {
  cidr_block = "192.169.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

# 서브넷 생성 (퍼블릭 서브넷)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "192.169.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

# 라우팅 테이블 생성
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "public_rt"
  }
}

# 인터넷으로의 기본 라우트 추가
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# 서브넷을 라우팅 테이블에 연결
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 보안 그룹 생성
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

# 프론트엔드 서버 생성
resource "aws_instance" "front_server" {
  ami                    = "ami-046f30a00c4c82a8d"  # ubuntu 22.04
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "hackathon"

  tags = {
    Name = "front_server"
  }
}

# 백엔드 서버 생성
resource "aws_instance" "back_server" {
  ami                    = "ami-046f30a00c4c82a8d"  # ubuntu 22.04
  instance_type          = "t2.medium"  # 인스턴스 타입 변경
  subnet_id              = aws_subnet.public_subnet.id  # 동일 서브넷 사용
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "hackathon"

  tags = {
    Name = "back_server"
  }
}
