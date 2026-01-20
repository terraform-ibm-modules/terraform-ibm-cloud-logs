# Advanced example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cloud-logs-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cloud-logs/tree/main/examples/advanced"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


<!-- There is a pre-commit hook that will take the title of each example add include it in the repos main README.md  -->
<!-- Add text below should describe exactly what resources are provisioned / configured by the example  -->

Example that configures:

- A new resource group if one is not passed
- A Key Protect instance and root key
- 2 Event Notifications instances
- A COS instance and 2 KMS encrypted COS buckets (one for logs and one for metrics)
- A context-based restriction (CBR) zone for the Schematics service
- An IBM Cloud Logs instance with Event Notifications integration
- IBM Cloud Logs policies
- A context-based restriction (CBR) rule to only allow Cloud Logs to be accessible from the Schematics zone

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
