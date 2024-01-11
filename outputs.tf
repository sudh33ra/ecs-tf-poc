# get ALB DNS name
output "alb_hostname" {
  value = "${aws_alb.alb.dns_name}:${var.container_port}"
}
