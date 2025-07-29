# Packer Variables for RHEL Azure Build
# Copy this file to variables.auto.pkrvars.hcl and customize values

# Azure Configuration
subscription_id  = "your-azure-subscription-id-here"
resource_group   = "packer-builds-rg"
location         = "East US"
vm_size          = "Standard_B2s"

# Image Configuration  
image_name       = "rhel-custom"
image_version    = "1.0.0"