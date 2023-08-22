terraform {
  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = "~> 0.19.1"
    }
  }

  required_version = "~> 1.4.6"
}

provider "pingone" {
  force_delete_production_type = false
}
