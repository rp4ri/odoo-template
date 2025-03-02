provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
#   client_id       = var.client_id
#   client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Grupo de recursos
resource "azurerm_resource_group" "rg" {
  name     = "OdooResourceGroup"
  location = "brazilsouth"
}

# Red virtual
resource "azurerm_virtual_network" "vnet" {
  name                = "odooVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subred
resource "azurerm_subnet" "subnet" {
  name                 = "odooSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# IP pública
resource "azurerm_public_ip" "public_ip" {
  name                = "odooPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Interfaz de red (NIC)
resource "azurerm_network_interface" "nic" {
  name                = "odooNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "odooIP"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Máquina Virtual Linux ARM64
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "odooVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"  # 🔄 Cambio a x86
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/id_rsa.pub")
  }

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"  # Igual que rodri-jex-livebook
    disk_size_gb         = 50
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    # sku       = "22_04-lts-arm64"  # Cambio a ARM64
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt update -y
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg -y; done

    sudo apt update -y
    sudo apt install ca-certificates curl gnupg lsb-release -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install Docker
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    # Add user to Docker group
    sudo groupadd docker
    sudo usermod -aG docker azureuser

    # Switch to 'ubuntu' user and execute commands
    su - azureuser <<EOF2
    # Generate SSH keys
    ssh-keygen -t rsa -b 4096 -C "rodrigo@ssventures.com" -f ~/.ssh/id_rsa -N ""

    # Start the SSH agent and add the key
    eval \$(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa

    # Ensure correct permissions for the '.ssh' directory
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/id_rsa.pub
    EOF2
  EOF
  )

  depends_on = [azurerm_network_interface.nic]  
}


# Grupo de seguridad de red (NSG)
resource "azurerm_network_security_group" "nsg" {
  name                = "odooNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Regla para permitir SSH (puerto 22)
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Asociar el NSG a la NIC
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
