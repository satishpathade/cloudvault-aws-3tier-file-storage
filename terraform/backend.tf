# terraform remote storage

terraform {
  backend "s3" {
    bucket  = "cloudvault-store-tfstate"
    key     = "terraform/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}