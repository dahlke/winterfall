output "db_id" {
  value = "${module.winterfall-aws-rds-db.id}"
}

output "db_address" {
  value = "${module.winterfall-aws-rds-db.db_address}"
}

output "db_port" {
  value = "${module.winterfall-aws-rds-db.db_port}"
}

output "db_name" {
  value = "${module.winterfall-aws-rds-db.db_name}"
}

output "db_username" {
  value = "${module.winterfall-aws-rds-db.db_username}"
}

output "db_password" {
  value = "${module.winterfall-aws-rds-db.db_password}"
}

output "k8s_config_context_cluster" {
  value = "${var.k8s_config_context_cluster}"
}
