resource "pingone_application" "MOBILE" {
  environment_id = data.pingone_environment.env.id
  name           = "My Awesome Mobile App"
  enabled        = true

  oidc_options {
    type                        = "NATIVE_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    pkce_enforcement            = "S256_REQUIRED"
    token_endpoint_authn_method = "NONE"
    redirect_uris = [
      "https://demo.bxretail.org/app/callback",
      "org.bxretail.app://callback"
    ]

    mobile_app {
      bundle_id           = var.bundle_id
      package_name        = var.package_name
    }
  }
}
