data "aws_caller_identity" "current" { provider = aws.primary }
data "aws_partition" "current" { provider = aws.primary }
locals {
  names = { primary = "${var.project_prefix}-primary-${data.aws_caller_identity.current.account_id}", recovery = "${var.project_prefix}-recovery-${data.aws_caller_identity.current.account_id}" }
}
resource "aws_s3_bucket" "primary" {
  provider      = aws.primary
  bucket_prefix = "${local.names.primary}-"
  force_destroy = false
  tags          = { Purpose = "PrimaryAuditBackup", ManagedBy = "Terraform" }
}
resource "aws_s3_bucket" "recovery" {
  provider      = aws.recovery
  bucket_prefix = "${local.names.recovery}-"
  force_destroy = false
  tags          = { Purpose = "RecoveryAuditBackup", ManagedBy = "Terraform" }
}
resource "aws_s3_bucket_versioning" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_versioning" "recovery" {
  provider = aws.recovery
  bucket   = aws_s3_bucket.recovery.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "recovery" {
  provider = aws.recovery
  bucket   = aws_s3_bucket.recovery.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "primary" {
  provider                = aws.primary
  bucket                  = aws_s3_bucket.primary.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_public_access_block" "recovery" {
  provider                = aws.recovery
  bucket                  = aws_s3_bucket.recovery.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "primary" {
  provider   = aws.primary
  bucket     = aws_s3_bucket.primary.id
  policy     = jsonencode({ Version = "2012-10-17", Statement = [{ Sid = "EnforceTLS", Effect = "Deny", Principal = "*", Action = "s3:*", Resource = [aws_s3_bucket.primary.arn, "${aws_s3_bucket.primary.arn}/*"], Condition = { Bool = { "aws:SecureTransport" = "false" } } }] })
  depends_on = [aws_s3_bucket_public_access_block.primary]
}
resource "aws_s3_bucket_policy" "recovery" {
  provider   = aws.recovery
  bucket     = aws_s3_bucket.recovery.id
  policy     = jsonencode({ Version = "2012-10-17", Statement = [{ Sid = "EnforceTLS", Effect = "Deny", Principal = "*", Action = "s3:*", Resource = [aws_s3_bucket.recovery.arn, "${aws_s3_bucket.recovery.arn}/*"], Condition = { Bool = { "aws:SecureTransport" = "false" } } }] })
  depends_on = [aws_s3_bucket_public_access_block.recovery]
}
data "aws_iam_policy_document" "replication_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "replication" {
  provider           = aws.primary
  name_prefix        = "${var.project_prefix}-replication-"
  assume_role_policy = data.aws_iam_policy_document.replication_trust.json
}
data "aws_iam_policy_document" "replication" {
  statement {
    actions   = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
    resources = [aws_s3_bucket.primary.arn]
  }
  statement {
    actions   = ["s3:GetObjectVersionForReplication", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"]
    resources = ["${aws_s3_bucket.primary.arn}/*"]
  }
  statement {
    actions   = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"]
    resources = ["${aws_s3_bucket.recovery.arn}/*"]
  }
}
resource "aws_iam_role_policy" "replication" {
  provider = aws.primary
  name     = "replicate-to-recovery"
  role     = aws_iam_role.replication.id
  policy   = data.aws_iam_policy_document.replication.json
}
resource "aws_s3_bucket_replication_configuration" "primary" {
  provider = aws.primary
  role     = aws_iam_role.replication.arn
  bucket   = aws_s3_bucket.primary.id
  rule {
    id     = "backup-copy-to-recovery"
    status = "Enabled"
    filter { prefix = "" }
    destination {
      bucket        = aws_s3_bucket.recovery.arn
      storage_class = "STANDARD"
    }
    delete_marker_replication { status = "Disabled" }
  }
  depends_on = [aws_s3_bucket_versioning.primary, aws_s3_bucket_versioning.recovery, aws_iam_role_policy.replication]
}
