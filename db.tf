resource aws_db_instance main {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  multi_az             = true
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [ aws_security_group.mysql.id ]
  identifier           = "${var.Name_tag_prefix}-db"
  skip_final_snapshot  = true
  tags = merge(var.tags,
    {
      Name = "${var.Name_tag_prefix}-db"
    }
  )
}

resource aws_db_subnet_group main {
  name       = "${var.Name_tag_prefix}-dbsg"
  subnet_ids = aws_subnet.nointernet.*.id

  tags = merge(var.tags,
    {
      Name = "${var.Name_tag_prefix}-dbsg"
    }
  )
}
