# HCP Stack - Azure Infrastructure

This repository contains Terraform and Packer configurations for deploying infrastructure on Azure using HashiCorp Cloud Platform (HCP) stack.

## Project Structure

```
├── packer/                 # Packer configurations for image building
│   ├── rhel-azure.pkr.hcl # RHEL image configuration
│   └── variables.pkrvars.hcl # Variable definitions
├── terraform/              # Terraform configurations
│   ├── environments/       # Environment-specific configurations
│   │   ├── dev/           # Development environment
│   │   ├── staging/       # Staging environment
│   │   └── prod/          # Production environment
│   ├── modules/           # Reusable Terraform modules
│   └── policies/          # Sentinel policies
├── scripts/               # Helper scripts
└── docs/                  # Documentation
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Packer](https://www.packer.io/downloads) >= 1.7
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Valid Azure subscription and credentials
- HCP account (for HashiCorp Cloud Platform features)

## Getting Started

### 1. Azure Authentication

Login to Azure CLI:
```bash
az login
```

Set your subscription:
```bash
az account set --subscription "your-subscription-id"
```

### 2. Configure Variables

Copy the example variables file and customize:
```bash
cp packer/variables.pkrvars.hcl packer/variables.auto.pkrvars.hcl
```

Edit `packer/variables.auto.pkrvars.hcl` with your Azure subscription details.

### 3. Build RHEL Image

Initialize Packer plugins:
```bash
cd packer
packer init rhel-azure.pkr.hcl
```

Validate the configuration:
```bash
packer validate -var-file="variables.auto.pkrvars.hcl" rhel-azure.pkr.hcl
```

Build the image:
```bash
packer build -var-file="variables.auto.pkrvars.hcl" rhel-azure.pkr.hcl
```

## Environment Variables

Set the following environment variables for authentication:

### Azure
- `ARM_CLIENT_ID` - Azure Client ID
- `ARM_CLIENT_SECRET` - Azure Client Secret  
- `ARM_SUBSCRIPTION_ID` - Azure Subscription ID
- `ARM_TENANT_ID` - Azure Tenant ID

### HCP (if using HCP features)
- `HCP_CLIENT_ID` - HCP Client ID
- `HCP_CLIENT_SECRET` - HCP Client Secret

## Security Notes

- Never commit `.tfvars` files containing sensitive data
- Use Azure Key Vault or similar for storing secrets
- Follow principle of least privilege for service principals
- Regularly rotate credentials

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.