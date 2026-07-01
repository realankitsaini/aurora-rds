# 1. DB Subnet Group Binding
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name        = "${terraform.workspace}-aurora-subnet-group"
  description = "Static grouping of subnets associated with the database cluster"
  subnet_ids  = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]

  tags = {
    Name        = "${terraform.workspace}-db-subnet-group"
    Environment = lookup(var.environment_names, terraform.workspace, "development")
  }
}

# 2. Aurora Cluster Core Storage Engine (With CloudWatch log streaming enabled)
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier   = "${terraform.workspace}-${var.db_cluster_identifier}"
  engine               = "aurora-mysql"
  engine_version       = "8.0"
  database_name        = var.db_name
  master_username      = var.db_master_username
  master_password      = var.db_master_password
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]
  
  # Streams database logs natively to CloudWatch Log Groups
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]
  skip_final_snapshot            = true 

  tags = {
    Name        = "${terraform.workspace}-aurora-cluster"
    Environment = lookup(var.environment_names, terraform.workspace, "development")
  }
}

# 3. Primary Cluster Node (Writer/Primary Instance)
resource "aws_rds_cluster_instance" "writer_instance" {
  identifier          = "${terraform.workspace}-${var.db_cluster_identifier}-writer"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = lookup(var.db_instance_classes, terraform.workspace, "db.t4g.medium")
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = false

  tags = {
    Name        = "${terraform.workspace}-aurora-primary-node"
    Role        = "writer"
    Environment = lookup(var.environment_names, terraform.workspace, "development")
  }
}

# 4. Explicit Cluster Read Replica (Reader Instance)
resource "aws_rds_cluster_instance" "reader_replica_instance" {
  depends_on          = [aws_rds_cluster_instance.writer_instance]
  identifier          = "${terraform.workspace}-${var.db_cluster_identifier}-reader"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = lookup(var.db_instance_classes, terraform.workspace, "db.t4g.medium")
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = false

  tags = {
    Name        = "${terraform.workspace}-aurora-replica-node"
    Role        = "reader"
    Environment = lookup(var.environment_names, terraform.workspace, "development")
  }
}

# =========================================================================
# CLOUDWATCH ALARMS FOR CPU UTILIZATION
# =========================================================================

# 5. Monitor Primary Node CPU
resource "aws_cloudwatch_metric_alarm" "writer_cpu_high" {
  alarm_name          = "${terraform.workspace}-${var.db_cluster_identifier}-writer-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors the Aurora Primary Writer instance CPU utilization"

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.writer_instance.id
  }
}

# 6. Monitor Read Replica CPU
resource "aws_cloudwatch_metric_alarm" "reader_cpu_high" {
  alarm_name          = "${terraform.workspace}-${var.db_cluster_identifier}-reader-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors the Aurora Read Replica instance CPU utilization"

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.reader_replica_instance.id
  }
}