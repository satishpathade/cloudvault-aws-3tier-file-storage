variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
  default = "cloudvault"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "web_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.32.0/20", "10.0.48.0/20"]
}

variable "app_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.64.0/20", "10.0.80.0/20"]
}

variable "db_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.96.0/20", "10.0.112.0/20"]
}

variable "cicd_instance_type" {
  type    = string
  default = "c7i-flex.large"
}

variable "web_instance_type" {
  type    = string
  default = "t3.small"
}

variable "app_instance_type" {
  type    = string
  default = "t3.small"
}

variable "web_min_size" {
  type    = number
  default = 1
}

variable "web_desired_size" {
  type    = number
  default = 1
}

variable "web_max_size" {
  type    = number
  default = 3
}

variable "app_min_size" {
  type    = number
  default = 1
}

variable "app_desired_size" {
  type    = number
  default = 1
}

variable "app_max_size" {
  type    = number
  default = 3
}

variable "db_name" {
  type    = string
  default = "cloudvaultdb"
}

variable "db_username" {
  type    = string
  default = "root"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "git_repo_url" {
  type    = string
  default = "https://github.com/satishpathade/cloudvault-aws-3tier-file-storage"
}

variable "key_name" {
  type    = string
  default = "CloudVault-CICD"
}

variable "tags" {
  type = map(string)

  default = {
    Project = "CloudVault"
  }
}