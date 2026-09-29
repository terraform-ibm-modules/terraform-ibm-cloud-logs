########################################################################
# IBM Cloud Log Router v3
#########################################################################

# Log Router Targets

output "logs_router_targets" {
  value       = ibm_logs_router_target.targets
  description = "The created IBM Cloud Log Router v3 targets."
}

# Log Router Routes

output "logs_router_routes" {
  value       = ibm_logs_router_route.routes
  description = "The created IBM Cloud Log Router v3 routes."
}

# Log Router Global Settings

output "logs_router_settings" {
  value       = ibm_logs_router_settings.settings
  description = "The global IBM Cloud Log Router v3 settings."
}
