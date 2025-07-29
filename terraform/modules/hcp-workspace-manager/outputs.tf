output "workspace_id" {
  description = "The ID of the created workspace"
  value       = tfe_workspace.managed_workspace.id
}

output "workspace_name" {
  description = "The name of the created workspace"
  value       = tfe_workspace.managed_workspace.name
}

output "workspace_url" {
  description = "The URL of the workspace in HCP Terraform"
  value       = "https://app.terraform.io/app/${var.organization}/workspaces/${tfe_workspace.managed_workspace.name}"
}

output "workspace_external_id" {
  description = "The external ID of the workspace"
  value       = tfe_workspace.managed_workspace.id
}

output "workspace_terraform_version" {
  description = "The Terraform version configured for the workspace"
  value       = tfe_workspace.managed_workspace.terraform_version
}

output "workspace_execution_mode" {
  description = "The execution mode of the workspace"
  value       = var.execution_mode
}

output "workspace_vcs_repo" {
  description = "VCS repository configuration"
  value = length(tfe_workspace.managed_workspace.vcs_repo) > 0 ? {
    identifier = tfe_workspace.managed_workspace.vcs_repo[0].identifier
    branch     = tfe_workspace.managed_workspace.vcs_repo[0].branch
  } : null
}

output "variable_ids" {
  description = "Map of variable names to their IDs"
  value = merge(
    { for k, v in tfe_variable.workspace_variables : k => v.id },
    { for k, v in tfe_variable.environment_variables : k => v.id }
  )
}

output "team_access_ids" {
  description = "Map of team access configurations to their IDs"
  value       = { for k, v in tfe_team_access.workspace_access : k => v.id }
}

output "notification_ids" {
  description = "Map of notification configurations to their IDs"
  value       = { for k, v in tfe_notification_configuration.workspace_notifications : k => v.id }
}