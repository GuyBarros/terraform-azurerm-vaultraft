provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "vaultraft" {
  name     = var.resource_group
  location = var.location

  tags = {
    name  = var.owner
    TTL   = var.TTL
    owner = var.owner
  }
}

resource "azurerm_availability_set" "vm" {
  # count                          = var.servers
  name                         = "${var.demo_prefix}-aval-set"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.vaultraft.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

  tags = {
    name  = var.owner
    TTL   = var.TTL
    owner = var.owner
  }
}




resource "azurerm_virtual_network" "awg" {
  name                = "${var.virtual_network_name}-awg"
  location            = azurerm_resource_group.vaultraft.location
  address_space       = ["${var.address_space}"]
  resource_group_name = azurerm_resource_group.vaultraft.name

  tags = {
    name  = var.owner
    TTL   = var.TTL
    owner = var.owner
  }
}

resource "azurerm_network_security_group" "vaultraft-sg" {
  name                = "${var.demo_prefix}-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.vaultraft.name

  tags = {
    name  = var.owner
    TTL   = var.owner
    owner = var.owner

  }

  security_rule {
    name                       = "vaultraft-https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "vaultraft-ssh"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "vaultraft-http"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "vaultraft-vault"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000-8999"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
