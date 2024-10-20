// Modificação
// https://registry.terraform.io/providers/hashicorp/aws/3.3.0/docs/resources/flow_log
// Adicionar cloudwatch log group
// Os logs serão apagados após 7 dias
resource "aws_cloudwatch_log_group" "vpc_log_group" {
  name              = "${var.project}-${var.candidate}-vpc-log-group"
  retention_in_days = 7

  tags = {
    Name = "${var.project}-${var.candidate}-vpc-log-group"
  }
}

// O recurso `aws_flow_log` cria um VPC Flow Log, que é usado para capturar informações sobre o tráfego de rede entrando e saindo.
// Nesse caso, o log captura todo o tráfego ("ALL") associado à VPC.
// O log é associado a uma IAM Role (`iam_role_arn`) que define permissões de escrita no CloudWatch.
resource "aws_flow_log" "vpc_log" {
  iam_role_arn    = aws_iam_role.vpc_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main_vpc.id
  log_destination = aws_cloudwatch_log_group.vpc_log_group.arn

  tags = {
    Name = "${var.project}-${var.candidate}-vpc-flow-log"
  }
}

// O recurso `aws_iam_policy_document` define uma política IAM que permite ao serviço VPC Flow Logs assumir uma role IAM.
// A ação permitida é `sts:AssumeRole`, o que significa que o serviço VPC Flow Logs pode assumir a role associada a essa política
// permitindo o envio de logs para o CloudWatch ou outro destino.
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


// Criar recurso para IAM.
resource "aws_iam_role" "vpc_log" {
  name               = "vpc_log"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

// O recurso `aws_iam_policy_document` define uma política IAM que concede permissões para interagir com o serviço de logs do CloudWatch.
// - `CreateLogGroup`: criar grupos de logs;
// - `CreateLogStream`: criar fluxos de logs;
// - `PutLogEvents`: enviar eventos de logs para um fluxo de logs;
// - `DescribeLogGroups`: visualizar detalhes dos grupos de logs;
// - `DescribeLogStreams`: visualizar detalhes dos fluxos de logs.
data "aws_iam_policy_document" "vpc_log_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

// Asoociar a IAM a role e a política
resource "aws_iam_role_policy" "vpc_log" {
  name   = "vpc_log"
  role   = aws_iam_role.vpc_log.id
  policy = data.aws_iam_policy_document.vpc_log_policy.json
}