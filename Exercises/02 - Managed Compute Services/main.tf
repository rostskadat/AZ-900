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

# Use that to build the local 
# resource "null_resource" "build_apps" {
#   provisioner "local-exec" {
#     command = "cd ${path.module}/msdocs-python-flask-webapp-quickstart && python -m pip install -r requirements.txt"
#   }
# }

data "archive_file" "html" {
  # https://github.com/Azure-Samples/html-docs-hello-world
  type             = "zip"
  source_dir       = "${path.module}/html-docs-hello-world"
  output_path      = "${path.module}/.terraform/build/html-docs-hello-world.zip"
  output_file_mode = "0666"
}

data "archive_file" "python" {
  # https://github.com/Azure-Samples/python-docs-hello-world
  type             = "zip"
  source_dir       = "${path.module}/python-docs-hello-world"
  output_path      = "${path.module}/.terraform/build/python-docs-hello-world.zip"
  output_file_mode = "0666"
}

data "archive_file" "python_flask" {
  # https://github.com/Azure-Samples/msdocs-python-flask-webapp-quickstart
  type             = "zip"
  source_dir       = "${path.module}/msdocs-python-flask-webapp-quickstart"
  output_path      = "${path.module}/.terraform/build/msdocs-python-flask-webapp-quickstart.zip"
  output_file_mode = "0666"

  # depends_on = [
  #   null_resource.build_apps
  # ]
}

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

  create_html   = false
  create_python = false
  create_docker = false
  create_aci    = false
}

# creating resource_group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.random_id}"
  location = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
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

resource "azurerm_service_plan" "service_plan" {
  name                = "service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Static webapp
resource "azurerm_linux_web_app" "html" {
  count = local.create_html ? 1 : 0

  name                = "webapp-html-${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.service_plan.id
  https_only          = true


  # REF: https://learn.microsoft.com/en-us/azure/app-service/deploy-run-package
  zip_deploy_file = data.archive_file.html.output_path

  app_settings = {
    # in order to deploy a locally generated zip file
    WEBSITE_RUN_FROM_PACKAGE = "1"
    # or from a remote archive
    # WEBSITE_RUN_FROM_PACKAGE="https://myblobstorage.blob.core.windows.net/content/SampleCoreMVCApp.zip?st=2018-02-13T09%3A48%3A00Z&se=2044-06-14T09%3A48%3A00Z&sp=rl&sv=2017-04-17&sr=b&sig=bNrVrEFzRHQB17GFJ7boEanetyJ9DGwBSV8OM3Mdh%2FM%3D"
  }

  site_config {
    minimum_tls_version = "1.2"
    health_check_path   = "/"
  }
}

# Python webapp
resource "azurerm_linux_web_app" "python" {
  count = local.create_python ? 1 : 0

  name                = "webapp-python-${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.service_plan.id
  https_only          = true


  # REF: https://learn.microsoft.com/en-us/azure/app-service/deploy-run-package
  zip_deploy_file = data.archive_file.python.output_path

  app_settings = {
    # linux-fx-version = "PYTHON:3.8"
    # in order to deploy a locally generated zip file
    WEBSITE_RUN_FROM_PACKAGE = "1"
    # or from a remote archive
    # WEBSITE_RUN_FROM_PACKAGE="https://myblobstorage.blob.core.windows.net/content/SampleCoreMVCApp.zip?st=2018-02-13T09%3A48%3A00Z&se=2044-06-14T09%3A48%3A00Z&sp=rl&sv=2017-04-17&sr=b&sig=bNrVrEFzRHQB17GFJ7boEanetyJ9DGwBSV8OM3Mdh%2FM%3D"

    # This will allow the instalation of the requirements found in the requirements.txt
    SCM_DO_BUILD_DURING_DEPLOYMENT = true
  }

  site_config {
    minimum_tls_version = "1.2"
    health_check_path   = "/"
    application_stack {
      # az webapp list-runtimes --os linux 
      python_version = "3.9"
    }
  }
}

resource "azurerm_container_registry" "acr" {
  count = local.create_docker ? 1 : 0

  name                = "acr${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = true
}

# Docker webapp
resource "azurerm_linux_web_app" "python_docker" {
  count = local.create_docker ? 1 : 0

  name                = "webapp-python-docker-${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.service_plan.id
  https_only          = true

  site_config {
    minimum_tls_version                     = "1.2"
    health_check_path                       = "/"
    container_registry_use_managed_identity = true
    application_stack {
      # when bootstrapping use nginx
      # docker_image = "nginx"
      docker_image     = "${azurerm_container_registry.acr[count.index].login_server}/webapp-python-docker"
      docker_image_tag = "latest"
    }
  }

  # There are mainly 2 ways to handle the identity of the application.
  # Either we let the System create an identity for the application and then we assign a role o that identity
  # Or we create an identity, assign a role to it, and then set the application to use that identity
  # System managed identity
  identity {
    type = "SystemAssigned"
  }
  # User defined identity
  # identity {
  #   type         = "SystemAssigned, UserAssigned"
  #   identity_ids = [azurerm_user_assigned_identity.assigned_identity_acr_pull.id]
  # }

}

# System managed identity
resource "azurerm_role_assignment" "role_assignment" {
  count = local.create_docker ? 1 : 0

  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_web_app.python_docker[count.index].identity[0].principal_id
}

# # User defined identity: in case you do not want to use the 
# #   system managed one
# resource "azurerm_user_assigned_identity" "assigned_identity_acr_pull" {
#   count = local.create_docker ? 1 : 0

#   name                = "acr_pull"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }
# resource "azurerm_role_assignment" "role_assignment" {
#   count = local.create_docker ? 1 : 0

#   scope                = data.azurerm_subscription.current.id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_user_assigned_identity.assigned_identity_acr_pull.principal_id
# }

#------------------------------------------------------------------------------
#
# CONTAINER INSTANCES
#
#------------------------------------------------------------------------------
resource "azurerm_container_group" "aci" {
  count = local.create_aci ? 1 : 0

  name                = "aci-${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_address_type = "Public"
  dns_name_label  = "aci-${local.random_id}"
  os_type         = "Linux"

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}

#------------------------------------------------------------------------------
#
# FUNCTIONS
#
#------------------------------------------------------------------------------
resource "azurerm_linux_function_app" "function_app" {
  name                = "function-app-${local.random_id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.service_plan.id

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key

  site_config {
    application_stack {
      python_version = "3.8"
    }
  }
}

# REF: https://learn.microsoft.com/en-us/azure/azure-functions/

resource "azurerm_function_app_function" "function" {
  name            = "function-${local.random_id}"
  function_app_id = azurerm_linux_function_app.function_app.id
  language        = "Python"
  file {
    name    = "__init__.py"
    content = file("./SampleApp/PythonSampleApp/__init__.py")
  }
  test_data = file("./SampleApp/PythonSampleApp/sample.dat")
  config_json = file("./SampleApp/PythonSampleApp/function.json")
}


#------------------------------------------------------------------------------
#
# OUTPUT SECTION
#
#------------------------------------------------------------------------------
output "docker_login_string" {
  value = local.create_docker ? "docker login --username ${azurerm_container_registry.acr[0].admin_username} --password ${nonsensitive(azurerm_container_registry.acr[0].admin_password)} ${azurerm_container_registry.acr[0].login_server}" : "not build"
}
