variable "project_name" {
  description = "Used for naming things like the k8s namespace, PG DB, etc."
  type        = "string"
}

variable "aws_region" {
  type    = "string"
  default = "us-east-1"
}

variable "aws_db_username" {
  type = "string"
}

variable "aws_db_password" {
  type = "string"
}

variable "k8s_config_context_auth_info" {
  type = "string"
}

variable "k8s_config_context_cluster" {
  type = "string"
}
