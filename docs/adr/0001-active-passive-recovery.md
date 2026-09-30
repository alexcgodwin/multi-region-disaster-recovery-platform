# ADR 0001: Active/Passive Multi-Region Recovery

## Status
Accepted

## Context
The recovery design needs regional-failure protection without the standing cost of two continuously active production stacks.

## Decision
Use an active/passive recovery model. The primary region serves production traffic while the secondary region maintains the infrastructure and recovery responsibilities required to meet the documented RTO/RPO assumptions.

## Consequences
- Standing cost is lower than active/active operation.
- Failover is an explicit operational event with named validation steps.
- Recovery time includes detection, decision, traffic movement and service verification.
- Data freshness must be evaluated against the RPO before cutover.
- Rollback and failback criteria must be defined before recovery is declared complete.
