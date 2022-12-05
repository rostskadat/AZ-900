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

#------------------------------------------------------------------------------
#
# VARIABLE SECTION
#
#------------------------------------------------------------------------------
variable "resource_group" {
  description = "The resource group the instance belongs to"
  type        = any
}

variable "subnet" {
  description = "The subnet the instance is connected to"
  type        = any
}

variable "network_security_group" {
  description = "The network_security_group to configure the access to the instance"
  type        = any
}

variable "storage_account" {
  description = "The storage account the instance use to store its boot logs, etc."
  type        = any
}

variable "public_key_openssh" {
  description = "The ssh key to use when configuring the admin user"
  type        = any
}

#------------------------------------------------------------------------------
#
# RESOURCES SECTION
#
#------------------------------------------------------------------------------
resource "random_id" "lab" { byte_length = 3 }
resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

locals {
  random_id                      = lower(random_id.lab.hex)
  machine_size                   = "Standard_B1s"
  machine_admin                  = "azureuser"
  preferred_sku                  = "Standard"
  frontend_ip_configuration_name = "public-ip"
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-${local.random_id}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Static"
  sku                 = local.preferred_sku
  domain_name_label   = random_string.fqdn.result
}

resource "azurerm_lb" "lb" {
  name                = "lb-${local.random_id}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = local.preferred_sku

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "http-running-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_backend_address_pool" "pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backend-ip-pool-${local.random_id}"
}

resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-to-backend"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = local.frontend_ip_configuration_name
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = tolist([azurerm_lb_backend_address_pool.pool.id])
}

# the scale set
resource "azurerm_linux_virtual_machine_scale_set" "scale_set" {

  name                = "vmss-${local.random_id}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  sku                 = local.machine_size
  #single_placement_group = true # It seems to be ignored
  instances = 1

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_username                  = local.machine_admin
  disable_password_authentication = true

  admin_ssh_key {
    username   = local.machine_admin
    public_key = var.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = var.storage_account.primary_blob_endpoint
  }

  network_interface {
    name                      = "vmss-nic"
    primary                   = true
    network_security_group_id = var.network_security_group.id

    ip_configuration {
      name                                   = "ip-configuration"
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.pool.id]
      subnet_id                              = var.subnet.id
      primary                                = true
    }
  }

  zone_balance = true
  zones        = tolist(["1", "2", "3"])

  upgrade_mode = "Automatic"
  # health_probe_id = azurerm_lb_probe.probe.id

  custom_data = filebase64("${path.module}/../resources/cloud_init.sh")
}
