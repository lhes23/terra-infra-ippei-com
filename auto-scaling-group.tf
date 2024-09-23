resource "aws_autoscaling_group" "terra_asg" {
  name                = "terra-asg"
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  vpc_zone_identifier = aws_subnet.public_subnet[*].id
  target_group_arns   = [aws_lb_target_group.terra_tg.arn]
  launch_template {
    id      = aws_launch_template.terra_lt.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "terra-web-server"
    propagate_at_launch = true
  }
}