variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "environment" {
  type        = string
  description = "Deployment environment name"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "account_id" {
  type = string
}

variable "name_prefix" {
  type        = string
  description = "Prefix to be used for resource names"
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "ingest_function_arn" {
  description = "ARN of the Lambda ingestion function"
  type        = string
}

variable "schedule_expression" {
  description = "Cron expression for scheduled execution"
  type        = string
}

variable "schedule_timezone" {
  description = "Timezone for scheduled execution"
  type        = string
}