# Can be used for tests! Don't use in production
# resource "tls_private_key" "ec2_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }
// https://github.com/raj13aug/Terraform-demo/blob/main/ssh-key-store-ssm/main.tf -> Chave no aws secrets manager

// ssh-keygen -t rsa -b 4096 -f ~/.ssh/my_ec2_key
// Definir o recurso com as chaves ssh usando a chave ssh gerada com o comando da linha anterior
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.project}-${var.candidate}-key"
  public_key = file(var.public_key_path)
}

// O recurso `aws_kms_key` cria uma chave KMS (Key Management Service) usada para criptografar dados sensíveis.
// A rotação automática da chave melhora a segurança ao garantir que a chave seja trocada periodicamente.
resource "aws_kms_key" "kms_key" {
  description         = "Description key for secret manager"
  enable_key_rotation = true
}

// O recurso `aws_secretsmanager_secret` cria um segredo no AWS Secrets Manager para armazenar informações sensíveis.
// O `kms_key_id` especifica a chave KMS que será utilizada para criptografia 
resource "aws_secretsmanager_secret" "secret" {
  description = "SSH keys for EC2 instance"
  name        = "Ec2-ssh-key"
  kms_key_id  = aws_kms_key.kms_key.arn
}

// Armazernar uma versão específica de um segredo no AWS Secrets Manager.
// Isso permite que a chave privada SSH seja gerenciada de forma segura e acessível apenas por usuários ou serviços autorizados.
resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = file(var.private_key_path)
}

// Obter AMI para um container que contém os filtros definidos abaixo
data "aws_ami" "debian12" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_owner]
}

// O recurso `aws_ssm_parameter` cria um parâmetro no AWS Systems Manager (SSM) Parameter Store para armazenar a configuração do agente do CloudWatch.
// cw_agent_config.json contém as configurações específicas do agente.
resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("${path.module}/cw_agent_config.json")
}

// Define uma variável `userdata`, que utiliza a função `templatefile` para gerar um script de inicialização.
// O `templatefile` lê o arquivo "user_data.sh" e substitui o placeholder `ssm_cloudwatch_config` pelo nome do parâmetro do SSM.
locals {
  userdata = templatefile("${path.module}/scripts/nginx_instance_setup.sh", {
    ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name
  })

  bastion_script = file("${path.module}/scripts/bastion_instance_setup.sh")
}

// https://cyberpadawan.dev/terraform-code-to-deploy-bastion-host-and-private-instance-in-aws
// Criação da instância do tipo bastions
resource "aws_instance" "bastion_ec2" {
  ami                         = data.aws_ami.debian12.id
  instance_type               = var.instance_type
  subnet_id                   = var.bastion_subnet_id
  vpc_security_group_ids      = [var.bastion_security_group_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key_pair.key_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  // Enable monitoring
  monitoring = true

  user_data = local.bastion_script

  tags = {
    Name = "${var.project}-${var.candidate}-bastion-ec2"
  }
}

// Criação da instância `debian_ec2`
resource "aws_instance" "debian_ec2" {
  ami             = data.aws_ami.debian12.id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  key_name        = aws_key_pair.ec2_key_pair.key_name
  security_groups = [var.sg_name]

  associate_public_ip_address = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  monitoring = true
  user_data  = local.userdata

  tags = {
    Name = "${var.project}-${var.candidate}-ec2"
  }
}
