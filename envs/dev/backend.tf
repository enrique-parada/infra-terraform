terraform {
  backend "s3" {
    bucket         = "devops-tf-state-enrique-<algo-unico>" # mismo del bootstrap
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-tf-locks"
    encrypt        = true
  }
}

