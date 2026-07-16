variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "cicd_instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "cicd_sg_id" {
  type = string
}

variable "k8s_common_sg_id" {
  type = string
}
