terraform {
  backend "azurerm" {
    resource_group_name  = "statefiles-store-rg"
    storage_account_name = "statefilesstore"
    container_name       = "storage-lid"
    key                  = "spn.tfstate"
  }
}

# App Registration
# App Registration was not working with azdo service connection
provider "azuread" {
}

resource "azuread_application" "app" {
  display_name               = var.app_name
  homepage                   = format("https://%s.azurewebsites.net",var.app_name)
  identifier_uris            = [format("https://%s.azurewebsites.net",var.app_name)]
  reply_urls                 = [format("https://%s.azurewebsites.net/.auth/login/aad/callback",var.app_name)]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true

  oauth2_permissions {
    admin_consent_description  = "Allow the application to access website on behalf of the signed-in user."
    admin_consent_display_name = format("Allow %s",var.app_name)
    is_enabled                 = true
    type                       = "User"
    user_consent_description   = "Allow the application to access website on your behalf."
    user_consent_display_name  = format("Allow %s",var.app_name)
    value                      = "user_impersonation"
  }
}
