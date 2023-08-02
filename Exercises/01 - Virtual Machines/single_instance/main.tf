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
locals {
  random_id     = lower(random_id.lab.hex)
  machine_size  = "Standard_B1s"
  machine_admin = "azureuser"
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-${local.random_id}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "ip_configuration"
    subnet_id                     = var.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.network_security_group.id
}

# create the availability set
resource "azurerm_availability_set" "aset" {
  name                = "aset"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "vm"
  location              = var.resource_group.location
  resource_group_name   = var.resource_group.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = local.machine_size

  os_disk {
    name                 = "os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
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

  custom_data         = filebase64("${path.module}/../resources/cloud_init.sh")
  availability_set_id = azurerm_availability_set.aset.id
}

#------------------------------------------------------------------------------
#
# OUTPUT SECTION
#
#------------------------------------------------------------------------------
output "public_ip_address" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "connection_string" {
  value = "ssh -i id_rsa ${local.machine_admin}@${azurerm_linux_virtual_machine.vm.public_ip_address}"
}
