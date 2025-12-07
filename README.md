# infra-terraform

Este repositorio contiene la **infraestructura como código (IaC)** del proyecto **DevOps Text Toolkit**, usando **Terraform** sobre **AWS**.

Su objetivo es:

- Crear y gestionar de forma reproducible:
  - Backend remoto de Terraform (S3 + DynamoDB).
  - API serverless (Lambda + API Gateway HTTP) para el backend.
  - Bucket S3 para el frontend (static website hosting).
- Integrar buenas prácticas de:
  - **GitFlow**.
  - **CI/CD** con GitHub Actions.
  - **Seguridad de IaC** con `tfsec`.
  - **Costos** con `Infracost` (free tier-friendly).



## 🗂️ Estructura del repositorio

```text
infra-terraform/
├── bootstrap/
│   └── main.tf                 # Backend remoto de Terraform (S3 + DynamoDB)
│
├── envs/
│   └── dev/
│       ├── backend.tf          # Configuración del backend remoto (S3 + DynamoDB)
│       ├── main.tf             # Uso de módulos para Lambda, API Gateway y S3 frontend
│       ├── outputs.tf          # Outputs (api_url, frontend_website_url, etc.)
│       └── variables.tf        # Variables del entorno dev
│
├── modules/
│   ├── lambda_api/             # Módulo para la Lambda del backend
│   ├── api_gateway/            # Módulo para el API Gateway HTTP
│   └── frontend_s3/            # Módulo para el bucket S3 del frontend
│
├── artifacts/
│   └── backend.zip             # ZIP del backend (generado en el repo microservice-api)
│
└── .github/
    └── workflows/
        ├── ci.yml              # CI de Terraform: fmt, validate, tfsec
        └── infracost.yml       # Infracost: reporte de costo en PR
```

---

## 🔧 Requisitos

- **Terraform**: probado con `>= 1.7.x`  
  (puede actualizarse a versiones más nuevas ajustando `required_version` y el workflow de CI).
- **Provider AWS**: probado con `~> 5.0` del provider `hashicorp/aws`.
- Cuenta de **AWS** con permisos para:
  - Crear S3, DynamoDB, Lambda, API Gateway.
- Usuario/credenciales IAM para Terraform (ej. `terraform-devops`) con permisos adecuados
  (en esta prueba se puede usar un rol más amplio, documentando que en producción se haría **least privilege**).

---

## 🧱 Backend remoto de Terraform (state + locks)

El backend remoto se gestiona en `bootstrap/main.tf` y crea:

### S3 – Bucket de state

- Recurso: `aws_s3_bucket.tf_state`
- Configuración de seguridad:
  - **Privado**, sin políticas públicas.
  - **Versioning** habilitado (`aws_s3_bucket_versioning.tf_state_versioning`).
  - **Cifrado en reposo** (`aws_s3_bucket_server_side_encryption_configuration.tf_state_encryption` con `AES256`).
  - **Public access block** (`aws_s3_bucket_public_access_block.tf_state_block`).

### DynamoDB – Tabla de locks

- Recurso: `aws_dynamodb_table.tf_lock`
- Uso: locking de Terraform para evitar `terraform apply` concurrentes.
- Configuración:
  - `billing_mode = "PAY_PER_REQUEST"`.
  - Cifrado en reposo (`server_side_encryption.enabled = true`).
  - **Point-in-time recovery (PITR)** habilitado.

### Razón de diseño

- S3 + DynamoDB son el patrón recomendado para:
  - State remoto compartido.
  - Bloqueo de concurrencia.
  - Durabilidad y recuperación del state (versioning + PITR).
- Algunos checks de `tfsec` que recomiendan:
  - Claves KMS administradas por el cliente (CMK).
  - Logging detallado del bucket de state.
  Se han documentado como **mejoras futuras** y marcados explícitamente con `tfsec:ignore`, manteniendo el equilibrio entre seguridad y simplicidad en esta prueba.

---

## 🚀 Flujo de uso

### 1️⃣ Bootstrap (crear backend de state)

Desde `infra-terraform/bootstrap`:

```bash
cd bootstrap

terraform init
terraform plan
terraform apply
```

Esto crea:

- `devops-tf-state-enrique-textapp` (o el bucket que hayas configurado).
- Tabla `devops-tf-locks` para locks.

> Este paso suele ejecutarse **una sola vez** por cuenta/entorno.

---

### 2️⃣ Entorno `dev` (infra de la aplicación)

En `envs/dev/backend.tf` se configura el backend remoto, por ejemplo:

```hcl
terraform {
  backend "s3" {
    bucket         = "devops-tf-state-enrique-textapp"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-tf-locks"
    encrypt        = true
  }
}
```

Luego, desde `infra-terraform/envs/dev`:

```bash
cd envs/dev

terraform init         # ahora usando el backend remoto
terraform plan
terraform apply
```

Esto crea (via módulos):

- Lambda del backend (usando `artifacts/backend.zip`).
- API Gateway HTTP integrado con esa Lambda.
- Bucket S3 con static website para el frontend (index/error document).

Outputs típicos:

```bash
terraform output
terraform output api_url
terraform output frontend_website_url
```



## 🧪 Comandos útiles

### Validar cambios localmente

```bash
cd bootstrap
terraform fmt
terraform validate

cd ../envs/dev
terraform fmt
terraform validate
```


### Estimar costos localmente (opcional)

```bash
infracost breakdown --path=envs/dev
```

---

## 🚀 Futuras mejoras

- Añadir más entornos (`envs/stage`, `envs/prod`) reutilizando los mismos módulos.
- Integrar CloudFront + HTTPS para el frontend S3.
- Afinar aún más IAM (políticas least privilege por servicio).
- Profundizar en observabilidad (por ejemplo, dashboards de CloudWatch para Lambda/API Gateway).

