variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The target AWS region for deployment"
}

variable "db_cluster_identifier" {
  type        = string
  default     = "aurora-mysql-cluster"
  description = "The base unique identifier naming your DB cluster"
}

variable "db_name" {
  type        = string
  default     = "appdb"
  description = "The initial database name created on startup"
}

variable "db_master_username" {
  type        = string
  default     = "dbadmin"
  description = "The master username for the database cluster"
}

variable "db_master_password" {
  type        = string
  sensitive   = true # Prevent password exposure in plan/apply logs
  description = "The database master security password (Injected at runtime via secrets/environment variables)"
}

# Map defining the hardware profile for each environment workspace
variable "db_instance_classes" {
  type = map(string)
  default = {
    dev     = "db.t4g.medium"  # Cost-efficient for sandbox testing
    staging = "db.r6g.large"   # Match production architectural layout
    prod    = "db.r6g.xlarge"  # High performance scale sizing
  }
}

# Map defining tag identification names per workspace
variable "environment_names" {
  type = map(string)
  default = {
    dev     = "development"
    staging = "staging"
    prod    = "production"
  }
}

variable "cpu_alarm_threshold" {
  type        = number
  default     = 80
  description = "The CPU utilization percentage threshold to trigger an alert"
}

variable "cpu_alarm_period" {
  type        = number
  default     = 300 # 5 minutes
  description = "The period in seconds over which the metric statistic is evaluated"
}