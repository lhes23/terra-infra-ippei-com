
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