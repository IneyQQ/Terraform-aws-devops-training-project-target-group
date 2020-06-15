resource aws_security_group mysql {
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [ aws_security_group.backend.id ]
  }

  tags = merge(var.tags,
    {
      Name = "${var.Name_tag_prefix}-mysql-sg"
    }
  )
}

resource aws_security_group backend {
  description = "Allow backend traffic"
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port = 8081
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [data.aws_security_group.lb.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    {
      Name = "${var.Name_tag_prefix}-backend-sg"
    }
  )
}

resource aws_security_group frontend {
  description = "Allow frontend traffic"
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [data.aws_security_group.lb.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    {
      Name = "${var.Name_tag_prefix}-frontend-sg"
    }
  )
}

data aws_security_group lb {
  id = var.lb_security_group_id
}
