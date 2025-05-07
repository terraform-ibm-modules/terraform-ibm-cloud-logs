output "logs_policies_details" {
  value       = length(var.policies) > 0 ? ibm_logs_policy.logs_policies : null
  description = "The details of the Cloud logs policies created."
}
