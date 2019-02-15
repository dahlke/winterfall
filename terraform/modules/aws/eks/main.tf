provider "aws" {
  region = "${var.aws_region}"
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  name    = "${var.project_name}"
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.53.0"

  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "${var.project_name}"
  }

  vpc_tags = {
    Name = "${var.project_name}"
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-eks
module "eks-cluster" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.project_name}"

  subnets = ["${concat(module.vpc.public_subnets, module.vpc.private_subnets)}"]
  vpc_id  = "${module.vpc.vpc_id}"

  worker_group_count = 1

  worker_groups = [
    {
      instance_type = "t2.small"
      asg_min_size  = 1
      asg_max_size  = 3
    },
  ]

  tags = {
    Name = "${var.project_name}"
  }
}
