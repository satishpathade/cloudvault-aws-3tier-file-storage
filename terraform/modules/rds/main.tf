resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-db"
  allocated_storage = 20
  engine         = "mysql"
  engine_version = "8.0"

  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]
  multi_az            = true
  publicly_accessible = false
  skip_final_snapshot = true
  storage_encrypted   = true
  tags = var.tags
}