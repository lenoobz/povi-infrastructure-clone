variable "prefix" {
  description = "Prefix of different environment. Ex: qa, prod, or dev"
  type        = string
}

variable "domain_name" {
  description = "Api Gateway domain name"
  type        = string
}

variable "cognito_domain" {
  description = "Cognito domain name"
  type        = string
}

variable "pool_name" {
  description = "Cognito user pool"
  type        = string
}

variable "identity_pool_name" {
  description = "Identifier for the resource server"
  type        = string
}

variable "google_client_id" {
  description = "Google identifier client id"
  type        = string
}

variable "google_client_secret" {
  description = "Google identifier client secret"
  type        = string
}

