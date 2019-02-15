provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_db_instance" "pg-db" {
  name                = "${var.name}"
  allocated_storage   = 10
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "10.6"
  instance_class      = "db.t2.micro"
  publicly_accessible = true
  skip_final_snapshot = true
  username            = "${var.aws_db_username}"
  password            = "${var.aws_db_password}"
}
