terraform {
  required_version = ">= 1.6.0"
}

variable "primary_region" {
  type    = string
  default = "canadacentral"
}

variable "secondary_region" {
  type    = string
  default = "eastus"
}

locals {
  rto_minutes   = 30
  rpo_minutes   = 15
  failover_mode = "active-passive"
}

output "dr_strategy" {
  value = {
    primary_region   = var.primary_region
    secondary_region = var.secondary_region
    rto_minutes      = local.rto_minutes
    rpo_minutes      = local.rpo_minutes
    failover_mode    = local.failover_mode
  }
}
