output "primary_bucket" { value = aws_s3_bucket.primary.id }
output "recovery_bucket" { value = aws_s3_bucket.recovery.id }
output "replication_role_arn" { value = aws_iam_role.replication.arn }
output "dns_failover_enabled" { value = var.enable_dns_failover }
