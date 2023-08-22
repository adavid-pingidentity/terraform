resource "pingone_application" "app" {
  environment_id = data.pingone_environment.env.id
  name           = "Passkeys Example App"
  enabled        = true

  oidc_options {
    type                        = "NATIVE_APP"
    grant_types                 = ["AUTHORIZATION_CODE", "IMPLICIT"]
    response_types              = ["CODE", "TOKEN", "ID_TOKEN"]
    pkce_enforcement            = "S256_REQUIRED"
    token_endpoint_authn_method = "NONE"
    redirect_uris = [
      "com.example.app://callback",
      "https://example.com"
    ]
  }
}

data "pingone_resource" "resource_pingone_api" {
  environment_id = data.pingone_environment.env.id

  name = "PingOne API"
}

data "pingone_resource_scope" "scope_create_device" {
  environment_id = data.pingone_environment.env.id
  resource_id = data.pingone_resource.resource_pingone_api.id

  name = "p1:create:device"
}

resource "pingone_application_resource_grant" "resource_grant1" {
  environment_id = data.pingone_environment.env.id
  application_id = pingone_application.app.id

  resource_id = data.pingone_resource.resource_pingone_api.id

  scopes = [
    data.pingone_resource_scope.scope_create_device.id
  ]
}

# OIDC request:
# https://auth.pingone.com/f59504de-3c45-4a37-8d70-d5ad75dfaaa0/as/authorize?scope=profile&client_id=84c6d61f-52f2-45fd-8119-73aaed490242&redirect_uri=https://example.com&response_type=id_token token&prompt=login&grant_type=implicit

resource "pingone_mfa_policy" "mfa_policy" {
  environment_id = data.pingone_environment.env.id
  name           = "Passkeys Example MFA Policy"

  # assuming Passkey FIDO policy is the default FIDO policy for the env
  fido2 {
    enabled = true
  }

  mobile {
    enabled = false
  }

  totp {
    enabled = false
  }

  sms {
    enabled = false
  }

  voice {
    enabled = false
  }

  email {
    enabled = false
  }
}

resource "pingone_sign_on_policy" "passkey_authn_policy" {
  environment_id = data.pingone_environment.env.id

  name        = "Passkeys_Example_AuthN_Policy"
  description = "Authentication policy that requires only username and passkey"
}

resource "pingone_sign_on_policy" "password_authn_policy" {
  environment_id = data.pingone_environment.env.id

  name        = "Username_Password_Example_AuthN_Policy"
  description = "Authentication policy that requires username and password"
}

resource "pingone_sign_on_policy_action" "password_action" {
  environment_id    = data.pingone_environment.env.id
  sign_on_policy_id = pingone_sign_on_policy.password_authn_policy.id

  priority = 1

  login {
    
  }
}

resource "pingone_sign_on_policy_action" "passkey_action" {
  environment_id    = data.pingone_environment.env.id
  sign_on_policy_id = pingone_sign_on_policy.passkey_authn_policy.id

  priority = 1

  mfa {
    device_sign_on_policy_id = pingone_mfa_policy.mfa_policy.id
  }
}

resource "pingone_application_sign_on_policy_assignment" "policy_assignment1" {
  environment_id = data.pingone_environment.env.id
  application_id = pingone_application.app.id

  sign_on_policy_id = pingone_sign_on_policy.passkey_authn_policy.id

  priority = 1
}

resource "pingone_application_sign_on_policy_assignment" "policy_assignment2" {
  environment_id = data.pingone_environment.env.id
  application_id = pingone_application.app.id

  sign_on_policy_id = pingone_sign_on_policy.password_authn_policy.id

  priority = 2
}