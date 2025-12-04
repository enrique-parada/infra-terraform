# infra-terraform

Infraestructura para la prueba DevOps utilizando Terraform.

## Estructura

- `bootstrap/`: crea recursos para el backend remoto de Terraform (S3 + DynamoDB).
- `envs/dev/`: definición de la infraestructura del entorno `dev`.

## Backend de Terraform

1. Ejecutar el bootstrap (una sola vez):

```bash
cd bootstrap
terraform init
terraform apply

