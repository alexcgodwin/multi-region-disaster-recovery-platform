from pathlib import Path
import sys
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'simulations'))
from recovery_drill import Checkpoint, drill

SAMPLE=[Checkpoint(i, 1000+i*10) for i in range(1,6)]
class RecoveryTests(unittest.TestCase):
 def kwargs(self, **override):
  base=dict(approval=True,primary_healthy=False,recovery_healthy=True,events=SAMPLE,replicated_through=4,max_rpo_s=25,simulate_recovery_seconds=0)
  base.update(override)
  return base
 def test_requires_human_approval(self):
  self.assertEqual('human_approval_required',drill(**self.kwargs(approval=False))['reason'])
 def test_does_not_failover_healthy_primary(self):
  self.assertEqual('primary_is_healthy',drill(**self.kwargs(primary_healthy=True))['reason'])
 def test_requires_recovery_checks(self):
  self.assertEqual('recovery_validation_failed',drill(**self.kwargs(recovery_healthy=False))['reason'])
 def test_blocks_stale_replication(self):
  self.assertEqual('rpo_policy_exceeded',drill(**self.kwargs(replicated_through=1))['reason'])
 def test_records_distinct_rpo_and_rto(self):
  result=drill(**self.kwargs())
  self.assertEqual('SIMULATION_ONLY',result['mode'])
  self.assertTrue(result['traffic_shifted'])
  self.assertEqual(10,result['observed_rpo_seconds'])
  self.assertEqual(1,result['unreplicated_events'])
  self.assertFalse(result['cloud_failover_executed'])

if __name__=='__main__':unittest.main()
