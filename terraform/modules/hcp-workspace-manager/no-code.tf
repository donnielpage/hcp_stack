# No-Code Module Configuration
# This file defines the no-code module that will be used in HCP Terraform
# to provide a self-service interface for creating workspaces

# Note: The no-code module resource is created in the control workspace
# This file documents the module structure for no-code usage

# Variable options that will be exposed in the no-code interface
locals {
  no_code_variable_options = {
    workspace_name = {
      display_name = "Workspace Name"
      description  = "Name for the new workspace (letters, numbers, hyphens, underscores only)"
      type         = "string"
      required     = true
      validation = {
        pattern = "^[a-zA-Z0-9-_]+$"
        message = "Must contain only letters, numbers, hyphens, and underscores"
      }
    }
    
    workspace_description = {
      display_name = "Workspace Description"
      description  = "Brief description of what this workspace manages"
      type         = "string"
      required     = false
      default      = "Managed workspace created via no-code module"
    }
    
    environment = {
      display_name = "Environment"
      description  = "Environment type for this workspace"
      type         = "string"
      required     = true
      options      = ["dev", "staging", "prod"]
    }
    
    terraform_version = {
      display_name = "Terraform Version"
      description  = "Terraform version to use"
      type         = "string"
      required     = false
      default      = "1.11.0"
      options      = ["1.11.0", "1.10.2", "1.9.8", "1.8.5"]
    }
    
    github_repo = {
      display_name = "GitHub Repository"
      description  = "GitHub repository (format: org/repo-name)"
      type         = "string"
      required     = false
      validation = {
        pattern = "^[a-zA-Z0-9-_.]+/[a-zA-Z0-9-_.]+$"
        message = "Must be in format: organization/repository-name"
      }
    }
    
    github_branch = {
      display_name = "GitHub Branch"
      description  = "Git branch to track"
      type         = "string"
      required     = false
      default      = "main"
      options      = ["main", "master", "develop"]
    }
    
    auto_apply = {
      display_name = "Auto Apply"
      description  = "Automatically apply approved plans"
      type         = "bool"
      required     = false
      default      = false
    }
    
    working_directory = {
      display_name = "Working Directory"
      description  = "Directory containing Terraform configuration"
      type         = "string"
      required     = false
      default      = "/"
      options      = ["/", "/terraform", "/infrastructure", "/terraform/environments/dev", "/terraform/environments/staging", "/terraform/environments/prod"]
    }
    
    execution_mode = {
      display_name = "Execution Mode"
      description  = "Where Terraform runs execute"
      type         = "string"
      required     = false
      default      = "remote"
      options      = ["remote", "local", "agent"]
    }
    
    project_assignment = {
      display_name = "Project Assignment"
      description  = "Project to assign workspace to"
      type         = "string"
      required     = false
      options      = ["networking", "applications", "security", "shared-services"]
    }
    
    cloud_provider = {
      display_name = "Cloud Provider"
      description  = "Primary cloud provider for this workspace"
      type         = "string"
      required     = false
      options      = ["aws", "azure", "gcp", "multi-cloud"]
    }
  }
  
  # Common tag combinations based on selections
  common_tag_patterns = {
    dev = ["development", "non-production", "testing"]
    staging = ["staging", "pre-production", "testing"]
    prod = ["production", "critical", "monitored"]
  }
}

# Provider configuration for no-code module
# This ensures the module is self-contained
provider "tfe" {
  hostname = "app.terraform.io"
  # Token should be provided via TFE_TOKEN environment variable
}

# Example variable sets that can be applied based on selections
locals {
  # AWS common variables
  aws_variables = var.cloud_provider == "aws" ? {
    AWS_DEFAULT_REGION = {
      value       = "us-east-1"
      description = "Default AWS region"
      sensitive   = false
    }
  } : {}
  
  # Azure common variables  
  azure_variables = var.cloud_provider == "azure" ? {
    ARM_SUBSCRIPTION_ID = {
      value       = "your-subscription-id"
      description = "Azure subscription ID"
      sensitive   = true
    }
  } : {}
  
  # GCP common variables
  gcp_variables = var.cloud_provider == "gcp" ? {
    GOOGLE_PROJECT = {
      value       = "your-project-id"
      description = "GCP project ID"
      sensitive   = false
    }
  } : {}
}

# Dynamic tags based on selections
locals {
  computed_tags = concat(
    [var.environment],
    var.cloud_provider != null ? [var.cloud_provider] : [],
    lookup(local.common_tag_patterns, var.environment, []),
    ["managed", "no-code"]
  )
}