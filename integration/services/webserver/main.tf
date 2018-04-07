terraform {
  backend "s3" {}
}

provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.aws_profile}"
}

module "webserver" {
  source                     = "../../../modules/services/webserver"
  vpc_cidr_block             = "${var.vpc_cidr_block}"
  public_subnet_a_cidr_block = "${var.public_subnet_a_cidr_block}"
  public_subnet_b_cidr_block = "${var.public_subnet_b_cidr_block}"
  cluster_name               = "${var.cluster_name}"
  environment                = "${var.environment}"
  instance_type              = "t2.micro"
  min_size                   = 1
  max_size                   = 1
}
