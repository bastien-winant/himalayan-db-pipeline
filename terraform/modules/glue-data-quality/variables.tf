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

variable "cloudwatch_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
}

variable "glue_job_name" {
  description = "Name of the AWS Glue data quality job"
  type        = string
}

variable "glue_job_timeout" {
  description = "Timeout for the Glue job in minutes"
  type        = number

  validation {
    condition     = var.glue_job_timeout >= 1 && var.glue_job_timeout <= 2880
    error_message = "Glue job timeout must be between 1 and 2880 minutes (48 hours)."
  }
}

variable "glue_worker_type" {
  description = "Type of worker for Glue job (G.1X, G.2X, G.4X, G.8X, Z.2X)"
  type        = string

  validation {
    condition     = contains(["G.1X", "G.2X", "G.4X", "G.8X", "Z.2X"], var.glue_worker_type)
    error_message = "Worker type must be one of: G.1X, G.2X, G.4X, G.8X, Z.2X."
  }
}

variable "glue_number_of_workers" {
  description = "Number of workers for Glue job"
  type        = number

  validation {
    condition     = var.glue_number_of_workers >= 2 && var.glue_number_of_workers <= 299
    error_message = "Number of workers must be between 2 and 299."
  }
}

variable "data_bucket_name" {
  description = "Name of the created S3 data bucket"
  type        = string
}

variable "data_bucket_arn" {
  description = "ARN of the created S3 data bucket"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the created S3 artifacts bucket"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "ARN of the created S3 artifacts bucket"
  type        = string
}