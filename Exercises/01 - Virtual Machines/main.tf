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
# RESOURCES SECTION
#
#------------------------------------------------------------------------------
resource "random_id" "lab" { byte_length = 3 }
locals {
  random_id        = lower(random_id.lab.hex)
  machine_size     = "Standard_B1s"
  machine_admin    = "azureuser"
  create_instamce  = false
  create_scale_set = true
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

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storage_account" {
  name                     = "sa${local.random_id}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#------------------------------------------------------------------------------
#
# Create single instance
#
#------------------------------------------------------------------------------
module "single_instance" {
  count     = local.create_instamce ? 1 : 0
  source    = "./single_instance"

  resource_group         = azurerm_resource_group.rg
  subnet                 = azurerm_subnet.subnet
  network_security_group = azurerm_network_security_group.nsg
  storage_account        = azurerm_storage_account.storage_account
  public_key_openssh     = tls_private_key.example_ssh.public_key_openssh
}

#------------------------------------------------------------------------------
#
# Scaling Set with LoadBalancer
#
#------------------------------------------------------------------------------
module "scale_set" {
  count     = local.create_scale_set ? 1 : 0
  source    = "./scale_set"

  resource_group         = azurerm_resource_group.rg
  subnet                 = azurerm_subnet.subnet
  network_security_group = azurerm_network_security_group.nsg
  storage_account        = azurerm_storage_account.storage_account
  public_key_openssh     = tls_private_key.example_ssh.public_key_openssh
}

#------------------------------------------------------------------------------
#
# OUTPUT SECTION
#
#------------------------------------------------------------------------------
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "tls_private_key" {
  value       = tls_private_key.example_ssh.private_key_pem
  sensitive   = true
  description = "The SSH Key. Use `terraform output -raw tls_private_key` to obtain the key"
}
