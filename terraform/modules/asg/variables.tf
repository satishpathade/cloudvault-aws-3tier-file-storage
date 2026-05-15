variable "project_name" {
  type = string
}

# Web ASG

variable "web_subnet_ids" {
  type = list(string)
}

variable "web_sg_id" {
  type = string
}

variable "web_instance_type" {
  type = string
}

variable "web_desired_size" {
  type = number
}

variable "web_min_size" {
  type = number
}

variable "web_max_size" {
  type = number
}

# App ASG

variable "app_subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "app_desired_size" {
  type = number
}

variable "app_min_size" {
  type = number
}

variable "app_max_size" {
  type = number
}

# Common

variable "instance_profile_name" {
  type = string
  
}

variable "key_name" {
  type = string
}

variable "tags" {
  type = map(string)
}