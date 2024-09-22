provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "terravpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terravpc"
  }
}

# Subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.vpc_az)
  vpc_id                  = aws_vpc.terravpc.id
  cidr_block              = cidrsubnet(aws_vpc.terravpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.vpc_az, count.index)
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terravpc.id
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.terravpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
}

resource "aws_route_table_association" "public_association" {
  count          = length(var.vpc_az)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

# Security Group for ALB and EC2
resource "aws_security_group" "terra_alb_sg" {
  name   = "terra-alb-sg"
  vpc_id = aws_vpc.terravpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "terra_ec2_sg" {
  name   = "terra-ec2-sg"
  vpc_id = aws_vpc.terravpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.terra_alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "terra_alb" {
  name               = "terra-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terra_alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
}

# Target Group
resource "aws_lb_target_group" "terra_tg" {
  name     = "terra-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terravpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ALB Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.terra_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terra_tg.arn
  }
}

# Launch Template
resource "aws_launch_template" "terra_lt" {
  name          = "terra-lt"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  #   user_data     = filebase64("userdata.sh")

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.terra_ec2_sg.id]
  }
}

# Auto Scaling Group (ASG)
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


# Output the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.terra_alb.dns_name
}