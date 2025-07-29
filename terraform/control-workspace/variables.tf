# Organization Configuration
variable "organization_name" {
  description = "HCP Terraform organization name"
  type        = string
  default     = "dlp-org"
}

variable "organization_id" {
  description = "HCP Terraform organization ID"
  type        = string
  default     = "org-mhf7eMEcUbJKwSys"
}

# GitHub Integration
variable "github_oauth_token" {
  description = "GitHub OAuth token for VCS integration"
  type        = string
  sensitive   = true
}

variable "module_repository" {
  description = "GitHub repository containing the workspace manager module"
  type        = string
  default     = "donnielpage/hcp_stack"
}

# Azure Credentials
variable "azure_subscription_id" {
  description = "Azure subscription ID for workspaces"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure service principal client ID"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure service principal client secret"
  type        = string
  sensitive   = true
}

# Project Configuration
variable "projects" {
  description = "Map of projects to create for organizing workspaces"
  type = map(object({
    description = string
  }))
  default = {
    infrastructure = {
      description = "Core infrastructure and networking workspaces"
    }
    applications = {
      description = "Application deployment workspaces"
    }
    security = {
      description = "Security and compliance workspaces"
    }
    shared-services = {
      description = "Shared services and utilities"
    }
  }
}

# Team Configuration
variable "teams" {
  description = "Map of teams to create for access control"
  type = map(object({
    visibility = string
    organization_permissions = object({
      manage_policies         = bool
      manage_policy_overrides = bool
      manage_workspaces      = bool
      manage_vcs_settings    = bool
    })
  }))
  default = {
    platform-engineers = {
      visibility = "organization"
      organization_permissions = {
        manage_policies         = true
        manage_policy_overrides = true
        manage_workspaces      = true
        manage_vcs_settings    = true
      }
    }
    developers = {
      visibility = "organization"
      organization_permissions = {
        manage_policies         = false
        manage_policy_overrides = false
        manage_workspaces      = false
        manage_vcs_settings    = false
      }
    }
    security-team = {
      visibility = "organization"
      organization_permissions = {
        manage_policies         = true
        manage_policy_overrides = false
        manage_workspaces      = false
        manage_vcs_settings    = false
      }
    }
  }
}

# Common Environment Variables for Workspaces
variable "common_environment_variables" {
  description = "Common environment variables to apply to all managed workspaces"
  type = map(object({
    value       = string
    description = string
    sensitive   = bool
  }))
  default = {
    TF_LOG = {
      value       = "INFO"
      description = "Terraform log level"
      sensitive   = false
    }
    TF_IN_AUTOMATION = {
      value       = "true"
      description = "Indicates Terraform is running in automation"
      sensitive   = false
    }
  }
}