output "organization_id" {
  description = "The organization ID"
  value       = data.tfe_organization.main.id
}

output "organization_name" {
  description = "The organization name"
  value       = data.tfe_organization.main.name
}

output "projects" {
  description = "Created projects and their IDs"
  value = {
    for name, project in tfe_project.projects : name => {
      id          = project.id
      name        = project.name
      description = project.description
    }
  }
}

output "teams" {
  description = "Created teams and their IDs"
  value = {
    for name, team in tfe_team.teams : name => {
      id   = team.id
      name = team.name
    }
  }
}

output "github_oauth_client" {
  description = "GitHub OAuth client information"
  value = {
    id               = tfe_oauth_client.github.id
    oauth_token_id   = tfe_oauth_client.github.oauth_token_id
    service_provider = tfe_oauth_client.github.service_provider
  }
}

output "registry_module" {
  description = "Registry module information"
  value = {
    id           = tfe_registry_module.workspace_manager.id
    name         = tfe_registry_module.workspace_manager.name
    organization = tfe_registry_module.workspace_manager.organization
    registry_name = tfe_registry_module.workspace_manager.registry_name
  }
}

output "no_code_module" {
  description = "No-code module information"
  value = {
    id      = tfe_no_code_module.workspace_creator.id
    enabled = tfe_no_code_module.workspace_creator.enabled
  }
}

output "example_workspace" {
  description = "Example workspace details"
  value = {
    id   = module.example_workspace.workspace_id
    name = module.example_workspace.workspace_name
    url  = module.example_workspace.workspace_url
  }
}

output "control_workspace_url" {
  description = "URL to the control workspace"
  value       = "https://app.terraform.io/app/${var.organization_name}/workspaces/control-workspace"
}

output "no_code_module_url" {
  description = "URL to access the no-code module interface"
  value       = "https://app.terraform.io/app/${var.organization_name}/registry/modules/private/${var.organization_name}/workspace-manager/tfe"
}