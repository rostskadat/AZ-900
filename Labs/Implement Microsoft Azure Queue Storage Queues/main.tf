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
  }
}

provider "azurerm" {
  features {}
  # DO NOT INCLUDE CREDENTIALS HERE. CF. README.MD
}

#------------------------------------------------------------------------------
#
# RESOURCES SECTION
#
#------------------------------------------------------------------------------

resource "random_id" "lab" { byte_length = 3 }
locals { random_id = lower(random_id.lab.hex) }

# obtaining the default resource_group
resource "azurerm_resource_group" "lab" {
  name     = "rg-lab${local.random_id}"
  location = "West Europe"
}

resource "azurerm_storage_account" "lab" {
  name                     = "sa-lab${local.random_id}"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Creating the queues
resource "azurerm_storage_queue" "incoming-messages" {
  name                 = "incoming-messages"
  storage_account_name = azurerm_storage_account.lab.name
}

resource "azurerm_storage_queue" "outgoing-messages" {
  name                 = "outgoing-messages"
  storage_account_name = azurerm_storage_account.lab.name
}

# Creating the functions
resource "azurerm_storage_container" "func_storage_container" {
  name                  = "sc-lab${local.random_id}"
  storage_account_name  = azurerm_storage_account.lab.name
  container_access_type = "private"
}

module "simple_function_app" {
  source                     = "./modules/simple_function_app"
  function_name              = "af-lab${local.random_id}"
  location                   = azurerm_resource_group.lab.location
  resource_group_name        = azurerm_resource_group.lab.name
  storage_account_name       = azurerm_storage_account.lab.name
  storage_account_access_key = azurerm_storage_account.lab.primary_access_key
  storage_connection_string  = azurerm_storage_account.lab.primary_blob_connection_string
}

# NOTE: config_json does not support "scriptFile" attribute in function.json
locals {
  incoming_request_handler_json       = jsondecode(file("src/IncomingRequestHandler/function.json"))
  incoming_request_handler_bindings   = local.incoming_request_handler_json.bindings
  process_request_handler_json        = jsondecode(file("src/ProcessRequestHandler/function.json"))
  process_request_handler_bindings    = local.process_request_handler_json.bindings
  statistics_request_handler_json     = jsondecode(file("src/StatisticsRequestHandler/function.json"))
  statistics_request_handler_bindings = local.statistics_request_handler_json.bindings
}

resource "azurerm_function_app_function" "incoming_request_handler" {
  name            = "IncomingRequestHandler"
  function_app_id = module.simple_function_app.function_app_id
  config_json     = jsonencode({ bindings = local.incoming_request_handler_bindings })

  file {
    name    = "__init__.py"
    content = file("src/IncomingRequestHandler/__init__.py")
  }
  language  = "Python"
  test_data = jsonencode({ "name" = "Azure" })
}

resource "azurerm_function_app_function" "process_request_handler" {
  name            = "ProcessRequestHandler"
  function_app_id = module.simple_function_app.function_app_id
  config_json     = jsonencode({ bindings = local.process_request_handler_bindings })

  file {
    name    = "__init__.py"
    content = file("src/ProcessRequestHandler/__init__.py")
  }
  language  = "Python"
  test_data = jsonencode({ "name" = "Azure" })
}

resource "azurerm_function_app_function" "statistics_request_handler" {
  name            = "StatisticsRequestHandler"
  function_app_id = module.simple_function_app.function_app_id
  config_json     = jsonencode({ bindings = local.statistics_request_handler_bindings })

  file {
    name    = "__init__.py"
    content = file("src/StatisticsRequestHandler/__init__.py")
  }
  language  = "Python"
  test_data = jsonencode({ "name" = "Azure" })
}


resource "local_file" "output" {
  content = jsonencode({
    "app_functions" : {
      "name" : module.simple_function_app.function_app_name,
      "id" : module.simple_function_app.function_app_id,
      "hostname" : module.simple_function_app.function_app_default_hostname,
      #"storage_account" : replace(module.simple_function_app.function_app_storage_connection, "/", "\\/"),
      "storage_account" : azurerm_storage_account.lab.primary_blob_connection_string
    }
    #FUNCTION = $(shell node -p "require('./temp_infra/func.json').app_functions.name")
    #STORAGE_ACC = $(shell node -p "require('./temp_infra/func.json').app_functions.storage_account")
    #STORAGE_SUB = 's/""/"$(STORAGE_ACC)"/g'
    #sed -i $(STORAGE_SUB) functions/local.settings.json
  })
  filename = ".build/func.json"
}



#------------------------------------------------------------------------------
#
# OUTPUT SECTION
#
#------------------------------------------------------------------------------
# output "function_name" {
#   value = module.simple_function_app.function_app_name
# }
