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

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                       = var.kv_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled    = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "purge",
      "recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "appservicesecret" {
  name         = "spn-secret"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "random_password" "password" {
  length           = 32
  special          = true
  number           = true
  upper            = true
  lower            = true
  override_special = "$-_%@#+="
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

resource "azuread_application_password" "passwrd" {
  application_object_id = azuread_application.app.object_id
  description           = "V1"
  value                 = random_password.password.result
  end_date              = timeadd(timestamp(), "8760h") # one year
}

