# HCP Terraform Control Workspace

This directory contains the Terraform configuration for managing a control workspace in HCP Terraform (Terraform Cloud). The control workspace is responsible for:

1. **Creating and managing other HCP Terraform workspaces**
2. **Setting up no-code modules for self-service workspace creation**
3. **Managing organization-level resources** (teams, projects, OAuth clients)
4. **Providing standardized workspace configurations**

## Architecture

```
┌─────────────────────────┐
│   Control Workspace     │
│  (this configuration)   │
├─────────────────────────┤
│ • Creates workspaces    │
│ • Manages teams/projects│
│ • Sets up no-code module│
│ • Configures OAuth      │
└─────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│    No-Code Module       │
│   (Self-Service UI)     │
├─────────────────────────┤
│ • Workspace creation    │
│ • GitHub repo linking   │
│ • Variable configuration│
│ • Team access setup     │
└─────────────────────────┘
            │
            ▼
┌─────────────────────────┐
│  Managed Workspaces     │
│ (Created via module)    │
├─────────────────────────┤
│ • Linked to GitHub      │
│ • Pre-configured vars   │
│ • Proper team access    │
│ • Tagged and organized  │
└─────────────────────────┘
```

## Prerequisites

1. **HCP Terraform Account**: Organization `dlp-org` with ID `org-mhf7eMEcUbJKwSys`
2. **API Token**: Generate from HCP Terraform user settings
3. **GitHub OAuth Token**: For repository integration
4. **Azure Service Principal**: For managed workspace authentication

## Setup Instructions

### 1. Prepare Environment Variables

```bash
# Set HCP Terraform token
export TFE_TOKEN="your-hcp-terraform-api-token"

# Optional: Set via file
terraform login
```

### 2. Configure Variables

```bash
# Copy and customize the variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your specific values:
# - GitHub OAuth token
# - Azure service principal credentials
# - Organization details
```

### 3. Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## What Gets Created

### Core Resources
- **Projects**: Organizational containers for workspaces
- **Teams**: Access control groups with different permission levels
- **OAuth Client**: GitHub integration for VCS-connected workspaces
- **Registry Module**: Private module for workspace management
- **No-Code Module**: Self-service interface for workspace creation

### Example Workspace
The configuration creates an example workspace to demonstrate the module usage:
- Connected to this GitHub repository
- Configured for Azure infrastructure
- Assigned to the infrastructure project
- Pre-populated with common variables

## Using the No-Code Module

After applying this configuration, users can create new workspaces through the HCP Terraform UI:

1. Navigate to: `https://app.terraform.io/app/dlp-org/registry/modules/private/dlp-org/workspace-manager/tfe`
2. Click "Provision workspace"
3. Fill in the self-service form:
   - Workspace name
   - Environment (dev/staging/prod)
   - GitHub repository
   - Terraform version
   - Working directory
   - Cloud provider settings

### Available Options
- **Environment**: dev, staging, prod
- **Terraform Version**: 1.11.0, 1.10.2, 1.9.8, 1.8.5
- **Execution Mode**: remote, local, agent
- **Working Directory**: /, /terraform, /infrastructure
- **Cloud Provider**: aws, azure, gcp, multi-cloud
- **GitHub Branch**: main, master, develop

## Module Structure

The workspace manager module (`../modules/hcp-workspace-manager/`) provides:

### Features
- **VCS Integration**: Automatic GitHub repository connection
- **Variable Management**: Terraform and environment variable configuration
- **Team Access**: Configurable permission assignments
- **Notifications**: Slack, email, and webhook integrations
- **Tagging**: Automatic tag assignment based on selections

### Outputs
- Workspace ID, name, and URL
- Variable and team access mappings
- VCS configuration details

## Common Workflows

### Creating a New Workspace Manually
```hcl
module "new_workspace" {
  source = "../modules/hcp-workspace-manager"
  
  workspace_name = "my-new-workspace"
  organization   = "dlp-org"
  github_repo    = "donnielpage/my-repo"
  
  environment_variables = {
    ARM_SUBSCRIPTION_ID = {
      value     = var.azure_subscription_id
      sensitive = true
    }
  }
}
```

### Bulk Workspace Creation
```hcl
module "dev_workspaces" {
  source = "../modules/hcp-workspace-manager"
  
  for_each = var.dev_repositories
  
  workspace_name = "${each.key}-dev"
  organization   = "dlp-org"
  github_repo    = each.value
  
  tags = ["dev", "managed", each.key]
}
```

## Security Considerations

- **Sensitive Variables**: All Azure credentials are marked as sensitive
- **Team Permissions**: Follow principle of least privilege
- **OAuth Scope**: GitHub integration limited to repository access
- **API Tokens**: Use workspace-specific tokens when possible

## Troubleshooting

### Common Issues

1. **OAuth Token Issues**
   - Ensure GitHub token has repo access
   - Verify organization permissions
   - Check token expiration

2. **Permission Errors**
   - Verify HCP Terraform organization membership
   - Check API token permissions
   - Ensure workspace-level access

3. **Module Registry Issues**
   - Confirm repository access
   - Verify VCS connection
   - Check module path structure

### Useful Commands

```bash
# Refresh OAuth token
terraform apply -replace=tfe_oauth_client.github

# Import existing workspace
terraform import module.example_workspace.tfe_workspace.managed_workspace ws-xxxxxxxxxxxxx

# List all workspaces
terraform state list | grep tfe_workspace
```

## Next Steps

After the control workspace is deployed:

1. **Train Teams**: Show users how to use the no-code interface
2. **Create Standards**: Establish naming conventions and tagging policies
3. **Monitor Usage**: Track workspace creation and resource consumption
4. **Iterate**: Gather feedback and improve the module based on usage patterns

## Related Documentation

- [HCP Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs)
- [No-Code Modules Guide](https://developer.hashicorp.com/terraform/cloud-docs/no-code-provisioning)
- [VCS Integration Setup](https://developer.hashicorp.com/terraform/cloud-docs/vcs)