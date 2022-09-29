resource "aws_route53_zone" "aws-prod" {
  name = var.domain
}

resource "aws_route53_record" "aws-prod-ns" {
  provider = aws.root
  zone_id  = data.aws_route53_zone.main_domain.zone_id
  name     = var.domain
  type     = "NS"
  ttl      = "30"
  records  = aws_route53_zone.aws-prod.name_servers
}
