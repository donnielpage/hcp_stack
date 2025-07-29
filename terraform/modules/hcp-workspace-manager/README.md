# HCP Workspace Manager Module

A Terraform module for creating and managing HCP Terraform (Terraform Cloud) workspaces with standardized configurations, VCS integration, and team access controls.

## Features

- 🏗️ **Workspace Creation**: Automated workspace provisioning with consistent settings
- 🔗 **VCS Integration**: Automatic GitHub repository connection via OAuth
- 🔐 **Access Control**: Team-based permissions and workspace access management
- 📊 **Variable Management**: Terraform and environment variable configuration
- 🏷️ **Tagging**: Automatic workspace tagging for organization
- 📧 **Notifications**: Slack, email, and webhook notification support
- 🎯 **Project Assignment**: Workspace organization within HCP Terraform projects

## Usage

### Basic Workspace Creation

```hcl
module "my_workspace" {
  source = "../../modules/hcp-workspace-manager"
  
  workspace_name = "my-infrastructure"
  organization   = "dlp-org"
  
  # Optional: Connect to GitHub repository
  github_repo   = "myorg/infrastructure-repo"
  github_branch = "main"
}
```

### Advanced Configuration

```hcl
module "production_workspace" {
  source = "../../modules/hcp-workspace-manager"
  
  # Required
  workspace_name        = "production-infrastructure"
  organization         = "dlp-org"
  
  # Workspace Configuration
  workspace_description = "Production infrastructure workspace"
  terraform_version     = "1.11.0"
  auto_apply           = false
  execution_mode       = "remote"
  working_directory    = "/terraform/environments/prod"
  
  # VCS Integration
  github_repo   = "myorg/infrastructure"
  github_branch = "main"
  trigger_prefixes = ["environments/prod/", "modules/"]
  
  # Project Assignment
  project_id = "prj-xxxxxxxxxxxxx"
  
  # Tagging
  tags = ["production", "critical", "infrastructure"]
  
  # Environment Variables
  environment_variables = {
    ARM_SUBSCRIPTION_ID = {
      value       = "12345678-1234-1234-1234-123456789012"
      description = "Azure Subscription ID"
      sensitive   = true
    }
    ARM_TENANT_ID = {
      value       = "87654321-4321-4321-4321-210987654321"
      description = "Azure Tenant ID"
      sensitive   = true
    }
    TF_LOG = {
      value       = "INFO"
      description = "Terraform logging level"
      sensitive   = false
    }
  }
  
  # Terraform Variables
  workspace_variables = {
    environment = {
      value       = "prod"
      description = "Environment name"
    }
    location = {
      value       = "East US"
      description = "Azure region"
    }
    instance_count = {
      value       = "3"
      description = "Number of instances"
      hcl         = true
    }
  }
  
  # Team Access
  team_access = {
    platform-team = {
      team_id     = "team-xxxxxxxxxxxxx"
      permissions = "admin"
    }
    developers = {
      team_id     = "team-yyyyyyyyyyyyy"
      permissions = "write"
    }
    security-team = {
      team_id     = "team-zzzzzzzzzzzzz"
      permissions = "read"
    }
  }
  
  # Notifications
  notification_configurations = {
    slack_alerts = {
      enabled          = true
      destination_type = "slack"
      triggers         = ["run:planning", "run:errored", "run:applied"]
      url             = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
    }
  }
}
```

### Multiple Workspaces with For-Each

```hcl
# Create workspaces for multiple environments
locals {
  environments = {
    dev = {
      auto_apply        = true
      terraform_version = "1.11.0"
      working_directory = "/terraform/environments/dev"
    }
    staging = {
      auto_apply        = false
      terraform_version = "1.11.0"
      working_directory = "/terraform/environments/staging"
    }
    prod = {
      auto_apply        = false
      terraform_version = "1.10.2"
      working_directory = "/terraform/environments/prod"
    }
  }
}

module "environment_workspaces" {
  source = "../../modules/hcp-workspace-manager"
  
  for_each = local.environments
  
  workspace_name        = "myapp-${each.key}"
  organization         = "dlp-org"
  workspace_description = "MyApp ${each.key} environment"
  
  # Environment-specific configuration
  auto_apply           = each.value.auto_apply
  terraform_version    = each.value.terraform_version
  working_directory    = each.value.working_directory
  
  # Common configuration
  github_repo   = "myorg/myapp-infrastructure"
  github_branch = "main"
  execution_mode = "remote"
  
  # Environment-specific tags
  tags = [each.key, "myapp", "managed"]
  
  # Common environment variables
  environment_variables = {
    ARM_SUBSCRIPTION_ID = {
      value     = var.azure_subscription_id
      sensitive = true
    }
    ENVIRONMENT = {
      value = each.key
    }
  }
}
```

## Input Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `workspace_name` | Name of the Terraform workspace | `string` |
| `organization` | HCP Terraform organization name | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `workspace_description` | Description of the workspace | `string` | `"Managed workspace created via Terraform"` |
| `terraform_version` | Terraform version to use | `string` | `"1.11.0"` |
| `auto_apply` | Automatically apply approved plans | `bool` | `false` |
| `queue_all_runs` | Queue all runs | `bool` | `true` |
| `execution_mode` | Execution mode (remote/local/agent) | `string` | `"remote"` |
| `working_directory` | Working directory for operations | `string` | `"/"` |
| `github_repo` | GitHub repository (org/repo) | `string` | `null` |
| `github_branch` | GitHub branch to track | `string` | `"main"` |
| `project_id` | Project ID to assign workspace | `string` | `null` |
| `tags` | List of tags to apply | `list(string)` | `[]` |

### Complex Variables

#### workspace_variables
Map of Terraform variables to set in the workspace:
```hcl
workspace_variables = {
  variable_name = {
    value       = "variable_value"
    category    = "terraform"        # optional, default: "terraform"
    description = "Variable purpose" # optional
    sensitive   = false             # optional, default: false
    hcl         = false            # optional, default: false
  }
}
```

#### environment_variables
Map of environment variables to set in the workspace:
```hcl
environment_variables = {
  ENV_VAR_NAME = {
    value       = "env_var_value"
    description = "Environment variable purpose" # optional
    sensitive   = false                         # optional, default: false
  }
}
```

#### team_access
Map of team access configurations:
```hcl
team_access = {
  team_name = {
    team_id     = "team-xxxxxxxxxxxxx"
    permissions = "read|plan|write|admin|custom"
  }
}
```

#### notification_configurations
Map of notification configurations:
```hcl
notification_configurations = {
  notification_name = {
    enabled          = true                                    # optional, default: true
    destination_type = "slack|email|webhook"
    triggers         = ["run:planning", "run:applied", ...]
    url             = "https://hooks.example.com/webhook"     # for slack/webhook
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| `workspace_id` | The ID of the created workspace |
| `workspace_name` | The name of the created workspace |
| `workspace_url` | The URL of the workspace in HCP Terraform |
| `workspace_external_id` | The external ID of the workspace |
| `workspace_terraform_version` | The Terraform version configured |
| `workspace_execution_mode` | The execution mode of the workspace |
| `workspace_vcs_repo` | VCS repository configuration |
| `variable_ids` | Map of variable names to their IDs |
| `team_access_ids` | Map of team access configurations to IDs |
| `notification_ids` | Map of notification configurations to IDs |

## Prerequisites

1. **HCP Terraform Organization**: Access to the specified organization
2. **GitHub OAuth Client**: Configured in the organization for VCS integration
3. **Team IDs**: Existing team IDs for access control configuration
4. **Project IDs**: Existing project IDs for workspace organization

## Permission Requirements

The executing user/token needs the following permissions:
- **Manage Workspaces**: Create and configure workspaces
- **Manage Variables**: Set workspace variables
- **Manage Team Access**: Configure workspace permissions
- **Manage VCS Settings**: Connect repositories (if using VCS integration)

## Best Practices

### Workspace Naming
- Use descriptive, consistent naming patterns
- Include environment and application identifiers
- Example: `myapp-prod`, `networking-dev`, `shared-services`

### Variable Management
- Mark sensitive variables appropriately
- Use descriptive variable descriptions
- Group related variables logically

### Team Access
- Follow principle of least privilege
- Use consistent permission levels across similar workspaces
- Document team responsibilities

### Tagging Strategy
- Include environment tags (`dev`, `staging`, `prod`)
- Add application/service tags
- Include management tags (`managed`, `no-code`)

## Examples

See the `examples/` directory for additional usage patterns:
- Basic workspace creation
- Multi-environment setup
- No-code module integration
- Advanced notification configuration

## Version Compatibility

| Module Version | HCP Terraform Provider | Terraform Version |
|----------------|----------------------|------------------|
| >= 1.0.0       | >= 0.68.1           | >= 1.0           |

## Contributing

When contributing to this module:
1. Update variable descriptions and validation
2. Add examples for new features
3. Update the README documentation
4. Test with multiple workspace configurations