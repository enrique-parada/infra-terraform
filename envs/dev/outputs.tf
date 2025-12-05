output "lambda_function_name" {
  value = module.lambda_api.lambda_name
}

output "api_url" {
  value = module.api_gateway.api_url
}

