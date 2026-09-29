########################################################################
# Logs Router Primary Metadata Region
#########################################################################

data "ibm_iam_auth_token" "token" {}

data "external" "get_primary_metadata_region" {
  program = ["python3", "${path.module}/scripts/primary_metadata_region.py"]

  query = {
    iam_access_token     = sensitive(data.ibm_iam_auth_token.token.iam_access_token)
    use_private_endpoint = var.use_private_endpoint
  }
}
