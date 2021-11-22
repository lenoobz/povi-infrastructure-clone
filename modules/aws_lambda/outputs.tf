output "function_name" {
  description = "Function name"
  value       = aws_lambda_function.function.function_name
}

output "function_arn" {
  description = "Function arn"
  value       = aws_lambda_function.function.arn
}

output "function_invoke_arn" {
  description = "Function invoke arn"
  value       = aws_lambda_function.function.invoke_arn
}
