terraform {
  backend "s3" {}
}

provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.aws_profile}"
}

module "webserver" {
  source                 = "../../../modules/services/webserver"
  cluster_name           = "${var.cluster_name}"
  db_remote_state_bucket = "${var.db_remote_state_bucket}"
  db_remote_state_key    = "${var.db_remote_state_key}"
  instance_type          = "t2.micro"
  min_size               = 1
  max_size               = 1
}
