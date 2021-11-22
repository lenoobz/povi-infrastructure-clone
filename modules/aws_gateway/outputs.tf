output "execution_arn" {
  description = "Gateway execution arn"
  value       = aws_apigatewayv2_api.api.execution_arn
}

output "id" {
  description = "Gateway id"
  value       = aws_apigatewayv2_api.api.id
}

output "authorizer_id" {
  description = "Gateway authorizer id"
  value       = aws_apigatewayv2_authorizer.authorizer.id
}
