variable "name_prefix" {
  default = "dev-myapp"
}

variable "aws_region" {
  default = "us-east-1"
}


variable "az_count" {
  default = "2"
}

variable "healthcheck_path" {
  default = "/"
}

variable "ecs_task_execution_role" {
  default = null 
}

variable "ecs_autoscale_role" {
  default = null 
}

variable "min_capacity" {
  default = "2"
}

variable "max_capacity" {
  default = "5"
}

variable "container_port" {
  default = "80"
}

variable "alb_protocol" {
  default = "HTTP"
}

variable "balanced_container_name" {
  default = "myapp-api"
}

variable "app_image" {
  default = "lvthillo/python-flask-docker:latest"
}

variable "fargate_cpu" {
  default = "1024"
}

variable "fargate_memory" {
  default = "2048"
}
