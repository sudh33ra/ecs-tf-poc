# define Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}-cluster"
}

# define Task
data "template_file" "template_container_definitions" {
  template = "${file("container-definitions.json.tpl")}"

  vars {
    app_image      = "${var.app_image}"
    fargate_cpu    = "${var.fargate_cpu}"
    fargate_memory = "${var.fargate_memory}"
    aws_region     = "${var.aws_region}"
    app_port       = "${var.container_port}"
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.name_prefix}-task"
  execution_role_arn       = "${var.ecs_task_execution_role}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${data.template_file.template_container_definitions.rendered}"
}

# define Service
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.name_prefix}-service"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.ecs_task.arn}"
  desired_count   = "${var.min_capacity}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.ecs_tasks_sg.id}"]
    subnets          = ["${aws_subnet.private_subnet.*.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
    container_name   = "${var.balanced_container_name}"
    container_port   = "${var.container_port}"
  }

  depends_on = ["aws_alb_listener.load_balancer_listener"]
}
