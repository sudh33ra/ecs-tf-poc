# define Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.name_prefix}"

  tags {
    Name = "tranque-api" #TODO check how this name matches the container/task/service/cluster/?
  }
}

# define Log stream
resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${var.name_prefix}-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.log_group.name}"
}
