data aws_subnet backend {
  count = length(var.backend_subnet_ids)
  id = var.backend_subnet_ids[count.index]
}

data aws_subnet frontend {
  count = length(var.frontend_subnet_ids)
  id = var.frontend_subnet_ids[count.index]
}

data aws_subnet db {
  count = length(var.db_subnet_ids)
  id = var.db_subnet_ids[count.index]
}

data aws_vpc main {
  id = data.aws_subnet.backend[0].vpc_id
}

