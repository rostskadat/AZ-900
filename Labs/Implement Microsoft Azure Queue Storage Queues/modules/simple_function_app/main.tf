### INPUT VARs ###
variable "location" {}
variable "function_name" {}
variable "resource_group_name" {}
variable "storage_account_name" {}
variable "storage_account_access_key" {}
variable "storage_connection_string" {}

resource "azurerm_service_plan" "service_plan" {
  name                = "func-app-service-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "linux_function_app" {
  name                = var.function_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.service_plan.id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  app_settings = {
    # Ref: https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings
    # XXXX: Should get the Queue url
    # QueueStorageAccount = var.storage_connection_string,
    FUNCTIONS_WORKER_RUNTIME        = "python",
    AzureWebJobsStorage             = var.storage_connection_string,
#    WEBSITE_RUN_FROM_PACKAGE        = "1"
    PYTHON_ENABLE_WORKER_EXTENSIONS = "1" # load extentions from requirements.txt
  }

  # FIXME: Use DNS names instead of enabling CORS
  site_config {
    cors {
      allowed_origins = ["*"]
    }
    application_stack {
      python_version = "3.8"
    }
  }

  # lifecycle {
  #   ignore_changes = [
  #     app_settings["WEBSITE_RUN_FROM_PACKAGE"]
  #   ]
  # }

}

output "function_app_name" {
  value       = azurerm_linux_function_app.linux_function_app.name
  description = "Deployed function app name"
}

output "function_app_id" {
  value       = azurerm_linux_function_app.linux_function_app.id
  description = "Deployed function app ID"
}

output "function_app_default_hostname" {
  value       = azurerm_linux_function_app.linux_function_app.default_hostname
  description = "Deployed function app hostname"
}
