$ErrorActionPreference = 'Stop'

Write-Host '== Multi-Region Disaster Recovery local validation =='
terraform -chdir=terraform init -backend=false -input=false
terraform -chdir=terraform validate

$runbook = Get-Content runbooks/failover.md -Raw
if ($runbook -notmatch 'RTO' -or $runbook -notmatch 'RPO') {
  throw 'Runbook must document RTO and RPO.'
}

Write-Host 'Validation complete. No cloud resources were created.'
