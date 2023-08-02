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
# MYSQL DB - OLTP
#
#------------------------------------------------------------------------------
resource "azurerm_mysql_server" "server" {
  count = local.create_oltp ? 1 : 0

  name                = "server-${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = "mysqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_1"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                = false
  backup_retention_days            = 7
  geo_redundant_backup_enabled     = false
  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_mysql_database" "database" {
  count = local.create_oltp ? 1 : 0

  name                = "database-${local.random_id}"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.server[0].name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

output "mysql_connect_command" {
  value = local.create_oltp ? "mysql --host=${azurerm_mysql_server.server[0].fqdn} --user=${azurerm_mysql_server.server[0].administrator_login}@${azurerm_mysql_database.database[0].server_name} -p" : ""
}

/*
    create database todos;
    use todos;
    create table user (id integer, username varchar(30) );
    describe user;
    insert into user values (1, 'john');
    insert into user values (2, 'smith');
    select * from user;
*/

#------------------------------------------------------------------------------
#
# SYNAPSE - OLAP
#
#------------------------------------------------------------------------------
resource "azurerm_storage_account" "storage_account" {
  count = local.create_olap ? 1 : 0

  name                = "sa${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "filesystem" {
  count = local.create_olap ? 1 : 0

  name               = "filesystem-${local.random_id}"
  storage_account_id = azurerm_storage_account.storage_account[0].id
}

resource "azurerm_synapse_workspace" "workspace" {
  count = local.create_olap ? 1 : 0

  name                                 = "workspace-${local.random_id}"
  location                             = azurerm_resource_group.rg.location
  resource_group_name                  = azurerm_resource_group.rg.name
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.filesystem[0].id

  sql_administrator_login          = "sqladminuser"
  sql_administrator_login_password = "H@Sh1CoR3!"

  # aad_admin {
  #   login     = "AzureAD Admin"
  #   object_id = "00000000-0000-0000-0000-000000000000"
  #   tenant_id = "00000000-0000-0000-0000-000000000000"
  # }

  identity {
    type = "SystemAssigned"
  }
}

output "synapse_connect_command" {
  value = local.create_olap ? "jdbc:sqlserver://${azurerm_synapse_workspace.workspace[0].connectivity_endpoints.sql}:1433;database=yourdatabase;user=${azurerm_synapse_workspace.workspace[0].sql_administrator_login};password=${nonsensitive(azurerm_synapse_workspace.workspace[0].sql_administrator_login_password)};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.sql.azuresynapse.net;loginTimeout=30;" : ""
}

#------------------------------------------------------------------------------
#
# NOSQL
#
#------------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  count = local.create_nosql ? 1 : 0

  name                = "cosmosdb-account-${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = "northeurope"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "database" {
  count = local.create_nosql ? 1 : 0

  name                = "database-${local.random_id}"
  resource_group_name = azurerm_cosmosdb_account.cosmosdb_account[0].resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb_account[0].name
}

output "cosmosdb_connect_command" {
  value = local.create_nosql ? azurerm_cosmosdb_account.cosmosdb_account[0].connection_strings[0] : null
  sensitive = true
}

output "cosmosdb_database" {
  value = local.create_nosql ? azurerm_cosmosdb_mongo_database.database[0].name : null
}

#------------------------------------------------------------------------------
#
# CACHE
#
#------------------------------------------------------------------------------

resource "azurerm_redis_cache" "cache" {
  count = local.create_cache ? 1 :0

  name                = "cache-${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 2
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

output "redis_connect_command" {
  value = local.create_cache ? azurerm_redis_cache.cache[0] : null
  sensitive = true
}