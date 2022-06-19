
# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/24"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
#publice 
resource "azurerm_subnet" "public" {
  name                 = "public"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/26"]
}
#privete
resource "azurerm_subnet" "privete" {
  name                 = "privete"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.88/29"]
  #   delegation for the DB
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}
# Create public IPs

# Relay machine ip
resource "azurerm_public_ip" "publicIpApp" {
  name                = "appServerPublicIp"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

}
# lb ip
resource "azurerm_public_ip" "publicIpLB" {
  name                = "LBServerPublicIp"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = random_string.fqdn.result

}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}




# # Create Network Security Groups and rule

#public
resource "azurerm_network_security_group" "public_nsg" {
  name                = "public_nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 280
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "77.137.66.121"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "outsideweb"
    priority                   = 290
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#privete
resource "azurerm_network_security_group" "privete_nsg" {
  name                = "privete_nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 280
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/26"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "postgareSQL"
    priority                   = 290
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.0.0/26"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# # # Create network interface

#terminal  server
resource "azurerm_network_interface" "appNic" {
  name                = "appNic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "appNic"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.40"
    public_ip_address_id          = azurerm_public_ip.publicIpApp.id

  }
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "privete" {
  subnet_id                 = azurerm_subnet.privete.id
  network_security_group_id = azurerm_network_security_group.privete_nsg.id
}

# # # # privte DNS

resource "azurerm_private_dns_zone" "dns" {
  name                = "tracker.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "dns_link"
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}
