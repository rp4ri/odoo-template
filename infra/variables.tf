variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

# variable "client_id" {
#   description = "ID de la aplicación en Azure AD"
#   type        = string
# }

# variable "client_secret" {
#   description = "Secreto de la aplicación en Azure AD"
#   type        = string
#   sensitive   = true
# }

variable "tenant_id" {
  description = "ID del tenant en Azure AD"
  type        = string
}
