output "user_pool_id" {
  description = "User Pool Id"
  value       = aws_cognito_user_pool.pool.id
}

output "app_client_id" {
  description = "App client Id"
  value       = aws_cognito_user_pool_client.pool_client.id
}
