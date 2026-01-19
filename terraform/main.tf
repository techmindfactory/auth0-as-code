terraform {

# We have to indicate that we want to use Auth0 Terraform Provider and specify its version:
required_providers { 
    auth0 = {
      source  = "auth0/auth0"
      version = ">= 1.36.0"
    }
  }
}

# We have to provide credentials so Auth0 Terraform Provider can access our tenant using Auth0 Management API:
provider "auth0" {
  domain = var.auth0_domain
  client_id = var.auth0_client_id
  client_secret = var.auth0_client_secret
}


### Auth0 Tenant Initial Config

# Here we can define our Auth0 tenant settings. In this case we want to enable "en" locale for our tenant:
resource "auth0_tenant" "tenant_configuration" {
   enabled_locales = ["en"]
}


### Auth0 Web Applications

# Here we define Auth0 client which will be a web application.
resource "auth0_client" "sample_web_app" {
  name        = var.sample_web_app_name # Here we have to provide the name of the app. It will be taken from the "sample_web_app_name" variable defined in "tfvars" files under "vars" folder.
  app_type    = "regular_web" # We have to define the type of the client. In this case it is web application.
  oidc_conformant = true # We want this app to support OIDC standard for authentication.

  # Below we have to provide callback and logout URLs for the web application:
  callbacks           = var.sample_web_app_callbacks
  allowed_logout_urls = var.sample_web_app_logout_urls

  # Here we can define grant types. We want to support only authoirzation code glow and refresh token flow:
  grant_types = [
    "authorization_code",
    "refresh_token"
  ]

  # Here we can configure jwt settings:
  jwt_configuration {
    alg                  = "RS256"
    lifetime_in_seconds  = 28800 # 8 hours
    secret_encoded       = false
  }

  # Here define refresh token settings. We want to use refresh token rotation mechanism and we also define refresh token lifetime and idle token lifetime:
  refresh_token {
    rotation_type                 = "rotating"
    expiration_type               = "expiring"
    token_lifetime                = 2592000   # 30 days absolute lifetime
    idle_token_lifetime           = 604800   # 7 days idle timeout
    leeway                        = 0
    infinite_token_lifetime       = false
    infinite_idle_token_lifetime  = false
  }
}

  # Here we are definying credentials for our web app. In this case we want to use client secret with POST method:
resource "auth0_client_credentials" "web_app_credentials" {
  client_id = auth0_client.sample_web_app.id
  authentication_method = "client_secret_post"
}


### Auth0 Actions

# Here we define Auth0 action which will add custom claim to ID Token:
resource "auth0_action" "add-custom-claim-to-id-token_action" {
  name        = "add-custom-claim-to-id-token"
  deploy      = true
  runtime     = "node22"
  code        = file("../tenant-config/actions/post-login/add-custom-claim-to-id-token.js") # Here we have to provide the path to action file.

  # Here we indicate that this Action will be used with "post-login" trigger:
  supported_triggers {
    id      = "post-login"
    version = "v3"
  }

  # Here we define one secret for Auth0 action. In this case it is a namespace used with a custom token claim that will be added to an ID token.
  secrets {
    name  = "NAMESPACE"
    value = var.auth0_actions_custom_claims_namespace
  }
}

# Here we attach the above action to "post-login" trigger:
resource "auth0_trigger_action" "add-custom-claim-to-id-token_action_trigger_binding" {
  trigger = "post-login"
  action_id = auth0_action.add-custom-claim-to-id-token_action.id
}
