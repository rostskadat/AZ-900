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
  features {}
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

  create_sync = false
  create_blob = true
}

# creating resource_group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.random_id}"
  location = var.resource_group_location
}

# Create storage account for logs
resource "azurerm_storage_account" "storage_account" {
  name                     = "sa${local.random_id}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.storage_account.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = local.sas_start
  expiry = local.sas_expiry

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

#------------------------------------------------------------------------------
#
# FILE SYNC
#
#------------------------------------------------------------------------------

resource "azurerm_storage_sync" "sync" {
  count = local.create_sync ? 1 : 0

  name                = "sync-${local.random_id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_storage_sync_group" "sync_group" {
  count = local.create_sync ? 1 : 0

  name            = "sync-group-${local.random_id}"
  storage_sync_id = azurerm_storage_sync.sync[count.index].id
}


resource "azurerm_storage_share" "share" {
  count = local.create_sync ? 1 : 0

  name                 = "sync-share-${local.random_id}"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 5
  acl {
    id = "GhostedRecall"
    access_policy {
      permissions = "r"
    }
  }
}

resource "azurerm_storage_sync_cloud_endpoint" "sync_cloud_endpoint" {
  count = local.create_sync ? 1 : 0

  name                  = "sce-${local.random_id}"
  storage_sync_group_id = azurerm_storage_sync_group.sync_group[count.index].id
  file_share_name       = azurerm_storage_share.share[count.index].name
  storage_account_id    = azurerm_storage_account.storage_account.id
}

#------------------------------------------------------------------------------
#
# BLOB STORAGE
#
#------------------------------------------------------------------------------


resource "azurerm_storage_container" "container" {
  count = local.create_blob ? 1 : 0

  name                  = "container-${local.random_id}"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  count = local.create_blob ? 1 : 0

  name                   = "blob-${local.random_id}"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.container[0].name
  type                   = "Block"
  source                 = "${path.module}/main.tf"
}