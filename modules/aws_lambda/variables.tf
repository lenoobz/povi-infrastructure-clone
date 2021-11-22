variable "prefix" {
  description = "Prefix to append to any resource name. Ex: qa, prod, or dev"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name that store all lambda code"
  type        = string
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "function_runtime" {
  description = "Lambda function runtime. Ex: go1.x"
  type        = string
}

variable "function_handler" {
  description = "Lambda function handler. Ex: main"
  type        = string
}

variable "function_timeout_seconds" {
  description = "Lambda function timeout. Ex: 3"
  type        = number
}

variable "api_log_retention_days" {
  description = "Cloudwatch log retention in days. Ex: 7"
  type        = number
}

variable "function_env_variables" {
  description = "Lambda function environment variables"
  type        = map(string)
  default     = {}
}
