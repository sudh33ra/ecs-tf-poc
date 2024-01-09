# define Autoscaling Target
resource "aws_appautoscaling_target" "autoscaling_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${var.ecs_autoscale_role}"
  min_capacity       = "${var.min_capacity}"
  max_capacity       = "${var.max_capacity}"
}

# define Outscaling Policy
resource "aws_appautoscaling_policy" "outscaling_policy" {
  name               = "${var.name_prefix}-outscaling-policy"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 3
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.autoscaling_target"]
}

resource "aws_cloudwatch_metric_alarm" "outscaling_metric_alarm" {
  alarm_name          = "${var.name_prefix}-outscaling-metric-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
    ServiceName = "${aws_ecs_service.ecs_service.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.outscaling_policy.arn}"]
}

# define Downscaling Policy
resource "aws_appautoscaling_policy" "downscaling_policy" {
  name               = "${var.name_prefix}-downscaling-policy"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 3
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = ["aws_appautoscaling_target.autoscaling_target"]
}

resource "aws_cloudwatch_metric_alarm" "downscaling_metric_alarm" {
  alarm_name          = "${var.name_prefix}-downscaling-metric-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
    ServiceName = "${aws_ecs_service.ecs_service.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.downscaling_policy.arn}"]
}
