# Scale up when CPU utilization > 60%
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1 # Number of instances to add
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 # Time to wait before another scaling activity
  autoscaling_group_name = aws_autoscaling_group.terra_asg.name
}

# Scale down when CPU utilization is lower
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1 # Number of instances to remove
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.terra_asg.name
}

# Alarm to add 1 instance when free memory is less than or equal to 20%


# Scale up when memory utilization is <= 20% (free memory is low)
resource "aws_autoscaling_policy" "scale_up_policy_memory" {
  name                   = "scale-up-policy-memory"
  scaling_adjustment     = 1 # Add one instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 # Time to wait before another scaling activity
  autoscaling_group_name = aws_autoscaling_group.terra_asg.name
}

# Scale down when memory utilization is >= 70% (free memory is high)
resource "aws_autoscaling_policy" "scale_down_policy_memory" {
  name                   = "scale-down-policy-memory"
  scaling_adjustment     = -1 # Remove one instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 # Time to wait before another scaling activity
  autoscaling_group_name = aws_autoscaling_group.terra_asg.name
}
