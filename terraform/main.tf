terraform {
  backend "azurerm" {
    # resource_group_name  = "statefiles-store-rg"
    # storage_account_name = "statefilesstore"
    # container_name       = "storage-lid"
    # key                  = "pe/terraform.tfstate"
  }
  # experiments = [module_variable_optional_attrs]
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azuread" {
}

data "azurerm_client_config" "current" {
}


resource "azurerm_resource_group" "rg" {
  name     = var.RG_NAME
  location = var.RG_LOCATION
}

resource "azurerm_key_vault" "kv" {
  name                       = var.KV_NAME
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = true
}

resource "azurerm_role_assignment" "kv_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name               = var.SPN_APP_NAME
  identifier_uris            = [format("https://%s.azurewebsites.net", var.SPN_APP_NAME)]
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg" # available_to_other_tenants = false
  # oauth2_allow_implicit_flow = true

  web {
    homepage_url = format("https://%s.azurewebsites.net", var.SPN_APP_NAME)
    redirect_uris = [format("https://%s.azurewebsites.net/.auth/login/aad/callback", var.SPN_APP_NAME)]
    implicit_grant {
      access_token_issuance_enabled = true
    }
  }

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access website on behalf of the signed-in user."
      admin_consent_display_name = format("Allow %s", var.SPN_APP_NAME)
      id                         = "f7957771-325b-48a5-8f78-5a949ee5ba19"
      type                       = "User"
      user_consent_description   = "Allow the application to access website on your behalf."
      user_consent_display_name  = format("Allow %s", var.SPN_APP_NAME)
      value                      = "user_impersonation"
    }
  }

  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }
}

resource "time_rotating" "ninetydays" {
  rotation_days = 90
}

resource "azuread_application_password" "app_password" {
  depends_on = [
    time_rotating.ninetydays
  ]
  display_name = "App Password"
  application_object_id = azuread_application.app.object_id
  end_date_relative = "2160h"
}

resource "azurerm_key_vault_secret" "appservicesecret" {
  depends_on = [
    azurerm_role_assignment.kv_role
  ]
  name         = "spn-secret"
  value        = azuread_application_password.app_password.value
  key_vault_id = azurerm_key_vault.kv.id
}

# Storage
resource "azurerm_storage_account" "str" {
  name                     = var.STR_ACC_NAME
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.str_ip_rules
    bypass = [ "Logging", "Metrics", "AzureServices" ]
    # virtual_network_subnet_ids = [azurerm_subnet.app_subnet.id]
  }
}

# resource "azurerm_storage_container" "users" {
#   name                  = "users"
#   storage_account_name  = azurerm_storage_account.str.name
#   container_access_type = "private"
# }

# resource "azurerm_storage_container" "org" {
#   name                  = "org"
#   storage_account_name  = azurerm_storage_account.str.name
#   container_access_type = "private"
# }

# resource "azurerm_storage_account" "strlogs" {
#   name                     = format("%slogs",var.WEB_APP_NAME)
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"

#   network_rules {
#     default_action             = "Deny"
#     bypass = [ "Logging", "Metrics", "AzureServices" ]
#     # virtual_network_subnet_ids = [azurerm_subnet.app_subnet.id]
#   }
# }

# App Service

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = format("%s-plan", var.WEB_APP_NAME)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind = "Linux"
  reserved = true

# Minimum SKU required for vnet integration
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = var.WEB_APP_NAME
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  site_config {
    linux_fx_version = format("PYTHON|%s",var.PY_VERSION)
  }

  app_settings = {
    "STORAGE_URI" = azurerm_storage_account.str.primary_blob_endpoint
  }

  identity {
    type = "SystemAssigned"
  }

  auth_settings {
    enabled = true
    issuer  = "https://sts.windows.net/94a8b28b-7de6-4eba-af01-5dfd2c03c072"
    # default_provider              = "AzureActiveDirectory"
    # unauthenticated_client_action = "RedirectToLoginPage"

    active_directory {
      client_id     = azuread_application.app.application_id
      client_secret = azuread_application_password.app_password.value
      allowed_audiences = [
        format("https://%s.azurewebsites.net", var.WEB_APP_NAME)
      ]
    }
  }

}

# Vnet Integration to access data in storage account
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_app_service.webapp.id
  subnet_id      = azurerm_subnet.app_subnet.id
}

# # Permission the App Service Idenity to access Storage Account
resource "azurerm_role_assignment" "str_read" {
  scope                = azurerm_storage_account.str.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_app_service.webapp.identity.0.principal_id
}
