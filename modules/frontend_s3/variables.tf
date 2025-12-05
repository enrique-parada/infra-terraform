variable "bucket_name" {
  type        = string
  description = "Nombre del bucket S3 para hosting del frontend"
}

variable "tags" {
  type        = map(string)
  description = "Tags a aplicar al bucket"
  default     = {}
}

