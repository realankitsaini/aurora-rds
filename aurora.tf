# 1. DB Subnet Group Binding
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name        = "${var.environment}-aurora-subnet-group"
  description = "Static grouping of subnets associated with the database cluster"
  subnet_ids  = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
}

# 2. Aurora Cluster Core Storage Engine (With CloudWatch log streaming enabled)
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier   = var.db_cluster_identifier
  engine               = "aurora-mysql"
  engine_version       = "8.0.mysql_aurora.3.05.2"
  database_name        = var.db_name
  master_username      = var.db_master_username
  master_password      = var.db_master_password
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]
  
  # Exports engine errors and slow queries natively to CloudWatch Log Groups
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]

  skip_final_snapshot  = true 

  tags = {
    Name        = var.db_cluster_identifier
    Environment = var.environment
  }
}

# 3. Primary Cluster Node (Writer/Primary Instance)
resource "aws_rds_cluster_instance" "writer_instance" {
  identifier          = "${var.db_cluster_identifier}-writer"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = var.db_instance_class
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = false
}

# 4. Explicit Cluster Read Replica (Reader Instance)
resource "aws_rds_cluster_instance" "reader_replica_instance" {
  depends_on          = [aws_rds_cluster_instance.writer_instance]
  identifier          = "${var.db_cluster_identifier}-reader-replica"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = var.db_instance_class
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = false
}

# =========================================================================
# CLOUDWATCH ALARMS FOR CPU UTILIZATION
# =========================================================================

# 5. Monitor Primary Node CPU
resource "aws_cloudwatch_metric_alarm" "writer_cpu_high" {
  alarm_name          = "${var.db_cluster_identifier}-writer-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors Aurora Primary Writer instance CPU utilization"

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.writer_instance.id
  }
}

# 6. Monitor Read Replica CPU
resource "aws_cloudwatch_metric_alarm" "reader_cpu_high" {
  alarm_name          = "${var.db_cluster_identifier}-reader-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors Aurora Read Replica instance CPU utilization"

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.reader_replica_instance.id
  }
}