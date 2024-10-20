// Criar internet gateway entre a vpc e a internet externa
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project}-${var.candidate}-igw"
  }
}

// Cria uma tabela de rotas para a VPC, permitindo o roteamento do tráfego entre a VPC e a internet.
// A tabela de rotas é associada à VPC especificada por vpc_id.
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "${var.project}-${var.candidate}-route_table"
  }
}

// Criar tabela de roteamento associando a subrede bastion e a internet
resource "aws_route_table_association" "bastion_subnet_association" {
  subnet_id      = aws_subnet.bastion_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

// Criar tabela de roteamente associando a subrede a subnet privada a internet
resource "aws_route_table_association" "main_subnet_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}