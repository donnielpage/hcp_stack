# Packer configuration for RHEL image on Azure
# This builds a custom RHEL image with base configurations

packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

# Variables
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "resource_group" {
  type        = string
  description = "Resource group for build resources"
  default     = "packer-builds-rg"
}

variable "location" {
  type        = string
  description = "Azure region for build"
  default     = "East US"
}

variable "vm_size" {
  type        = string
  description = "VM size for build instance"
  default     = "Standard_B2s"
}

variable "image_name" {
  type        = string
  description = "Name for the output image"
  default     = "rhel-custom"
}

variable "image_version" {
  type        = string
  description = "Version tag for the image"
  default     = "1.0.0"
}

# Local variables
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

# Source configuration for Azure ARM builder
source "azure-arm" "rhel" {
  # Authentication - use environment variables:
  # ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
  subscription_id = var.subscription_id
  
  # Build configuration
  resource_group_name     = var.resource_group
  location                = var.location
  vm_size                 = var.vm_size
  
  # Source image - RHEL 9.x from Azure Marketplace
  image_publisher = "RedHat"
  image_offer     = "RHEL"
  image_sku       = "9-lvm-gen2"
  image_version   = "latest"
  
  # Output configuration
  managed_image_name                = "${var.image_name}-${local.timestamp}"
  managed_image_resource_group_name = var.resource_group
  
  # Build VM configuration
  os_type         = "Linux"
  ssh_username    = "packer"
  ssh_timeout     = "20m"
  
  # Tags
  azure_tags = {
    Environment = "Build"
    Tool        = "Packer"
    OS          = "RHEL"
    Version     = var.image_version
    BuildTime   = local.timestamp
  }
}

# Build configuration
build {
  name = "rhel-azure-build"
  sources = ["source.azure-arm.rhel"]
  
  # Update system packages
  provisioner "shell" {
    inline = [
      "echo 'Starting system update...'",
      "sudo dnf update -y",
      "sudo dnf install -y curl wget vim git htop",
      "echo 'System update completed'"
    ]
  }
  
  # Install Azure CLI
  provisioner "shell" {
    inline = [
      "echo 'Installing Azure CLI...'",
      "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc",
      "sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm",
      "sudo dnf install -y azure-cli",
      "az version"
    ]
  }
  
  # Install Docker
  provisioner "shell" {
    inline = [
      "echo 'Installing Docker...'",
      "sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo",
      "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker $USER"
    ]
  }
  
  # System hardening and cleanup
  provisioner "shell" {
    inline = [
      "echo 'Performing system cleanup...'",
      "sudo dnf clean all",
      "sudo rm -rf /var/cache/dnf/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      "history -c",
      "echo 'Build completed successfully'"
    ]
  }
  
  # Generalize the image (Azure specific)
  provisioner "shell" {
    inline = [
      "echo 'Preparing image for generalization...'",
      "sudo waagent -deprovision+user -force"
    ]
  }
}