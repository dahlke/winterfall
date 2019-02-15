module "winterfall-aws-rds-db" {
  source = "../modules/aws/rds/pg-db"

  name            = "${var.project_name}"
  aws_region      = "${var.aws_region}"
  aws_db_username = "${var.aws_db_username}"
  aws_db_password = "${var.aws_db_password}"
}

module "winterfall-aws-eks-cluster" {
  source = "../modules/aws/eks"

  project_name = "${var.project_name}"
  aws_region   = "${var.aws_region}"
}
