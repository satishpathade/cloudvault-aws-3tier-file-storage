resource "aws_s3_bucket" "this" {
  bucket = "${var.project_name}-file-storage"
  force_destroy = true

  tags = {
    project = var.project_name
    Name    = "${var.project_name}-file-storage"
  }
}

# Enable versioning

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CORS configuration

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_headers = ["*"]

    allowed_methods = [
      "GET",
      "PUT",
      "POST"
    ]

    allowed_origins = ["*"]

    expose_headers = ["ETag"]

    max_age_seconds = 3000
  }
}