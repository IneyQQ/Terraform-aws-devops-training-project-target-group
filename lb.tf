data aws_lb_listener main {
  arn                      = var.lb_listener_arn
}

data aws_lb main {
  arn                      = data.aws_lb_listener.main.load_balancer_arn
}

