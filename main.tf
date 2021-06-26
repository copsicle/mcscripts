terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.62.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = "${var.prefix}-rg"
  location = var.region
}

resource "azurerm_virtual_network" "vn" {
  name = "${var.prefix}-vn"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name = "${var.prefix}-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes = [ "10.0.2.0/24" ]
}

resource "azurerm_public_ip" "ip" {
  name = "${var.prefix}-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "Dynamic"
  domain_name_label = "${var.prefix}-server"
}

output "address" {
  description = "The domain name label for the server."
  value = azurerm_public_ip.ip.fqdn
}

resource "azurerm_network_security_group" "nsg" {
  name = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}

resource "azurerm_network_security_rule" "ssh" {
  name = "SSH"
  description = "SSH Server"
  resource_group_name = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  
  priority = 500
  direction = "Inbound"
  access = "Allow"
  protocol = "TCP"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "mc" {
  name = "MC"
  description = "Minecraft Server"
  resource_group_name = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  
  priority = 200
  direction = "Inbound"
  access = "Allow"
  protocol = "TCP"
  source_port_range = "*"
  destination_port_range = var.mcport
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "web" {
  name = "web"
  description = "Static File Server"
  resource_group_name = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
  
  priority = 800
  direction = "Inbound"
  access = "Allow"
  protocol = "TCP"
  source_port_range = "*"
  destination_port_range = var.webport
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_interface" "nic" {
  name = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  ip_configuration {
    name = "${azurerm_subnet.subnet.name}-config"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ip.id
  }  
}

resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = var.vm

  admin_username = var.username
  disable_password_authentication = true
  admin_ssh_key {
    username = var.username
    public_key = file(var.key)
  }

  network_interface_ids = [ azurerm_network_interface.nic.id, ]

  os_disk {
    name = "${var.prefix}-osdisk"
    caching = "ReadWrite"
    storage_account_type = var.disktype
    disk_size_gb = var.disksize
  }

  source_image_reference {
    publisher = "Debian"
    offer = "debian-10"
    sku = "10"
    version = "latest"
  }
}