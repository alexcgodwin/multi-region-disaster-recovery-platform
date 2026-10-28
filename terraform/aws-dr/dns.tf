# DNS is optional because records can switch production traffic. No DNS creates by default.
resource "aws_route53_health_check" "primary" {
  count             = var.enable_dns_failover ? 1 : 0
  provider          = aws.primary
  type              = "HTTPS"
  fqdn              = var.primary_probe_hostname
  port              = 443
  resource_path     = var.primary_probe_path
  request_interval  = 30
  failure_threshold = 3
  tags              = { ManagedBy = "Terraform", Project = var.project_prefix }
  lifecycle {
    precondition {
      condition     = !var.enable_dns_failover || (var.primary_probe_hostname != "" && var.hosted_zone_id != "" && var.record_name != "" && can(cidrhost("${var.primary_ipv4}/32", 0)) && can(cidrhost("${var.recovery_ipv4}/32", 0)))
      error_message = "Configure the reviewed hosted zone, full record name, endpoint IPv4 addresses and probe hostname."
    }
  }
}
resource "aws_route53_record" "primary" {
  count           = var.enable_dns_failover ? 1 : 0
  provider        = aws.primary
  zone_id         = var.hosted_zone_id
  name            = var.record_name
  type            = "A"
  ttl             = 60
  records         = [var.primary_ipv4]
  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.primary[0].id
  failover_routing_policy { type = "PRIMARY" }
}
resource "aws_route53_record" "secondary" {
  count          = var.enable_dns_failover ? 1 : 0
  provider       = aws.primary
  zone_id        = var.hosted_zone_id
  name           = var.record_name
  type           = "A"
  ttl            = 60
  records        = [var.recovery_ipv4]
  set_identifier = "recovery"
  failover_routing_policy { type = "SECONDARY" }
}
