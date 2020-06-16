data template_file frontend {
  template = "${file("${path.module}/frontend-init.yaml")}"
  vars = {
    backend_url = "http://${aws_route53_record.backend.name}"
  }
}

resource aws_launch_configuration frontend {
  name          = "${var.Name_tag_prefix}-frontend"
  image_id      = var.frontend_ami
  instance_type = var.frontend_type
  security_groups = concat([aws_security_group.frontend.id], var.frontend_sg_ids)
  key_name      = var.key_name
  user_data     = data.template_file.frontend.rendered
  iam_instance_profile = var.iam_instance_profile_name
}

/*
resource aws_instance test-frontend {
  subnet_id     = aws_subnet.public[0].id
  ami           = var.frontend_ami
  instance_type = var.frontend_type
  key_name      = var.key_name
  vpc_security_group_ids = []
  user_data     = data.template_file.frontend.rendered
  tags = merge(var.tags,
    {
      Name = "${var.Name_tag_prefix}-test"
    }
  )
}
*/

resource aws_autoscaling_group frontend {
  name                      = "${var.Name_tag_prefix}-frontend-asg"
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 5
  health_check_grace_period = 600 
  health_check_type         = "ELB"
  default_cooldown          = 3600
  force_delete              = true
  launch_configuration      = aws_launch_configuration.frontend.name
  vpc_zone_identifier       = data.aws_subnet.frontend.*.id
  target_group_arns         = [aws_lb_target_group.frontend.arn]

  timeouts {
    delete = "5m"
  }

  tag {
    key                 = "Name"
    value               = "${var.Name_tag_prefix}-frontend"
    propagate_at_launch = true
  }
}

resource aws_autoscaling_policy frontend_up {
  name                   = "${var.Name_tag_prefix}-frontend-up"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  autoscaling_group_name = aws_autoscaling_group.frontend.name
}

resource aws_autoscaling_policy frontend_down {
  name                   = "${var.Name_tag_prefix}-frontend-down"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  autoscaling_group_name = aws_autoscaling_group.frontend.name
}
/*
*/

resource aws_lb_target_group frontend {
  name     = "${var.Name_tag_prefix}-frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
  health_check {
    path = "/"
    matcher = "200"
  }
}

resource aws_lb_listener_rule frontend {
  listener_arn = data.aws_lb_listener.main.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values           = [aws_route53_record.frontend.name]
    }
  }
}

