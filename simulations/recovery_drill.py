"""Reproducible local active-passive drill. No AWS credentials or external calls."""
from __future__ import annotations
import argparse
import json
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path

@dataclass(frozen=True)
class Checkpoint:
    sequence: int
    timestamp: float


def drill(*, approval: bool, primary_healthy: bool, recovery_healthy: bool,
          events: list[Checkpoint], replicated_through: int, max_rpo_s: int,
          simulate_recovery_seconds: float = 0.2) -> dict:
    if not approval:
        return {"decision": "REJECTED", "reason": "human_approval_required", "traffic_shifted": False}
    if primary_healthy:
        return {"decision": "REJECTED", "reason": "primary_is_healthy", "traffic_shifted": False}
    if not recovery_healthy:
        return {"decision": "REJECTED", "reason": "recovery_validation_failed", "traffic_shifted": False}
    if not events:
        return {"decision": "REJECTED", "reason": "no_recovery_checkpoint", "traffic_shifted": False}
    latest = max(events, key=lambda e: e.sequence)
    copies = [e for e in events if e.sequence <= replicated_through]
    if not copies:
        return {"decision": "REJECTED", "reason": "replica_missing", "traffic_shifted": False}
    replica = max(copies, key=lambda e: e.sequence)
    actual_rpo = max(0, latest.timestamp-replica.timestamp)
    if actual_rpo > max_rpo_s:
        return {"decision": "REJECTED", "reason": "rpo_policy_exceeded", "observed_rpo_seconds": actual_rpo, "traffic_shifted": False}
    start = time.monotonic()
    # Simulated non-cloud target switch plus deterministic application validation.
    if simulate_recovery_seconds < 0: raise ValueError("Invalid simulation duration")
    time.sleep(min(simulate_recovery_seconds, 1.0))
    elapsed = time.monotonic()-start
    return {"decision": "APPROVED", "mode": "SIMULATION_ONLY", "traffic_shifted": True,
            "last_primary_sequence": latest.sequence, "last_recovered_sequence": replica.sequence,
            "unreplicated_events": latest.sequence-replica.sequence,
            "observed_rpo_seconds": round(actual_rpo, 3),
            "measured_simulated_rto_seconds": round(elapsed, 3), "cloud_failover_executed": False}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--approve', action='store_true', help='Explicitly approve the simulated cutover')
    parser.add_argument('--max-rpo-seconds', type=int, default=900)
    parser.add_argument('--evidence', type=Path)
    args = parser.parse_args()
    events = [Checkpoint(i, float(1_000_000+i*30)) for i in range(1, 7)]
    result = drill(approval=args.approve, primary_healthy=False, recovery_healthy=True,
                   events=events, replicated_through=5, max_rpo_s=args.max_rpo_seconds)
    print(json.dumps(result, indent=2))
    if args.evidence:
        args.evidence.parent.mkdir(parents=True,exist_ok=True)
        args.evidence.write_text(json.dumps(result,indent=2)+'\n')
    return 0 if result['decision']=='APPROVED' else 2

if __name__=='__main__': raise SystemExit(main())
