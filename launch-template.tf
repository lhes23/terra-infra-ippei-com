# Launch Template
resource "aws_launch_template" "terra_lt" {
  name          = "terra-lt"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = filebase64("userdata.sh")

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.terra_ec2_sg.id]
  }
}
