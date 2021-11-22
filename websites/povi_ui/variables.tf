variable "prefix" {
  description = "Prefix of different environment. Ex: qa, prod, or dev"
  type        = string
}

variable "domain_name" {
  description = "Domain name. Ex: example.com."
  type        = string
}

variable "force_destroy" {
  description = "Force destroy"
  type        = bool
  default     = false
}