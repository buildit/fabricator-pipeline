terraform {
  backend "s3" {}
}

provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.aws_profile}"
}

module "webserver" {
  source                    = "../../../modules/services/webserver"
  vpc_cidr_block            = "${var.vpc_cidr_block}"
  cluster_name              = "${var.cluster_name}"
  environment               = "${var.environment}"
  public_subnet_cidr_block  = "${var.public_subnet_cidr_block}"
  ssh_cidr_block            = "${var.ssh_cidr_block}"
  key_pair_name             = "${var.key_pair_name}"
  instance_type             = "t2.micro"
}

resource "aws_eip" "nat-eip" {
  vpc = true

  tags {
    "Name"        = "${var.cluster_name}-${var.environment}-nat-eip"
    "Environment" = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat-eip.id}"
  subnet_id     = "${module.webserver.subnet_public_id}"

  tags {
    "Name"        = "${var.cluster_name}-${var.environment}-nat"
    "Environment" = "${var.environment}"
  }
}

resource "aws_subnet" "subnet_private" {
  vpc_id                  = "${module.webserver.vpc_id}"
  cidr_block              = "${var.private_subnet_cidr_block}"
  availability_zone       = "${module.webserver.availability_zone_name_zero}"
  map_public_ip_on_launch = false

  tags {
    "Name"        = "${var.cluster_name}-${var.environment}-subnet-private"
    "Environment" = "${var.environment}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${module.webserver.vpc_id}"

  tags {
    "Name"        = "${var.cluster_name}-${var.environment}-private-route-table"
    "Environment" = "${var.environment}"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

# Associate subnet private subnet to private route table
resource "aws_route_table_association" "subnet_private_association" {
  subnet_id      = "${aws_subnet.subnet_private.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}
