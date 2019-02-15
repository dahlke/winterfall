output "id" {
  value = "${aws_db_instance.pg-db.id}"
}

output "db_address" {
  value = "${aws_db_instance.pg-db.address}"
}

output "db_port" {
  value = "${aws_db_instance.pg-db.port}"
}

output "db_name" {
  value = "${aws_db_instance.pg-db.name}"
}

output "db_username" {
  value = "${var.aws_db_username}"
}

output "db_password" {
  value = "${var.aws_db_password}"
}
