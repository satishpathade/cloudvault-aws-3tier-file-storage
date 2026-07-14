resource "aws_secretsmanager_secret" "cloudvault" {
  name                    = "${var.project_name}-secret"
  recovery_window_in_days = 0
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "cloudvault" {

  secret_id = aws_secretsmanager_secret.cloudvault.id

  secret_string = jsonencode({
    DB_HOST     = var.db_host
    DB_NAME     = var.db_name
    DB_USERNAME = var.db_username
    DB_PASSWORD = var.db_password
    SECRET_KEY  = var.secret_key
    AWS_REGION  = var.aws_region
    S3_BUCKET   = var.s3_bucket
  })
}