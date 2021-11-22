/**********************************************************
 * Define local variables
 **********************************************************/

locals {
  prefix             = var.prefix != "" ? "${var.prefix}" : ""
  domain             = var.prefix != "" ? "${var.prefix}.${var.domain_name}" : "www.${var.domain_name}"
  cognito_domain     = var.prefix != "" ? "${var.prefix}-${var.cognito_domain}" : "${var.cognito_domain}"
  pool_name          = var.prefix != "" ? "${var.prefix}-${var.pool_name}" : "${var.pool_name}"
  pool_client_name   = var.prefix != "" ? "${var.prefix}-${var.pool_name}-client" : "${var.pool_name}-client"
  identity_pool_name = var.prefix != "" ? "${var.prefix}-${var.identity_pool_name}" : "${var.identity_pool_name}"
  callback_urls      = "https://${local.domain}"
  logout_urls        = "https://${local.domain}"
}

resource "aws_cognito_user_pool" "pool" {
  name = local.pool_name

  # ATTRIBUTES
  alias_attributes = ["email", "preferred_username"]

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "email"
    required            = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "name"
    required            = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  username_configuration {
    case_sensitive = false
  }

  # MFA & VERIFICATIONS
  mfa_configuration        = "OFF"
  auto_verified_attributes = ["email"]

  # TAGS
  tags = {}
}

resource "aws_cognito_user_pool_client" "pool_client" {
  user_pool_id = aws_cognito_user_pool.pool.id

  # APP CLIENTS
  name            = local.pool_client_name
  generate_secret = false

  # APP INTEGRATION -
  # APP CLIENT SETTINGS
  supported_identity_providers         = [aws_cognito_identity_provider.google.provider_name]
  callback_urls                        = ["http://localhost:3000", local.callback_urls]
  logout_urls                          = ["http://localhost:3000", local.logout_urls]
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_user_pool_domain" "pool_domain" {
  user_pool_id = aws_cognito_user_pool.pool.id
  domain       = local.cognito_domain
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name = local.identity_pool_name

  allow_unauthenticated_identities = false
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.pool_client.id
    provider_name           = aws_cognito_user_pool.pool.endpoint
    server_side_token_check = false
  }

  supported_login_providers = {
    "accounts.google.com" = "959937491446-snbffjain246f2q7ea4j0dbf55khd338.apps.googleusercontent.com"
  }
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id                     = var.google_client_id
    client_secret                 = var.google_client_secret
    attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    attributes_url_add_attributes = true
    authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    authorize_scopes              = "profile email openid"
    oidc_issuer                   = "https://accounts.google.com"
    token_request_method          = "POST"
    token_url                     = "https://www.googleapis.com/oauth2/v4/token"
  }

  attribute_mapping = {
    email    = "email"
    name     = "name"
    picture  = "picture"
    username = "sub"
  }
}
