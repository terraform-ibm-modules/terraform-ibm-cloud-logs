terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.76.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.0"
    }
  }
}
