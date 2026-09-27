# Multi-Region Disaster Recovery Platform

A resilience engineering project that demonstrates how to design, document and validate an active/passive disaster recovery platform with clear RTO/RPO targets.

![Disaster recovery architecture](assets/dr-architecture.svg)

## Executive Summary

This project focuses on recoverability, not only backups. It documents the operating path for detecting regional failure, deciding when to fail over, recovering service in a secondary region, validating the recovery path and preserving evidence.

## Problem

Many cloud systems have backups but no tested recovery workflow. During an incident, the missing parts are usually ownership, decision criteria, data-loss expectations, rollback steps and proof that the recovery path has been exercised.

## Engineering Scope

| Area | Implementation |
| --- | --- |
| Recovery model | Active/passive regional design |
| Objectives | RTO/RPO language and trade-off notes |
| Infrastructure | Terraform outputs and region variables |
| Operations | Failover runbook with operator steps |
| Evidence | Validation summary and local validation log |
| Cost control | Architecture and proof maintained from code without always-on duplicate spend |

## Repository Structure

| Path | Purpose |
| --- | --- |
| `terraform/` | DR strategy outputs and region variables |
| `runbooks/failover.md` | Step-by-step failover procedure |
| `scripts/validate.ps1` | Validation checks |
| `docs/evidence/` | Validation summary and evidence notes |
| `assets/` | Architecture visual used in the README |

## Validation

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate.ps1
```

## Production Expansion Path

- Add health checks tied to DNS failover or traffic manager.
- Add backup replication and restore testing for the selected data tier.
- Define incident commander, approver and rollback responsibilities.
- Schedule recovery exercises and retain evidence per environment.
- Track RTO/RPO performance after each exercise.

## Interview Defense

The important engineering decision is the separation between backup and recovery. A backup is only an asset. A recovery platform needs a tested path, a decision model, a runbook and proof. This repo is structured around that operating reality.

## Status

Validated as a cost-controlled disaster recovery design with reusable infrastructure, runbook and evidence artifacts.