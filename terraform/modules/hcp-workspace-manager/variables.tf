# Required Variables
variable "workspace_name" {
  description = "Name of the Terraform workspace"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.workspace_name))
    error_message = "Workspace name must contain only letters, numbers, hyphens, and underscores."
  }
}

variable "organization" {
  description = "HCP Terraform organization name"
  type        = string
  default     = "dlp-org"
}

# Optional Variables with Defaults
variable "workspace_description" {
  description = "Description of the workspace"
  type        = string
  default     = "Managed workspace created via Terraform"
}

variable "terraform_version" {
  description = "Terraform version to use in the workspace"
  type        = string
  default     = "1.11.0"
}

variable "auto_apply" {
  description = "Whether to automatically apply approved plans"
  type        = bool
  default     = false
}

variable "queue_all_runs" {
  description = "Whether to queue all runs"
  type        = bool
  default     = true
}

variable "file_triggers_enabled" {
  description = "Whether to trigger runs based on file changes"
  type        = bool
  default     = true
}

variable "allow_destroy_plan" {
  description = "Whether to allow destroy plans"
  type        = bool
  default     = true
}

variable "execution_mode" {
  description = "Execution mode for the workspace"
  type        = string
  default     = "remote"
  validation {
    condition     = contains(["remote", "local", "agent"], var.execution_mode)
    error_message = "Execution mode must be 'remote', 'local', or 'agent'."
  }
}

variable "working_directory" {
  description = "Working directory for Terraform operations"
  type        = string
  default     = "/"
}

variable "trigger_prefixes" {
  description = "List of paths that trigger runs when changed"
  type        = list(string)
  default     = []
}

# VCS Configuration
variable "github_repo" {
  description = "GitHub repository identifier (org/repo)"
  type        = string
  default     = null
}

variable "github_branch" {
  description = "GitHub branch to use"
  type        = string
  default     = "main"
}

variable "ingress_submodules" {
  description = "Whether to include Git submodules"
  type        = bool
  default     = false
}

# Project and Organization
variable "project_id" {
  description = "Project ID to assign the workspace to"
  type        = string
  default     = null
}

variable "tags" {
  description = "List of tags to apply to the workspace"
  type        = list(string)
  default     = []
}

# Variables Configuration
variable "workspace_variables" {
  description = "Map of Terraform variables to set in the workspace"
  type = map(object({
    value       = string
    category    = optional(string, "terraform")
    description = optional(string, "")
    sensitive   = optional(bool, false)
    hcl         = optional(bool, false)
  }))
  default = {}
}

variable "environment_variables" {
  description = "Map of environment variables to set in the workspace"
  type = map(object({
    value       = string
    description = optional(string, "")
    sensitive   = optional(bool, false)
  }))
  default = {}
}

# Team Access Configuration
variable "team_access" {
  description = "Map of team access configurations"
  type = map(object({
    team_id     = string
    permissions = string
  }))
  default = {}
  validation {
    condition = alltrue([
      for access in var.team_access : contains([
        "read", "plan", "write", "admin", "custom"
      ], access.permissions)
    ])
    error_message = "Team permissions must be one of: read, plan, write, admin, custom."
  }
}

# Notification Configuration
variable "notification_configurations" {
  description = "Map of notification configurations"
  type = map(object({
    enabled          = optional(bool, true)
    destination_type = string
    triggers         = list(string)
    url              = optional(string, "")
  }))
  default = {}
  validation {
    condition = alltrue([
      for config in var.notification_configurations : contains([
        "slack", "email", "webhook"
      ], config.destination_type)
    ])
    error_message = "Notification destination_type must be one of: slack, email, webhook."
  }
}

# No-code module variables
variable "environment" {
  description = "Environment type (used for no-code module)"
  type        = string
  default     = null
  validation {
    condition = var.environment == null || contains([
      "dev", "staging", "prod"
    ], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "cloud_provider" {
  description = "Primary cloud provider (used for no-code module)"
  type        = string
  default     = null
  validation {
    condition = var.cloud_provider == null || contains([
      "aws", "azure", "gcp", "multi-cloud"
    ], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, azure, gcp, multi-cloud."
  }
}