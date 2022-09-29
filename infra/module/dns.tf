resource "aws_route53_record" "backend" {
  allow_overwrite = true
  name            = var.domain
  type            = "A"
  zone_id         = var.r53_zone_id
  alias {
    name                   = aws_lb.public_lb.dns_name
    zone_id                = aws_lb.public_lb.zone_id
    evaluate_target_health = true
  }

  geolocation_routing_policy {
    continent = var.r53_continent != "*" ? var.r53_continent : null
    country   = var.r53_continent == "*" ? var.r53_continent : null
  }
  set_identifier = var.stack_name
}