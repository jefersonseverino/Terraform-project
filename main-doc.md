## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ./modules/ec2 | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region of provider | `string` | `"us-east-1"` | no |
| <a name="input_candidato"></a> [candidato](#input\_candidato) | Nome do candidato | `string` | `"Jeferson"` | no |
| <a name="input_projeto"></a> [projeto](#input\_projeto) | Nome do projeto | `string` | `"VExpenses"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sg_group_name"></a> [sg\_group\_name](#output\_sg\_group\_name) | n/a |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
