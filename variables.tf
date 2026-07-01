variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The target AWS region for deployment"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Tag to identify the environment classification"
}

variable "db_cluster_identifier" {
  type        = string
  default     = "aurora-mysql-cluster"
  description = "The unique identifier naming your DB cluster"
}

variable "db_name" {
  type        = string
  default     = "appdb"
  description = "The initial application database name created on startup"
}

variable "db_master_username" {
  type        = string
  default     = "dbadmin"
  description = "The master username for the database cluster"
}

variable "db_master_password" {
  type        = string
  default     = "P@sswordSecure2026!" # Replace this with a secure password or dynamic input variable
  sensitive   = true
  description = "The database master administrative security password"
}

variable "db_instance_class" {
  type        = string
  default     = "db.r6g.large"
  description = "The compute size class applied to both writer and reader cluster instances"
}

variable "cpu_alarm_threshold" {
  type        = number
  default     = 80
  description = "The CPU utilization percentage threshold to trigger an alert"
}

variable "cpu_alarm_period" {
  type        = number
  default     = 300 # 5 minutes
  description = "The period in seconds over which the metric statistic is applied"
}