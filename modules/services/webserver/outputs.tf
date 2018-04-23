
output "web_server_ip" {
  value = "${aws_instance.web-server.private_ip}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_security_group_id" {
  value = "${aws_security_group.webserver-sg.id}"
}

output "vpc_private_subnet_id" {
  value = "${aws_subnet.subnet_private.id}"
}