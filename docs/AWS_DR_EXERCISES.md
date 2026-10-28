# AWS cross-region recovery implementation

The existing `terraform/` root documents the Azure conceptual model. The new `terraform/aws-dr` root independently implements a real AWS S3 cross-region replication pattern. It is **not** an Azure regional deployment and does not imply that the two region models are interchangeable.

## What can be provisioned

- Versioned private S3 buckets in two AWS regions, explicit primary and recovery provider aliases.
- SSE-S3, TLS-only bucket policies, public access block, replication service IAM role scoped to approved buckets.
- S3 Cross-Region Replication from primary to recovery, including access-controlled replication and disabled delete-marker replication.
- Optional Route53 active-passive routing to **existing** independently healthy service endpoints. DNS changes require an explicit switch, approvals and additional resource spend.

This storage example does **not** automatically restore databases, promote applications, or prove a complete service RTO/RPO. S3 replication is asynchronous and replication latency is not guaranteed by this design.

## Before applying

Use an isolated AWS account, least-privilege execution role, protected remote state, AWS budgets, two authorized regions, and a reviewed `terraform plan`. Copy `terraform.tfvars.example` outside Git to set values. `terraform -chdir=terraform/aws-dr init -backend=false` and `terraform -chdir=terraform/aws-dr validate` are safe offline checks. `terraform apply` creates chargeable infrastructure and is **not run in CI**. The buckets have `force_destroy=false`; cleanup requires a controlled data-retention decision.

## Local failure injection

Run `python -m unittest discover -s tests -v` and `python simulations/recovery_drill.py --approve --evidence artifacts/drill.json`. The local drill injects unavailable primary, stale replica and failed recovery health scenarios, blocks unauthorized cutovers, and measures simulated failover/RPO with explicit `SIMULATION_ONLY` flags.

## Live acceptance criteria (not yet verified)

1. Upload a unique object to primary and verify version-ID replication to secondary with evidence and latency.
2. Confirm access denied for unauthenticated and cross-account principals.
3. Demonstrate replication-status and backup consistency checks.
4. Run a real application failover with controlled DNS, synthetic traffic and business transaction checks, then measure observed RTO and RPO.
5. Exercise failback, preserve evidence and secure teardown. Until then, RTO/RPO targets remain objectives, not observed service guarantees.
