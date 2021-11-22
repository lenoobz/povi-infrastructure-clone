variable "prefix" {
  description = "Prefix of different environment. Ex: qa, prod, or dev"
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

variable "state_machine_id" {
  description = "State machine id"
  type        = string
}

variable "state_machine_arn" {
  description = "State machine arn"
  type        = string
}
