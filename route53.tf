#
# Private zone data
#
data aws_route53_zone private {
  zone_id      = var.route53_private_zone_id
  private_zone = true
}

#
# Private record
#
resource aws_route53_record mysql {
  zone_id = data.aws_route53_zone.private.zone_id
  name    = "${var.db_instance_name}.${data.aws_route53_zone.private.name}"
  type    = "A"
  alias {
    name                   = aws_db_instance.main.address
    zone_id                = aws_db_instance.main.hosted_zone_id
    evaluate_target_health = true
  }
}


#
# Public zone data
#
data aws_route53_zone public {
  zone_id              = var.route53_public_zone_id
}

#
# Public records
#
resource aws_route53_record backend {
  zone_id                  = data.aws_route53_zone.public.id
  name                     = "${var.backend_instance_name}.${data.aws_route53_zone.public.name}"
  type                     = "A"
  alias {
    name                   = data.aws_lb.main.dns_name
    zone_id                = data.aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
resource aws_route53_record frontend {
  zone_id                  = data.aws_route53_zone.public.id
  name                     = "${var.frontend_instance_name}.${data.aws_route53_zone.public.name}"
  type                     = "A"
  alias {
    name                   = data.aws_lb.main.dns_name
    zone_id                = data.aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
