resource "aws_autoscaling_policy" "scale_up" {
  name                   = "Scaleup"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.public-autoscaling-group.name}"
}


resource "aws_autoscaling_policy" "scale_down" {
  name                   = "Scaledown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.public-autoscaling-group.name}"
}


resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpuhigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  insufficient_data_actions = []

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.public-autoscaling-group.name}"
  }

  alarm_actions     =  ["${aws_autoscaling_policy.scale_up.arn}"]
}


resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpulow"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"
  insufficient_data_actions = []

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.public-autoscaling-group.name}"
  }

  alarm_actions     =  ["${aws_autoscaling_policy.scale_down.arn}"]
}

 