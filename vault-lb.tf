

# Create Public IP Address for the Load Balancer
resource "azurerm_public_ip" "vault-lb-pip" {
  name                = "${var.resource_group}-vault-lb-pip"
  resource_group_name = azurerm_resource_group.vaultraft.name
  location            = var.location
 allocation_method   = "Static"
  domain_name_label   = "${var.hostname}-vault-lb"
  sku                 = "Standard"

  tags = {
    name      =var.owner
    TTL       = var.TTL
    owner     = var.owner
 }
}

# create and configure Azure Load Balancer

resource "azurerm_lb" "vault-lb" {
  name                = "${var.resource_group}-vault-lb"
  resource_group_name = azurerm_resource_group.vaultraft.name
  location            = var.location
 sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.resource_group}-consulpip"
    public_ip_address_id = azurerm_public_ip.vault-lb-pip.id
  }

  tags = {
    name      =var.owner
    TTL       = var.TTL
    owner     = var.owner
 }
}

resource "azurerm_lb_probe" "vault-lb-probe" {
  name                = "${var.resource_group}-vault-lb-probe"
  resource_group_name = azurerm_resource_group.vaultraft.name
  loadbalancer_id     = azurerm_lb.vault-lb.id
  protocol            = "http"
  port                = "8200"
  request_path        = "/v1/sys/health"
  number_of_probes    = "1"
}

resource "azurerm_lb_rule" "vault-lb-rule" {
  name                           = "${var.resource_group}-vault-lb-rule"
  resource_group_name            = azurerm_resource_group.vaultraft.name
  loadbalancer_id                = azurerm_lb.vault-lb.id
  protocol                       = "Tcp"
  frontend_port                  = "8200"
  backend_port                   = "8200"
  frontend_ip_configuration_name = azurerm_lb.vault-lb.frontend_ip_configuration.0.name
  probe_id                       = azurerm_lb_probe.vault-lb-probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.vault-lb-pool.id
  depends_on                     = [azurerm_public_ip.vault-lb-pip,azurerm_lb_probe.vault-lb-probe,azurerm_lb_backend_address_pool.vault-lb-pool]
}


resource "azurerm_lb_backend_address_pool" "vault-lb-pool" {
  name                = "${var.resource_group}-vault-lb-pool"
  resource_group_name = azurerm_resource_group.vaultraft.name
  loadbalancer_id     = azurerm_lb.vault-lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vault-lb-servers" {
  count                   = var.servers
  network_interface_id    = azurerm_network_interface.servers-nic[count.index].id
  ip_configuration_name   = "${var.demo_prefix}-${count.index}-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vault-lb-pool.id
}


resource "azurerm_network_interface_backend_address_pool_association" "vault-lb-leader" {
 network_interface_id    = azurerm_network_interface.leader-nic.id
  ip_configuration_name   = "${var.demo_prefix}-leader-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.vault-lb-pool.id
}