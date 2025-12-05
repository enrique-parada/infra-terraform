terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "lambda_api" {
  source = "../../modules/lambda_api"

  function_name = "devops-text-toolkit-api-dev"
  runtime       = "python3.11"
  handler       = "main.handler"
  app_env       = "dev"

  # Más adelante crearemos este ZIP desde el repo de backend.
  lambda_filename = "${path.module}/../../artifacts/backend.zip"
}

module "api_gateway" {
  source            = "../../modules/api_gateway"
  name              = "devops-text-toolkit-apigw-dev"
  lambda_arn        = module.lambda_api.lambda_arn
  lambda_invoke_arn = module.lambda_api.lambda_invoke_arn
}

