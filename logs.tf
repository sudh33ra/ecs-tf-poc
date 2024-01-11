# Define Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.name_prefix}"

  tags = {
    Name = "${var.balanced_container_name}"
  }
}

# Define Log stream
resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${var.name_prefix}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

