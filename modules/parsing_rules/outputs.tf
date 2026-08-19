output "parsing_rule_groups_details" {
  value       = length(var.parsing_rules) > 0 ? ibm_logs_rule_group.parsing_rule_groups : null
  description = "The details of the IBM Cloud Logs parsing rule groups created."
}
