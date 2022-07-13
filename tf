main-----
resource "azuread_application" "sp_adapp" {
  display_name     = local.sp_name
  sign_in_audience = "AzureADMyOrg"
  owners = [ data.azurerm_client_config.current.object_id ]

  lifecycle { ignore_changes = [ tags, api, oauth2_permission_scope_ids, web ] }
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.sp_adapp.application_id
  description    = local.sp_desc
  owners         = [ data.azurerm_client_config.current.object_id ]
  lifecycle { ignore_changes = [ description, ] }
}

resource "azuread_application_password" "sp_adapp_password" {
  application_object_id = azuread_application.sp_adapp.object_id
  display_name          = "Terraform ServicePrincipal Module Created"
  end_date_relative     = "17520h"
}

output----
output "sp_id" {
  description = "ID of the Enterprise application associated with Service Principal"
  #value       = azuread_application.sp_adapp.application_id
  value       = azuread_service_principal.sp.id
}
output "sp_object_id" {
  description = "Object ID of the Service Principal"
  value       = azuread_service_principal.sp.object_id
}
output "sp_ad_id" {
  description = "Object ID of the Enterprise application associated with Service Principal"
  value       = azuread_application.sp_adapp.application_id
}
output "sp_ad_object_id" {
  description = "Object ID of the Enterprise application associated with Service Principal"
  value       = azuread_application.sp_adapp.object_id
}
output "sp_name" {
  description = "Name of the Service Principal"
  value       = azuread_service_principal.sp.display_name
}
output "sp_secret" {
  description = "Secret of the Service Principal"
  value       = azuread_application_password.sp_adapp_password.value
}






variable---

locals {
  sp_def_name = var.SP_NAME == null ? "${local.app_suffix}" : var.SP_NAME
  sp_name     = var.SP_IS_LZ == true ? "sp-applz-${local.sp_def_name}" : "sp-${local.sp_def_name}"
  sp_desc     = "Terraform created SP for ${local.app_suffix} - ${local.sp_date}"
  sp_date     = formatdate("MMMM DD, YYYY",timestamp())
  sp_prefix   = "${var.APP_NAME}-sp"
}
variable "SP_NAME" {
  description = "Name of the SP - typically leave this blank to follow naming conventions"
  type        = string
  default     = null
}
variable "SP_IS_LZ" {
  description = "Flag to determine if this is an SP used for Landing Zones"
  type        = bool
  default     = false
}
