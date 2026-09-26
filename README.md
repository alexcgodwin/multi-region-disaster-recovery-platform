# Multi-Region Disaster Recovery Platform

A cloud resilience project that demonstrates active/passive recovery design, infrastructure-as-code repeatability, backup validation, failover runbooks, and recovery evidence.

## What this proves

- RTO/RPO-driven architecture
- Multi-region infrastructure planning
- DNS failover and health-check based routing
- Backup, restore and validation workflow
- Operational runbooks for incident response

## Architecture

Primary region hosts the production workload. Secondary region keeps recovery infrastructure ready with replicated data, prepared network controls, and documented failover steps.

## Cost rule

The project is designed to avoid permanent standby compute. Validation can be done with temporary resources and destroyed immediately after proof capture.
