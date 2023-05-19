data "pingone_environment" "env" {
  environment_id = var.environment_id
}

data "pingone_licenses" "licenses" {
  organization_id = data.pingone_environment.env.organization_id

  data_filter {
    name   = "status"
    values = ["ACTIVE"]
  }
}

locals {
  license_id = data.pingone_licenses.licenses
}