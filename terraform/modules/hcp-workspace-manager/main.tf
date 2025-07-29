
# Data source to get GitHub OAuth token
data "tfe_oauth_client" "github" {
  organization     = var.organization
  service_provider = "github"
}

# Create the workspace
resource "tfe_workspace" "managed_workspace" {
  name         = var.workspace_name
  organization = var.organization
  description  = var.workspace_description
  
  # Terraform settings
  terraform_version     = var.terraform_version
  auto_apply           = var.auto_apply
  queue_all_runs       = var.queue_all_runs
  file_triggers_enabled = var.file_triggers_enabled
  allow_destroy_plan   = var.allow_destroy_plan
  
  # Execution settings
  execution_mode    = var.execution_mode
  working_directory = var.working_directory
  trigger_prefixes  = var.trigger_prefixes
  
  # VCS integration
  dynamic "vcs_repo" {
    for_each = var.github_repo != null ? [1] : []
    content {
      identifier         = var.github_repo
      branch            = var.github_branch
      oauth_token_id    = data.tfe_oauth_client.github.oauth_token_id
      ingress_submodules = var.ingress_submodules
    }
  }
  
  # Project assignment
  project_id = var.project_id
  
  # Tags for organization
  tag_names = var.tags
}

# Create workspace variables
resource "tfe_variable" "workspace_variables" {
  for_each = var.workspace_variables
  
  key          = each.key
  value        = each.value.value
  category     = each.value.category
  workspace_id = tfe_workspace.managed_workspace.id
  description  = each.value.description
  sensitive    = each.value.sensitive
  hcl          = each.value.hcl
}

# Create environment variables
resource "tfe_variable" "environment_variables" {
  for_each = var.environment_variables
  
  key          = each.key
  value        = each.value.value
  category     = "env"
  workspace_id = tfe_workspace.managed_workspace.id
  description  = each.value.description
  sensitive    = each.value.sensitive
}

# Optional team access configuration
resource "tfe_team_access" "workspace_access" {
  for_each = var.team_access
  
  access       = each.value.permissions
  team_id      = each.value.team_id
  workspace_id = tfe_workspace.managed_workspace.id
}

# Optional notification configurations
resource "tfe_notification_configuration" "workspace_notifications" {
  for_each = var.notification_configurations
  
  name             = each.key
  enabled          = each.value.enabled
  destination_type = each.value.destination_type
  triggers         = each.value.triggers
  url              = each.value.url
  workspace_id     = tfe_workspace.managed_workspace.id
}