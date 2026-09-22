output "target_id" {
  value       = ibm_logs_router_target.target.id
  description = "The UUID of the IBM Cloud Log Router v3 target."
}

output "target_crn" {
  value       = ibm_logs_router_target.target.crn
  description = "The CRN of the IBM Cloud Log Router v3 target."
}

output "target" {
  value       = ibm_logs_router_target.target
  description = "The full IBM Cloud Log Router v3 target resource."
}

output "route_ids" {
  value       = { for name, route in ibm_logs_router_route.routes : name => route.id }
  description = "Map of route name to route UUID."
}

output "route_crns" {
  value       = { for name, route in ibm_logs_router_route.routes : name => route.crn }
  description = "Map of route name to route CRN."
}

output "routes" {
  value       = ibm_logs_router_route.routes
  description = "Full details of all IBM Cloud Log Router v3 routes created by this module."
}
