variable "prefix" {
  description = "Prefix of different environment. Ex: qa, prod, or dev"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name that store all lambda code"
  type        = string
}

variable "machine_name" {
  description = "State machine name"
  type        = string
}

variable "cron_name" {
  description = "Cron job name"
  type        = string
}

variable "cron_expression" {
  description = "Cron job schedule expression. Ex: cron(0 0 ? * MON *)"
  type        = string
}

variable "function_env_variables" {
  description = "Lambda function environment variables"
  type        = map(string)
  default     = {}
}
