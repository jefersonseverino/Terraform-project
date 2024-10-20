// Criar o security group da subrede pública que vai conter o bastion
// Deixamos abertas a porta 22 (SSH) para qualquer IP
// O security group permite saída para qualquer IP 
resource "aws_security_group" "bastion_allow_ssh" {
  vpc_id      = aws_vpc.main_vpc.id
  name        = "bastion_allow_ssh"
  description = "Security group for bastion that allows ssh and all egress traffic"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "bastion_allow_ssh"
  }
}

// Criar security group para a rede privada
// A rede privada aceita requisições vindas da subrede `bastion_allow_ssh` 
// Aceitar tráfego para a porta 80 (HTTP) e 22 (SSH)
// A subrede privada pode enviar para qualquer outro IP
resource "aws_security_group" "main_sg" {
  name        = "${var.project}-${var.candidate}-sg"
  description = "Receives traffic from bastion instance"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "Allow SSH from bastion instance"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_allow_ssh.id]
  }

  ingress {
    description     = "Allow HTTP from bastion instance"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_allow_ssh.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}-${var.candidate}-sg"
  }
}
