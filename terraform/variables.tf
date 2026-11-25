variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix to be used for resource names"
  default     = "himalayan-db"
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project   = "HimalayanDB"
    ManagedBy = "Terraform"
  }
}

variable "cloudwatch_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}

variable "schedule_expression" {
  description = "Cron expression for scheduled execution"
  type        = string
  default     = "cron(30 16 * * ? *)"
}

variable "schedule_timezone" {
  description = "Timezone for scheduled execution"
  type        = string
  default     = "Europe/Luxembourg"
}

variable "glue_job_name" {
  description = "Name of the AWS Glue data quality job"
  type        = string
  default     = "data-quality-sample-job"
}

variable "glue_job_timeout" {
  description = "Timeout for the Glue job in minutes"
  type        = number
  default     = 60

  validation {
    condition     = var.glue_job_timeout >= 1 && var.glue_job_timeout <= 2880
    error_message = "Glue job timeout must be between 1 and 2880 minutes (48 hours)."
  }
}

variable "glue_worker_type" {
  description = "Type of worker for Glue job (G.1X, G.2X, G.4X, G.8X, Z.2X)"
  type        = string
  default     = "G.1X"

  validation {
    condition     = contains(["G.1X", "G.2X", "G.4X", "G.8X", "Z.2X"], var.glue_worker_type)
    error_message = "Worker type must be one of: G.1X, G.2X, G.4X, G.8X, Z.2X."
  }
}

variable "glue_number_of_workers" {
  description = "Number of workers for Glue job"
  type        = number
  default     = 2

  validation {
    condition     = var.glue_number_of_workers >= 2 && var.glue_number_of_workers <= 299
    error_message = "Number of workers must be between 2 and 299."
  }
}