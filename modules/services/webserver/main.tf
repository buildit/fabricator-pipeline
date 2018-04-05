data "aws_availability_zones" "available" {}

data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "${var.region}"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
  }
}
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
    "Name"        = "${var.cluster_name}-${var.environment}-vpc"
    "Environment" = "${var.environment}"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.public_subnet_cidr_block}"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = true

  tags {
    "Name"        = "${var.cluster_name}-${var.environment}-subnet-public"
    "Environment" = "${var.environment}"
  }
}

resource "aws_security_group" "webserver-sg" {
  description = "Security group for the web server"
  name        = "${var.cluster_name}-${var.environment}-webserver-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    "Name"        = "${var.cluster_name}-${var.environment}-webserver-sg"
    "Environment" = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_webserver_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.webserver-sg.id}"
  from_port         = "${var.server_port}"
  to_port           = "${var.server_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "lb-sg" {
  description = "Security group for the load balancer"
  name        = "${var.cluster_name}-${var.environment}-lb-sg"

  tags {
    "Name"        = "${var.cluster_name}-${var.environment}-lb-sg"
    "Environment" = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_http_inbound" {
  description       = "Security group ingress rule to allow all inbound traffic to the app load balancer on port 80."
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.lb-sg.id}"
}

resource "aws_security_group_rule" "allow_http_outbound" {
  description       = "Security group egress rule to allow all outbound traffic from the app load balancer."
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.lb-sg.id}"
}

resource "aws_launch_configuration" "launch_conf" {
  image_id        = "${lookup(var.region_to_ami, var.region)}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.webserver-sg.id}"]
  user_data       = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = "${aws_launch_configuration.launch_conf.id}"
  availability_zones   = ["${data.aws_availability_zones.available.names}"]
  load_balancers       = ["${aws_lb.app_load_balancer.name}"]
  health_check_type    = "ELB"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-${var.environment}-asg"
    propagate_at_launch = true
  }
}

resource "aws_lb" "app_load_balancer" {
  name            = "${var.cluster_name}-${var.environment}-lb"
  internal        = false
  security_groups = ["${aws_security_group.lb-sg.id}"]
  subnets         = ["${aws_subnet.subnet_public.id}"]

  enable_deletion_protection = false

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 1
    unhealthy_threshold = 1
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }

  tags {
    "Name"        = "${var.cluster_name}-${var.environment}-lb"
    "Environment" = "${var.environment}"
  }
}
