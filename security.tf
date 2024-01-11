# ALB security group
resource "aws_security_group" "load_balancer_sg" {
  name   = "${var.name_prefix}-alb-sg"
  vpc_id = "${aws_vpc.main_network.id}"

  ingress {
    protocol    = "tcp"
    from_port   = "${var.container_port}"
    cidr_blocks = ["0.0.0.0/0"]
    to_port   = "${var.container_port}"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS tasks security group
resource "aws_security_group" "ecs_tasks_sg" {
  name   = "${var.name_prefix}-ecs-tasks-sg"
  vpc_id = "${aws_vpc.main_network.id}"

  ingress {
    protocol        = "tcp"
    from_port   = "${var.container_port}"
    to_port   = "${var.container_port}"
    security_groups = ["${aws_security_group.load_balancer_sg.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
