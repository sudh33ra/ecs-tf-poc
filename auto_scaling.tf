resource "aws_iam_role" "ecs_autoscale_role" {
  name = "${var.name_prefix}-ecs-autoscale-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.application-autoscaling.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_autoscale_policy" {
  name        = "${var.name_prefix}-ecs-autoscale-policy"
  description = "Policy for ECS Auto Scaling"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:SetAlarmState",
        "cloudwatch:DeleteAlarms"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_policy_attachment" {
  policy_arn = aws_iam_policy.ecs_autoscale_policy.arn
  role       = aws_iam_role.ecs_autoscale_role.name
}

# define Autoscaling Target
resource "aws_appautoscaling_target" "autoscaling_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = aws_iam_role.ecs_autoscale_role.arn
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

  depends_on = [aws_appautoscaling_target.autoscaling_target]
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

  dimensions = {
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

  depends_on = [aws_appautoscaling_target.autoscaling_target]
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

  dimensions = {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
    ServiceName = "${aws_ecs_service.ecs_service.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.downscaling_policy.arn}"]
}
