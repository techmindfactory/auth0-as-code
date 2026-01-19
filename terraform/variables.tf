variable "auth0_domain" {
  type        = string
  description = "Auth0 tenant domain (e.g., mytenant.eu.auth0.com)"
}

variable "auth0_client_id" {
  type        = string
  description = "Auth0 Management API Client ID with sufficient permissions"
}

variable "auth0_client_secret" {
  type        = string
  description = "Auth0 Management API Client Secret"
}

variable "sample_web_app_name" {
  description = "Name of the web application in Auth0"
  type        = string
}

variable "sample_web_app_callbacks" {
  description = "Allowed callback URLs"
  type        = list(string)
  default     = []
}

variable "sample_web_app_logout_urls" {
  description = "Allowed logout URLs"
  type        = list(string)
  default     = []
}

variable "auth0_actions_custom_claims_namespace" {
  description = "The name of the namespace for the custom claims in tokens"
  default     = ""
  type        = string
}