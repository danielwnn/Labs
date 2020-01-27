# Configure the Microsoft Azure Provider
provider "azurerm" {
    version = "~> 1.33.1"
    skip_provider_registration = true # add this to avoid permission error for non-admin users
    /*
    subscription_id = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    client_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    client_secret   = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    tenant_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    */
}

provider "random" {
    version = "~> 2.2.1"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = var.resource_group_name
    location = var.location

    tags = var.tags
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "vnet-terraform"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = var.tags
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "subnet-default"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.0.2.0/24"
}

# Create public IP
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "publicip-01"
    location                     = azurerm_resource_group.myterraformgroup.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"
    domain_name_label            = var.hostname

    tags = var.tags
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "nsg-terraform"
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    
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

    tags = var.tags
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                        = "nic-terraform"
    location                    = azurerm_resource_group.myterraformgroup.location
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    network_security_group_id   = azurerm_network_security_group.myterraformnsg.id

    ip_configuration {
        name                          = "IpConfigurationTerraform"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = var.tags
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }
    
    byte_length = 8
}

# Generate random text for a unique storage account name
resource "random_string" "rndstr" {
  length  = 8
  lower   = true
  number  = true
  upper   = false
  special = false
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}" # ${random_string.rndstr.result}
    location                    = azurerm_resource_group.myterraformgroup.location
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = var.tags
    
    depends_on = [random_string.rndstr]
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "vm-terraform"
    location              = azurerm_resource_group.myterraformgroup.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "OsDiskTerraform"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = var.hostname
        admin_username = var.admin_username
        admin_password = var.admin_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
        /*
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzhwhqT9h..."
        } */
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = var.tags
}

output "vm_ip_address" {
    value = azurerm_public_ip.myterraformpublicip.ip_address
}
