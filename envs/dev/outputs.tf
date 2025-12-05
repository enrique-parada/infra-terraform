output "lambda_function_name" {
  value = module.lambda_api.lambda_name
}

output "api_url" {
  value = module.api_gateway.api_url
}

output "frontend_bucket_name" {
  value = module.frontend_s3.bucket_name
}

output "frontend_website_url" {
  value = module.frontend_s3.website_endpoint
}

