output "lb_dns_name" {
  value = "${aws_lb.app_load_balancer.dns_name}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.asg.name}"
}

output "lb_security_group_id" {
  value = "${aws_security_group.lb-sg.id}"
}
