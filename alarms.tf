resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60" # Set the threshold for CPU utilization
  alarm_description   = "This alarm triggers when CPU > 60%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.terra_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]
  ok_actions    = [aws_autoscaling_policy.scale_down_policy.arn]

  # Optional action when the alarm state changes to INSUFFICIENT_DATA
  insufficient_data_actions = []
}


resource "aws_cloudwatch_metric_alarm" "low_free_mem_alarm" {
  alarm_name          = "low-free-memory-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_free"
  namespace           = "CustomMetrics"
  period              = "60"
  statistic           = "Average"
  threshold           = 20 # Threshold for free memory in percentage
  alarm_description   = "This alarm triggers when free memory is <= 20%"

  # Use InstanceId as a dimension for memory-related metrics
  dimensions = {
    InstanceId = aws_autoscaling_group.terra_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up_policy_memory.arn]
}

# Alarm to remove 1 instance when free memory is greater than or equal to 70%
resource "aws_cloudwatch_metric_alarm" "high_free_mem_alarm" {
  alarm_name          = "high-free-memory-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_free"
  namespace           = "CustomMetrics"
  period              = "60"
  statistic           = "Average"
  threshold           = 70 # Threshold for free memory in percentage
  alarm_description   = "This alarm triggers when free memory is >= 70%"

  dimensions = {
    InstanceId = aws_autoscaling_group.terra_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down_policy_memory.arn]
}