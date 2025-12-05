variable "function_name" {
  type        = string
  description = "Nombre de la función Lambda"
}

variable "runtime" {
  type        = string
  description = "Runtime de la Lambda"
  default     = "python3.12"
}

variable "handler" {
  type        = string
  description = "Handler de la Lambda"
  default     = "app.main.handler"
}

variable "lambda_filename" {
  type        = string
  description = "Ruta local al ZIP de la Lambda"
}

variable "app_env" {
  type        = string
  description = "Entorno de la aplicación (dev/stage/prod)"
  default     = "dev"
}

