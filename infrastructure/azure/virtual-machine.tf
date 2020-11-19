locals {
  vm_name = "vm-${local.project}"
}

# Create public IP
resource "azurerm_public_ip" "publicip_vm" {
  name                = "pip-${local.vm_name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "nic-${local.vm_name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = local.ip_configuration_name
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip_vm.id
  }
}

# Add nic to load balancer
resource "azurerm_network_interface_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = local.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}

# Add nic to nsg
resource "azurerm_network_interface_security_group_association" "nsg_to_nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = local.vm_name
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "os-${local.vm_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = local.vm_name
    admin_username = "plankton"
    admin_password = "Password1234!"
    custom_data    = file("scripts/install-nginx.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
