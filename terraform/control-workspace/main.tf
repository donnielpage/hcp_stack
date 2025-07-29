terraform {
  required_version = ">= 1.0"
  
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.68.1"
    }
  }
  
  # Configure remote backend for HCP Terraform
  cloud {
    organization = "dlp-org"
    
    workspaces {
      name = "control-workspace"
    }
  }
}

# Configure the TFE Provider
provider "tfe" {
  hostname = "app.terraform.io"
  # Token should be provided via TFE_TOKEN environment variable
}

# Data source for organization details
data "tfe_organization" "main" {
  name = var.organization_name
}

# Create or reference projects for organizing workspaces
resource "tfe_project" "projects" {
  for_each = var.projects
  
  name         = each.key
  organization = var.organization_name
  description  = each.value.description
}

# Create teams for workspace access management
resource "tfe_team" "teams" {
  for_each = var.teams
  
  name         = each.key
  organization = var.organization_name
  visibility   = each.value.visibility
  
  # Organization access permissions
  organization_access {
    manage_policies      = each.value.organization_permissions.manage_policies
    manage_policy_overrides = each.value.organization_permissions.manage_policy_overrides
    manage_workspaces    = each.value.organization_permissions.manage_workspaces
    manage_vcs_settings  = each.value.organization_permissions.manage_vcs_settings
  }
}

# GitHub OAuth client for VCS integration
resource "tfe_oauth_client" "github" {
  organization     = var.organization_name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_oauth_token
  service_provider = "github"
  name             = "GitHub OAuth for dlp-org"
}

# Upload the workspace manager module to the private registry
resource "tfe_registry_module" "workspace_manager" {
  organization = var.organization_name
  
  vcs_repo {
    display_identifier = var.module_repository
    identifier         = var.module_repository
    oauth_token_id     = tfe_oauth_client.github.oauth_token_id
    tags               = true
  }
  
  module_provider = "tfe"
  name           = "workspace-manager"
  registry_name  = "private"
}

# Create no-code module for self-service workspace creation
resource "tfe_no_code_module" "workspace_creator" {
  organization    = var.organization_name
  registry_module = tfe_registry_module.workspace_manager.id
  enabled         = true
  
  # Variable options for the no-code interface
  variable_options {
    name = "workspace_name"
    type = "string"
    options = []
  }
  
  variable_options {
    name = "environment"
    type = "string"
    options = ["dev", "staging", "prod"]
  }
  
  variable_options {
    name = "terraform_version"
    type = "string"
    options = ["1.11.0", "1.10.2", "1.9.8", "1.8.5"]
  }
  
  variable_options {
    name = "execution_mode"
    type = "string"
    options = ["remote", "local", "agent"]
  }
  
  variable_options {
    name = "working_directory"
    type = "string"
    options = ["/", "/terraform", "/infrastructure"]
  }
  
  variable_options {
    name = "cloud_provider"
    type = "string"
    options = ["aws", "azure", "gcp", "multi-cloud"]
  }
  
  variable_options {
    name = "github_branch"
    type = "string"
    options = ["main", "master", "develop"]
  }
}

# Example workspace created using the module
module "example_workspace" {
  source = "../modules/hcp-workspace-manager"
  
  workspace_name        = "example-infrastructure"
  workspace_description = "Example workspace created by control workspace"
  organization         = var.organization_name
  
  # VCS Configuration
  github_repo   = "donnielpage/hcp_stack"
  github_branch = "main"
  
  # Workspace Settings
  terraform_version     = "1.11.0"
  auto_apply           = false
  execution_mode       = "remote"
  working_directory    = "/terraform/environments/dev"
  
  # Project assignment
  project_id = tfe_project.projects["infrastructure"].id
  
  # Tags
  tags = ["example", "infrastructure", "managed"]
  
  # Common Azure environment variables
  environment_variables = {
    ARM_SUBSCRIPTION_ID = {
      value       = var.azure_subscription_id
      description = "Azure Subscription ID"
      sensitive   = true
    }
    ARM_TENANT_ID = {
      value       = var.azure_tenant_id
      description = "Azure Tenant ID"
      sensitive   = true
    }
  }
  
  # Terraform variables
  workspace_variables = {
    environment = {
      value       = "dev"
      description = "Environment name"
    }
    location = {
      value       = "East US"
      description = "Azure region"
    }
  }
}