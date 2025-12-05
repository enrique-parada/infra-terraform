variable "name" {
  type        = string
  description = "Nombre del API Gateway"
}

variable "lambda_arn" {
  type        = string
  description = "ARN de la función Lambda"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Invoke ARN de la Lambda"
}

