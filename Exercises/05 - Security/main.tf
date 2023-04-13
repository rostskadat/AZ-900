#------------------------------------------------------------------------------
#
# PROVIDER SECTION
#
#------------------------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {
    # REF: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/features-block
    api_management {
      purge_soft_delete_on_destroy = true
    }
    app_configuration {
      purge_soft_delete_on_destroy = true
    }
    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
    key_vault {
      # This is important for this LAB
      purge_soft_delete_on_destroy = true
    }
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    template_deployment {
      delete_nested_items_during_deletion = true
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
  # DO NOT INCLUDE CREDENTIALS HERE. CF. README.MD
}

#------------------------------------------------------------------------------
#
# VARIABLE SECTION
#
#------------------------------------------------------------------------------
variable "resource_group_location" {
  default     = "West Europe"
  description = "Location of the resource group."
}

#------------------------------------------------------------------------------
#
# DATA SECTION
#
#------------------------------------------------------------------------------
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

#------------------------------------------------------------------------------
#
# RESOURCES SECTION
#
#------------------------------------------------------------------------------
resource "random_id" "lab" { byte_length = 3 }
locals {
  random_id  = lower(random_id.lab.hex)
  sas_start  = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())
  sas_expiry = timeadd(local.sas_start, "168h") # 1 week

  create_oltp  = false
  create_olap  = false
  create_nosql = false
  create_cache = true
}

# creating resource_group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.random_id}"
  location = var.resource_group_location
}

#------------------------------------------------------------------------------
#
# KEYVAULT
#
#------------------------------------------------------------------------------
resource "azurerm_key_vault" "key_vault" {
  name                        = "key-vault-${local.random_id}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  access_policy {
    tenant_id = data.azurerm_subscription.current.tenant_id
    object_id = "30293c55-5337-484b-b4bd-73540528fe4d" # data.azurerm_subscription.current.subscription_id
    certificate_permissions = [
      "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
    ]

    key_permissions = [
      "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
    ]
    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
    storage_permissions = [
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
    ]
  }
}

# resource "azurerm_key_vault_key" "key" {
#   name         = "key-${local.random_id}"
#   key_vault_id = azurerm_key_vault.key_vault.id
#   key_type     = "RSA"
#   key_size     = 2048

#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey",
#   ]
# }

# output "redis_connect_command" {
#   value     = local.create_cache ? azurerm_redis_cache.cache[0] : null
#   sensitive = true
# }
