# Advanced example

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
