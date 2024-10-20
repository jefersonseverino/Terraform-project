// Referência: https://jazz-twk.medium.com/cloudwatch-agent-on-ec2-with-terraform-8cf58e8736de

// Essas políticas permitem que a instância EC2 interaja com o SSM (AWS Systems Manager)
// e que o agente do CloudWatch possa coletar e enviar métricas e logs.
// definindo numa variável `role_policy_arns` com escopo local
locals {
  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

// Cria um perfil IAM para a instância EC2.
resource "aws_iam_instance_profile" "aws_instance_profile" {
  name = "EC2-Profile"
  role = aws_iam_role.iam_role_ec2.name
}

// Anexa políticas IAM à função definida anteriormente.
// A contagem é baseada no número de ARNs de políticas especificadas,
// garantindo que cada política seja associada à função correta.
resource "aws_iam_role_policy_attachment" "aws_iam_policy_attack" {
  count = length(local.role_policy_arns)

  role       = aws_iam_role.iam_role_ec2.name
  policy_arn = element(local.role_policy_arns, count.index)
}

// Cria uma política IAM inline para a função EC2.
// Esta política garante que a instância EC2 acesse o parâmetro SSM especificado,
resource "aws_iam_role_policy" "aws_iam_role_policy" {
  name = "EC2-Inline-Policy"
  role = aws_iam_role.iam_role_ec2.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameter"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

// Esta função permite que as instâncias EC2 assumam a função, 
// utilizando a política de confiança que especifica o serviço EC2 como principal autorizado.
resource "aws_iam_role" "iam_role_ec2" {
  name = "EC2-Role"
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
    }
  )
}