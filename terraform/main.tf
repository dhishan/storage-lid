terraform {
  backend "azurerm" {
    # resource_group_name  = "statefiles-store-rg"
    # storage_account_name = "statefilesstore"
    # container_name       = "storage-lid"
    # key                  = "terraform.tfstate"
  }
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
  name     = var.rg_name
  location = var.rg_location
}

resource "azurerm_key_vault" "kv" {
  name                       = var.kv_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = true
  # access_policy = [ {
  #   application_id = data.azurerm_client_config.current.client_id
  #   object_id    = data.azurerm_client_config.current.object_id
  #   tenant_id = data.azurerm_client_config.current.tenant_id
  #   certificate_permissions = []
  #   key_permissions = []
  #   storage_permissions = []
  #   secret_permissions = [
  #     "set",
  #     "get",
  #     "delete",
  #     "purge",
  #     "recover",
  #     "list"
  #   ]
  # }]
}

# resource "azurerm_key_vault_access_policy" "current_config" {
#   key_vault_id = azurerm_key_vault.kv.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = data.azurerm_client_config.current.object_id

#   secret_permissions = [
#       "set",
#       "get",
#       "delete",
#       "purge",
#       "recover"
#   ]
# }

resource "azurerm_key_vault_secret" "appservicesecret" {
  depends_on = [
    azurerm_role_assignment.kv_role
  ]
  name         = "spn-secret"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv.id
}

# access policy for the SC1 app

resource "random_password" "password" {
  depends_on = [
    time_rotating.ninetydays
  ]
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

resource "time_rotating" "ninetydays" {
  rotation_days = 90
}

resource "azuread_application_password" "passwrd" {
  lifecycle {
    ignore_changes = [
      end_date
    ]
  }
  depends_on = [
    time_rotating.ninetydays
  ]

  application_object_id = azuread_application.app.object_id
  description           = "V1"
  value                 = random_password.password.result
  end_date              = timeadd(timestamp(), "8760h") # one year
}

# Storage
resource "azurerm_storage_account" "str" {
  name                     = var.storageaccname
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.str_ip_rules
    # virtual_network_subnet_ids = [azurerm_subnet.app_subnet.id]
  }
}


# App Service

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = format("%s-plan", var.webapp_name)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = var.webapp_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  site_config {
    # linux_fx_version = "PYTHON|3.7"
    python_version = "3.4"
  }

  app_settings = {
    "STORAGE_URI" = azurerm_storage_account.str.primary_blob_endpoint
  }

  identity {
    type = "SystemAssigned"
  }

  auth_settings {
    enabled                       = true
    issuer                        = "https://sts.windows.net/94a8b28b-7de6-4eba-af01-5dfd2c03c072"
    # default_provider              = "AzureActiveDirectory"
    # unauthenticated_client_action = "RedirectToLoginPage"

    active_directory {
      client_id = azuread_application.app.application_id
      client_secret = random_password.password.result
      allowed_audiences = [
        format("https://%s.azurewebsites.net", var.webapp_name)
      ]
    }
  }
  
}

# Permission the App Service Idenity to access Storage Account
# azurerm_app_service.example.identity.0.tenant_id
resource "azurerm_role_assignment" "str_read" {
  scope                = azurerm_storage_account.str.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_app_service.webapp.identity.0.principal_id
}

resource "azurerm_role_assignment" "kv_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}