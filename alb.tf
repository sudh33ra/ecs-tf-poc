# define ALB
resource "aws_alb" "alb" {
  name            = "${var.name_prefix}-alb"
  subnets         = [for subnet in aws_subnet.public_subnet : subnet.id]
  security_groups = ["${aws_security_group.load_balancer_sg.id}"]
}

resource "aws_alb_target_group" "alb_target_group" {
  name        = "${var.name_prefix}-alb-target-group"
  port        = "${var.container_port}"
  protocol    = "${var.alb_protocol}"
  vpc_id      = "${aws_vpc.main_network.id}"
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    timeout             = "3"
    interval            = "5"
    protocol            = "${var.alb_protocol}"
    matcher             = "200"
    path                = "${var.healthcheck_path}"
  }
}

resource "aws_alb_listener" "load_balancer_listener" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "${var.container_port}"
  protocol          = "${var.alb_protocol}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
    type             = "forward"
  }
}
