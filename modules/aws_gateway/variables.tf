variable "prefix" {
  description = "Prefix of different environment. Ex: qa, prod, or dev"
  type        = string
}

variable "domain_name" {
  description = "Api Gateway domain name"
  type        = string
}

variable "domain_cert" {
  description = "Domain certificate auth"
  type        = string
}

variable "cognito_region" {
  description = "Cognito Region"
  type        = string
}

variable "cognito_audience" {
  description = "Cognito App Client Id"
  type        = string
}

variable "cognito_pool_id" {
  description = "Cognito User Pool Id"
  type        = string
}

variable "authorizer_name" {
  description = "Api authorizer name"
  type        = string
}

variable "gateway_name" {
  description = "Api gateway name"
  type        = string
}

variable "gateway_log_retention_days" {
  description = "Cloudwatch log retention in days. Ex: 7"
  type        = number
}
