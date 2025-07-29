# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains Terraform and Packer configurations for deploying infrastructure on Azure using HashiCorp Cloud Platform (HCP) stack. The project follows infrastructure-as-code principles with a focus on RHEL-based VM deployments.

## Common Commands

### Packer Operations
- Initialize Packer plugins: `cd packer && packer init rhel-azure.pkr.hcl`
- Validate Packer configuration: `packer validate -var-file="variables.auto.pkrvars.hcl" rhel-azure.pkr.hcl`
- Build RHEL image: `packer build -var-file="variables.auto.pkrvars.hcl" rhel-azure.pkr.hcl`

### Terraform Operations (typical workflow)
- Initialize: `terraform init`
- Plan: `terraform plan`
- Apply: `terraform apply`
- Destroy: `terraform destroy`

### Authentication Setup
- Azure CLI login: `az login`
- Set subscription: `az account set --subscription "your-subscription-id"`

## Architecture

### Directory Structure
- `packer/` - Contains Packer configuration for building custom RHEL images
  - `rhel-azure.pkr.hcl` - Main Packer configuration with Azure ARM builder
  - `variables.pkrvars.hcl` - Template for Packer variables (copy to `variables.auto.pkrvars.hcl`)
- `terraform/` - Terraform configurations organized by purpose
  - `environments/` - Environment-specific configurations (dev, staging, prod)
  - `modules/` - Reusable Terraform modules
  - `policies/` - Sentinel policies for governance
- `scripts/` - Helper scripts for automation
- `docs/` - Project documentation

### Key Configuration Files
- `packer/rhel-azure.pkr.hcl` - Builds RHEL 9.x images with Azure CLI, Docker, and security hardening
- `packer/variables.pkrvars.hcl` - Variable template requiring Azure subscription details

## Required Environment Variables

### Azure Authentication
- `ARM_CLIENT_ID` - Azure Client ID
- `ARM_CLIENT_SECRET` - Azure Client Secret  
- `ARM_SUBSCRIPTION_ID` - Azure Subscription ID
- `ARM_TENANT_ID` - Azure Tenant ID

### HCP Authentication (if using HCP features)
- `HCP_CLIENT_ID` - HCP Client ID
- `HCP_CLIENT_SECRET` - HCP Client Secret

## Prerequisites
- Terraform >= 1.0
- Packer >= 1.7
- Azure CLI installed and configured
- Valid Azure subscription
- HCP account (for HashiCorp Cloud Platform features)

## Important Notes
- Always copy `packer/variables.pkrvars.hcl` to `variables.auto.pkrvars.hcl` before customizing
- Never commit `.tfvars` files or `variables.auto.pkrvars.hcl` containing sensitive data
- The Packer build creates timestamped image names for versioning
- RHEL images include system updates, Azure CLI, Docker, and security hardening by default