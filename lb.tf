# #LB
resource "azurerm_lb" "LB" {
  name                = "LoadBalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicIpLB.id
  }
}

# backendpool

resource "azurerm_lb_backend_address_pool" "backendPool" {

  name            = "BackEndAddressPool"
  loadbalancer_id = azurerm_lb.LB.id

}

# porde

resource "azurerm_lb_probe" "LB" {
  loadbalancer_id = azurerm_lb.LB.id
  name            = "ssh-running-probe"
  port            = var.application_port
}

# lb rules

resource "azurerm_lb_rule" "lbnatrule" {
  loadbalancer_id                = azurerm_lb.LB.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backendPool.id]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.LB.id
  disable_outbound_snat          = true
}

# lboutboundrule

resource "azurerm_lb_outbound_rule" "outRule" {
  loadbalancer_id         = azurerm_lb.LB.id
  name                    = "OutboundRule"
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendPool.id

  frontend_ip_configuration {
    name = "PublicIPAddress"


  }
}
