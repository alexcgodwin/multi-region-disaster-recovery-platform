# Failover Runbook

## Trigger

Use this runbook when the primary region is unavailable or the application fails health checks beyond the incident threshold.

## Steps

1. Confirm incident scope and record start time.
2. Freeze non-essential deployments.
3. Confirm latest backup or replicated data point.
4. Promote secondary region service endpoint.
5. Update DNS or traffic manager routing.
6. Validate application health, login, API and data path.
7. Notify stakeholders with RTO/RPO status.
8. Keep primary region isolated until root cause is understood.

## Rollback

If recovery validation fails, keep traffic on the secondary region, preserve evidence, and reverse the routing change only after the incident owner approves rollback.

## Recovery evidence

Capture health checks, DNS routing result, backup timestamp, application smoke test and post-failover resource state.
