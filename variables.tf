variable "prefix" {
  description = "Prefix of different environment. Ex: qa, prod, or dev"
  type        = string
}

variable "domain_name" {
  description = "Domain name. Ex: example.com."
  type        = string
}

variable "domain_cert" {
  description = "Domain certificate auth"
  type        = string
}

variable "gateway_name" {
  description = "API gateway name"
  type        = string
}

variable "gateway_log_retention_days" {
  description = "Log retention in days"
  type        = number
}

variable "lambdas_bucket_name" {
  description = "Bucket lambdas storage name"
  type        = string
}

variable "website_bucket_name" {
  description = "Bucket website storage name"
  type        = string
}

variable "website_domain_name" {
  description = "Website domain name"
  type        = string
}

variable "api_list" {
  description = "Http Api list"
  type = list(object({
    name                     = string
    function_name            = string
    function_runtime         = string
    function_handler         = string
    function_timeout_seconds = number
    api_log_retention_days   = number
    routes = list(object({
      route_name        = string
      route_path        = string
      route_version     = string
      route_method      = string
      attach_authorizer = bool
    }))
  }))
  default = []
}

variable "MONGO_DB_HOST" {
  description = "Mongo Database Host (environment variable)"
  type        = string
}

variable "MONGO_DB_USERNAME" {
  description = "Mongo Database Username (environment variable)"
  type        = string
}

variable "MONGO_DB_PASSWORD" {
  description = "Mongo Database Password (environment variable)"
  type        = string
}

variable "GOOGLE_CLIENT_ID" {
  description = "Google Oauth Client Id (environment variable)"
  type        = string
}

variable "GOOGLE_CLIENT_SECRET" {
  description = "Mongo Oauth Client Secret (environment variable)"
  type        = string
}

