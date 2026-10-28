variable "primary_aws_region" { type = string }
variable "recovery_aws_region" { type = string }
variable "project_prefix" {
  type    = string
  default = "resilience-lab"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_prefix))
    error_message = "Use 3-21 lowercase letters, numbers and hyphens."
  }
}
variable "enable_dns_failover" {
  type        = bool
  default     = false
  description = "Optional Route53 failover using operator-provided domain and external endpoint IPv4 addresses. Additional AWS charges apply."
}
variable "hosted_zone_id" {
  type    = string
  default = ""
}
variable "record_name" {
  type    = string
  default = ""
}
variable "primary_ipv4" {
  type    = string
  default = ""
}
variable "recovery_ipv4" {
  type    = string
  default = ""
}
variable "primary_probe_hostname" {
  type    = string
  default = ""
}
variable "primary_probe_path" {
  type    = string
  default = "/health"
}
