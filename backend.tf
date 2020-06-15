data template_file backend {
  template = "${file("${path.module}/backend-init.yaml")}"
  vars = {
    db_url = aws_route53_record.mysql.name,
    db_port = "3306",
    db_name = var.db_name,
    db_username = var.db_username,
    db_password = var.db_password
  }
}

resource aws_launch_configuration backend {
  name                 = "${var.Name_tag_prefix}-backend"
  image_id             = var.backend_ami
  instance_type        = var.backend_type
  key_name             = var.key_name
  user_data            = data.template_file.backend.rendered
  security_groups      = [aws_security_group.backend.id]
  iam_instance_profile = var.iam_instance_profile_name
}

/*
resource aws_instance test-backend {
  subnet_id            = data.aws_subnet.backend[0].id
  ami                  = var.backend_ami
  instance_type        = var.backend_type
  key_name             = var.key_name
  vpc_security_group_ids = []
  user_data     = data.template_file.backend.rendered
  tags = merge(var.tags,
    {
      Name = "${var.Name_tag_prefix}-test"
    }
  )
}
*/

resource aws_autoscaling_group backend {
  name                      = "${var.Name_tag_prefix}-backend-asg5"
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 5
  health_check_grace_period = 900
  health_check_type         = "ELB"
  default_cooldown          = 3600
  force_delete              = true
  launch_configuration      = aws_launch_configuration.backend.name
  vpc_zone_identifier       = data.aws_subnet.backend.*.id
  target_group_arns         = [aws_lb_target_group.backend.arn]

  timeouts {
    delete = "1m"
  }

  tag {
    key                 = "Name"
    value               = "${var.Name_tag_prefix}-backend"
    propagate_at_launch = true
  }
}

resource aws_autoscaling_policy backend_up {
  name                   = "${var.Name_tag_prefix}-backend-up"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  autoscaling_group_name = aws_autoscaling_group.backend.name
}

resource aws_autoscaling_policy backend_down {
  name                   = "${var.Name_tag_prefix}-backend-down"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  autoscaling_group_name = aws_autoscaling_group.backend.name
}
/*
*/

resource aws_lb_target_group backend {
  name     = "${var.Name_tag_prefix}-backend"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
  health_check {
    path = "/"
    matcher = "200,401"
  }
}

resource aws_lb_listener_rule backend {
  listener_arn = data.aws_lb_listener.main.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values           = [aws_route53_record.backend.name]
    }
  }
}
