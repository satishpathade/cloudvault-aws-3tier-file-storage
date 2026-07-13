variable "project_name" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "tags" {
  type = map(string)
}