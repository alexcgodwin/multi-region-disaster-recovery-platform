# Multi-Region Disaster Recovery Platform

A resilience engineering project that defines and validates an active/passive recovery platform with clear RTO/RPO considerations, failover responsibilities and evidence.

## What I Built

- Active/passive multi-region recovery model.
- Infrastructure-as-code structure for primary and recovery responsibilities.
- Failover runbook covering decisions, traffic movement and verification.
- Evidence that distinguishes backup capability from tested recoverability.

## Recovery Workflow

1. Define RTO and RPO targets.
2. Prepare the secondary recovery region.
3. Detect failure through health and operational signals.
4. Execute the approved failover runbook.
5. Verify service, data and dependencies.
6. Review gaps and improve the recovery path.

## Repository Structure

| Path | Purpose |
| --- | --- |
| `terraform/` | DR strategy outputs and region variables. |
| `runbooks/` | Failover and recovery procedures. |
| `docs/evidence/` | Validation and recovery evidence. |
| `scripts/` | Repeatable validation commands. |

## Validation

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate.ps1
```

## Engineering Controls

| Control | Senior engineering concern |
| --- | --- |
| Objectives | RTO and RPO aligned to business impact. |
| Detection | Health signals and explicit recovery decisioning. |
| Execution | Owned failover runbook with verification steps. |
| Proof | Service, data and dependency recovery evidence. |

## Failure and Review Model

The design considers regional loss, dependency failure, stale data, incomplete failover and rollback conditions. Recovery is treated as an exercised operating capability, not a backup checkbox.

## Completed Result

A documented and validated recovery pattern with recovery objectives, infrastructure structure, failover procedures and evidence.

## Engineering Value

This project demonstrates recoverability planning, operational ownership, runbook discipline, failure validation and cost-aware resilience engineering.