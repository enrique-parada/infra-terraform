terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "tf_state" {
  bucket = "devops-tf-state-enrique-textapp"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "terraform-state"
    Environment = "dev"
    Project     = "devops-text-toolkit"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state_block" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cifrado por defecto del bucket del state
# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# tfsec:ignore:aws-dynamodb-table-customer-key
resource "aws_dynamodb_table" "tf_lock" {
  name         = "devops-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Cifrado en reposo
  server_side_encryption {
    enabled = true
  }

  # Point-in-time recovery (PITR)
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "terraform-locks"
    Environment = "dev"
    Project     = "devops-text-toolkit"
  }
}

