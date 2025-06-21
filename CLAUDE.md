# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Architecture

This repository contains an **Ansible-based deployment system** that automates the setup of complete development environments on **remote Debian VMs**. You run this system from your local machine to deploy development tools to target VMs. The architecture follows Ansible best practices with a role-based structure for modular deployment.

### Core Components

- **Ansible Playbooks**: Main orchestration (`ansible/playbooks/site.yml`)
- **Role-based Architecture**: Modular components in `ansible/roles/`
  - `common`: System preparation and updates
  - `git`: Git with credential management for multiple hosting services  
  - `docker`: Docker CE with Docker Compose
  - `nodejs`: Node.js 22 LTS with npm global packages
  - `claude-code`: Claude Code CLI installation
  - `kubernetes`: kubectl, k3s (preselected), kind (optional), kompose with bash completions
  - `mcp`: MCP server configuration and deployment
- **Environment Configuration**: Git credential system via `.env` file (created from `config/env.example`)

### Git Credential System

The project implements a flexible credential management system supporting multiple Git hosting services through environment variables:

**Well-known providers (URL automatic):**
- `GITHUB_USERNAME` and `GITHUB_PAT` for GitHub.com
- `GITLAB_USERNAME` and `GITLAB_PAT` for GitLab.com

**Custom/Self-hosted servers:**
- Pattern: `GIT_{NAME}_{FIELD}` where NAME is your choice
- `GIT_{NAME}_URL`, `GIT_{NAME}_USERNAME`, `GIT_{NAME}_PAT`

Supports GitHub, GitLab, Azure DevOps, GitHub Enterprise, and any custom Git servers.

### Deployment Target Architecture

This system deploys to **remote Debian VMs**, not your local machine. The deployment includes:
- Development tools (Git, Docker, Node.js, Kubernetes tools)
- Claude Code CLI installation on the target VM
- Credential management for Git hosting services
- Optional MCP server configuration for the remote Claude Code installation

## Essential Commands

### Primary Deployment Commands
```bash
# Full deployment workflow
make setup                                              # First-time setup, creates .env from template
make check-config                                       # Validate configuration
make test-connection VM_HOST=<ip> TARGET_USER=<user>   # Test SSH connectivity to target VM
make deploy VM_HOST=<ip> TARGET_USER=<user>             # Deploy complete development stack to remote VM
make validate VM_HOST=<ip> TARGET_USER=<user>           # Verify all components on remote VM

# Component-specific deployment to remote VM (use Ansible directly)
ansible-playbook ansible/playbooks/site.yml --tags git -e vm_host=<ip> -e target_vm_user=<user>
ansible-playbook ansible/playbooks/site.yml --tags docker -e vm_host=<ip> -e target_vm_user=<user>
ansible-playbook ansible/playbooks/site.yml --tags nodejs -e vm_host=<ip> -e target_vm_user=<user>
ansible-playbook ansible/playbooks/site.yml --tags claude-code -e vm_host=<ip> -e target_vm_user=<user>
ansible-playbook ansible/playbooks/site.yml --tags kubernetes -e vm_host=<ip> -e target_vm_user=<user>
```

### Maintenance and Updates
```bash
# Update configurations on target VM
make deploy VM_HOST=<ip> TARGET_USER=<user>    # Redeploy with updated .env configuration
make validate VM_HOST=<ip> TARGET_USER=<user>  # Verify all components after changes

# MCP Management (for target VM configuration)
cd tools/claude-code-mcp-management
make help                                       # Show available MCP management commands
```

### Validation and Testing
```bash
make validate                 # Complete deployment validation
make test-connection         # Test SSH connectivity to target VM
make clean                   # Clean up temporary files and logs

# Ansible validation
ansible-playbook --syntax-check ansible/playbooks/site.yml
ansible-playbook --check --diff ansible/playbooks/site.yml
ansible debian-vm -m ping
```

### Debugging and Troubleshooting
```bash
# Verbose deployment
ansible-playbook ansible/playbooks/site.yml -v    # Verbose
ansible-playbook ansible/playbooks/site.yml -vv   # More verbose
ansible-playbook ansible/playbooks/site.yml -vvv  # Very verbose

# Debug specific issues
make clean                    # Clean up temporary files and logs
tail -f deployment.log        # Monitor deployment logs
```

### Direct Ansible Commands
```bash
# Core playbook execution
ansible-playbook playbooks/site.yml
ansible-playbook playbooks/validate.yml

# Tag-based selective deployment
ansible-playbook playbooks/site.yml --tags git
ansible-playbook playbooks/site.yml --tags docker,kubernetes
ansible-playbook playbooks/site.yml --tags credentials,pats

# Testing and validation
ansible-playbook --syntax-check playbooks/site.yml
ansible-playbook --check --diff playbooks/site.yml
ansible debian-vm -m ping
```

## Configuration Requirements

### Prerequisites
1. **Local machine (control machine)**: Ansible installed
2. **Target VM**: Debian 12+ (Bookworm) with SSH access
3. **SSH access**: Key-based or password authentication to target VM
4. **Sudo privileges**: Target user must have sudo access on the VM
5. **Configuration**: `.env` file with Git credentials (use `make setup` to create from template)

### Critical Configuration Files
- `ansible/inventories/production/hosts.yml`: Target VM configuration
- `ansible/inventories/production/group_vars/all.yml`: Component versions and settings
- `.env`: Git credentials, PATs, and MCP API keys (create from `config/env.example`)
- `mcp-servers.json`: MCP server configuration
- `config/mcp-servers.template.json`: Template for MCP server configuration

### Environment Variables Setup
1. Copy template: `cp config/env.example .env`
2. Edit `.env` with your Git hosting service credentials
3. Required: At least one Git server configuration (GITHUB_USERNAME/GITHUB_PAT or custom GIT_* variables)
4. Optional: MCP API keys (will be configured on the target VM for Claude Code)

The system automatically configures Git servers on the target VM based on environment variables.

## Deployment Workflow

1. **First-time setup**: `make setup` → edit `.env` → `make check-config`
2. **Test connectivity**: `make test-connection VM_HOST=192.168.1.100 TARGET_USER=developer`
3. **Deploy to remote VM**: `make deploy VM_HOST=192.168.1.100 TARGET_USER=developer`
4. **Validate remote deployment**: `make validate VM_HOST=192.168.1.100 TARGET_USER=developer`
5. **Update configuration**: Edit `.env` → redeploy with `make deploy`

**Important**: All deployment happens TO the target VM, not on your local machine. The Makefile provides colored output and comprehensive help via `make help`.

## Post-Deployment (What Gets Installed on Target VM)

After successful deployment, the **target VM** will have:
- **Docker**: Running without sudo for the target user
- **Node.js 22 LTS**: With Claude Code CLI globally installed
- **Git**: Configured with encrypted credential storage for all defined hosting services
- **Kubernetes tools**: kubectl, k3s (preselected), kind (optional), kompose with bash completions
- **Claude Code CLI**: Installed and ready to use
- **SSH keys**: Generated for additional authentication options
- **Optional**: User CLAUDE.md configuration with environment-specific guidance

### User CLAUDE.md Configuration (on Target VM)

The deployment can optionally create `~/.claude/CLAUDE.md` on the target VM containing:
- **Environment Overview**: What was actually deployed (k3s/KIND/Docker)
- **Command Execution Policy**: Remote command execution settings
- **Git Workflow**: Branch policy with required .gitignore patterns
- **Quick Reference**: Aliases, paths, and environment-specific commands

**Important**: Users on the target VM must log out/in or run `source ~/.bashrc` to update PATH and group memberships after deployment.