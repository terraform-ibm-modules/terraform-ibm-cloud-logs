# IBM Cloud Log Router Agent (v3)

This module configures [IBM Cloud Logs Routing](https://cloud.ibm.com/docs/logs-router) using the **v3 API**. It creates:

1. An IAM service-to-service authorization policy granting the `logs-router` service `Sender` access to a Cloud Logs instance.
2. An `ibm_logs_router_target` — a named, account-global pointer to the Cloud Logs instance CRN.
3. One or more `ibm_logs_router_route` resources — each with ordered rules that filter platform logs by location and forward matching logs to one or more targets.

> **Key v3 concepts**
>
> - **Target** (`ibm_logs_router_target`): account-global resource; references a Cloud Logs instance by CRN.
> - **Route** (`ibm_logs_router_route`): account-global resource; contains up to 10 ordered rules. Each rule has `inclusion_filters` (currently `location`-based) and a list of target IDs to send matching logs to.
> - Rules are evaluated in order; the **first matching rule wins**.

## Usage

```hcl
module "logs_router" {
  source  = "terraform-ibm-modules/cloud-logs/ibm//modules/logs_router"
  version = "X.Y.Z" # Replace "X.Y.Z" with a release version

  cloud_logs_instance_crn = module.cloud_logs.crn
  target_name             = "my-cloud-logs-target"

  routes = [
    {
      name = "us-south-to-cloud-logs"
      rules = [
        {
          action = "send"
          targets = [
            {
              id   = module.log_router_agent.target_id
              crn  = module.log_router_agent.target_crn
              name = module.log_router_agent.target.name
            }
          ]
          inclusion_filters = [
            {
              operand  = "location"
              operator = "is"
              values   = ["us-south"]
            }
          ]
        }
      ]
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.2, < 3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_logs_routing_policy"></a> [logs\_routing\_policy](#module\_logs\_routing\_policy) | terraform-ibm-modules/s2s-auth/ibm | 2.3.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_logs_router_route.routes](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/logs_router_route) | resource |
| [ibm_logs_router_settings.settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/logs_router_settings) | resource |
| [ibm_logs_router_target.target](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/logs_router_target) | resource |
| [time_sleep.wait_for_auth_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_logs_instance_crn"></a> [cloud\_logs\_instance\_crn](#input\_cloud\_logs\_instance\_crn) | The CRN of the IBM Cloud Logs instance that log router targets will forward platform logs to. | `string` | n/a | yes |
| <a name="input_global_log_routing_settings"></a> [global\_log\_routing\_settings](#input\_global\_log\_routing\_settings) | Global account settings for logs routing. [Learn more](https://cloud.ibm.com/docs/logs-router?topic=logs-router-settings&interface=ui) | <pre>object({<br/>    default_targets           = optional(list(string), [])<br/>    primary_metadata_region   = optional(string)<br/>    backup_metadata_region    = optional(string)<br/>    permitted_target_regions  = optional(list(string), [])<br/>    private_api_endpoint_only = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | List of log router routes to create. Each route contains an ordered list of rules that are evaluated in sequence; the first matching rule is applied and the rest are skipped. | <pre>list(object({<br/>    name       = string<br/>    managed_by = optional(string)<br/>    rules = list(object({<br/>      action = optional(string, "send")<br/>      targets = list(object({<br/>        id = string<br/>      }))<br/>      inclusion_filters = list(object({<br/>        operand  = string<br/>        operator = string<br/>        values   = list(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_skip_logs_routing_auth_policy"></a> [skip\_logs\_routing\_auth\_policy](#input\_skip\_logs\_routing\_auth\_policy) | Set to true to skip creating the IAM service-to-service authorization policy that grants Logs Routing 'Sender' access to the Cloud Logs instance. Set to true only when the policy already exists. | `bool` | `false` | no |
| <a name="input_target_name"></a> [target\_name](#input\_target\_name) | The name to assign to the ibm\_logs\_router\_target resource. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_route_crns"></a> [route\_crns](#output\_route\_crns) | Map of route name to route CRN. |
| <a name="output_route_ids"></a> [route\_ids](#output\_route\_ids) | Map of route name to route UUID. |
| <a name="output_routes"></a> [routes](#output\_routes) | Full details of all IBM Cloud Log Router v3 routes created by this module. |
| <a name="output_target"></a> [target](#output\_target) | The full IBM Cloud Log Router v3 target resource. |
| <a name="output_target_crn"></a> [target\_crn](#output\_target\_crn) | The CRN of the IBM Cloud Log Router v3 target. |
| <a name="output_target_id"></a> [target\_id](#output\_target\_id) | The UUID of the IBM Cloud Log Router v3 target. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
