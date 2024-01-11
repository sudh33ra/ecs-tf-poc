[
  {
    "cpu": ${fargate_cpu},
    "essential": true,
    "image": "${app_image}",
    "memory": ${fargate_memory},
    "name": "${balanced_container_name}",
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${name_prefix}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "${name_prefix}-log-stream"
      }
    }
  }
]

