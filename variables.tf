#
# Tags
#
variable tags {
  type = map
  default = {}
  description = "A map of tags to add to all resources"
}
variable Name_tag_prefix {
  description = "Prefix for tag 'Name' and some named resources"
}

#
# DB
#
variable db_username {}
variable db_password {}
variable db_name {}

#
# Instances vars
#
variable frontend_subnet_ids {
  type = list(string)
}
variable backend_subnet_ids {
  type = list(string)
}
variable db_subnet_ids {
  type = list(string)
}
variable frontend_instance_name {
  default = "frontend"
}
variable backend_instance_name {
  default = "backend"
}
variable db_instance_name {
  default = "db"
}
variable backend_sg_ids {
  type = list(string)
  default = []
}
variable frontend_sg_ids {
  type = list(string)
  default = []
}
variable route53_private_zone_id {}
variable iam_instance_profile_name {}
variable key_name {}
variable backend_ami {
  default = "ami-54550b2b"
}
variable backend_type {
  default = "t2.micro"
}
variable frontend_ami {
  default = "ami-54550b2b"
}
variable frontend_type {
  default = "t2.micro"
}
variable logstash_host_port {}

#
# Public access vars
#
variable route53_public_zone_id {}
variable lb_listener_arn {}
variable lb_security_group_id {}
