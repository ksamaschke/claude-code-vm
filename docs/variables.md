# Variable Reference Guide

This document provides a comprehensive reference of all variables available in the Claude Code VM deployment system. Variables are organized by source and functional category, with exact default values as defined in the codebase.

## Table of Contents

- [Overview](#overview)
- [Makefile Variables](#makefile-variables)
- [Global Ansible Variables](#global-ansible-variables)
- [Role-specific Variables](#role-specific-variables)
- [Usage Examples](#usage-examples)

## Overview

The deployment system uses variables from three main sources:

1. **Makefile Variables**: Command-line and environment variables for deployment control
2. **Global Ansible Variables**: System-wide configuration defined in `group_vars/all.yml`
3. **Role-specific Variables**: Component-specific settings in each role's `defaults/main.yml`

Variable precedence follows Ansible's standard order: command-line → environment → role defaults → group vars.

## Makefile Variables

These variables control deployment behavior and can be set via command line or environment variables.

### Connection Settings (Required)

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `VM_HOST` | *(empty)* | string | Target VM IP address (REQUIRED) |
| `VM_USER` | `root` | string | SSH user for deployment connection |
| `TARGET_USER` | *(empty)* | string | Target user on VM for configuration (REQUIRED) |

### Authentication Settings (Optional)

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `CONNECT_AS_TARGET` | `false` | boolean | Connect directly as target user instead of VM_USER |
| `TARGET_SSH_KEY` | *(empty)* | string | SSH private key path for target user authentication |
| `USE_SSH_PASSWORD` | `false` | boolean | Use password authentication instead of SSH keys |
| `SSH_PASSWORD` | *(empty)* | string | SSH password when USE_SSH_PASSWORD=true |
| `USE_BECOME_PASSWORD` | `false` | boolean | Sudo requires password on target system |
| `BECOME_PASSWORD` | *(empty)* | string | Sudo password when USE_BECOME_PASSWORD=true |

### Deployment Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `SESSION_NAME` | `DEV` | string | Screen session name for development environment |
| `DEPLOYMENT_DIR` | `/home/$(TARGET_USER)/.claude-code-vm` | string | Remote directory for deployment artifacts |
| `DEPLOY_TARGET` | `single` | string | Deployment target (single machine vs group) |

### File Paths

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `ENV_FILE` | `.env` | string | Environment file path containing credentials |
| `MCP_FILE` | `mcp-servers.json` | string | MCP server configuration file path |
| `SSH_KEY` | `~/.ssh/id_rsa` | string | Default SSH key path |
| `TEMP_BASE_PATH` | `.tmp` | string | Base path for temporary files |

### User Configuration Options

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `CREATE_USER_CLAUDE_CONFIG` | *(empty)* | boolean | Create user-specific CLAUDE.md configuration |
| `ALLOW_COMMAND_EXECUTION` | *(empty)* | boolean | Allow Claude Code to execute commands on VM |
| `SKIP_PACKAGE_UPGRADE` | *(empty)* | boolean | Skip system package upgrades during deployment |

### Ansible Configuration (Internal)

| Variable | Default | Description |
|----------|---------|-------------|
| `ANSIBLE_PLAYBOOK` | `ansible-playbook` | Ansible command executable |
| `PLAYBOOK_DIR` | `ansible/playbooks` | Directory containing playbooks |
| `LIMIT_FLAG` | `--limit target` | Ansible inventory limit flag |
| `EXTRA_VARS` | *(computed)* | Combined extra variables for Ansible |

### Terminal Colors (Internal)

| Variable | Value | Description |
|----------|-------|-------------|
| `RED` | `\033[0;31m` | Red color code |
| `GREEN` | `\033[0;32m` | Green color code |
| `YELLOW` | `\033[1;33m` | Yellow color code |
| `BLUE` | `\033[0;34m` | Blue color code |
| `PURPLE` | `\033[0;35m` | Purple color code |
| `CYAN` | `\033[0;36m` | Cyan color code |
| `WHITE` | `\033[1;37m` | White color code |
| `NC` | `\033[0m` | No color (reset) |

## Global Ansible Variables

These variables are defined in `ansible/inventories/production/group_vars/all.yml` and apply to all hosts.

### System Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `target_user` | `{{ target_vm_user \| default('developer') }}` | string | Target user (computed from target_vm_user) |
| `target_user_home` | `/home/{{ target_user }}` | string | Target user home directory |
| `debian_version` | `bookworm` | string | Debian version codename |

### Deployment Paths

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `deployment_base_dir` | `{{ custom_deployment_dir \| default('/home/' + target_user + '/.claude-code-vm') }}` | string | Base deployment directory |
| `scripts_dir` | `{{ deployment_base_dir }}/scripts` | string | Scripts directory |
| `config_dir` | `{{ deployment_base_dir }}/config` | string | Configuration directory |
| `logs_dir` | `{{ deployment_base_dir }}/logs` | string | Logs directory |
| `temp_dir` | `{{ deployment_base_dir }}/tmp` | string | Temporary files directory |
| `tools_dir` | `{{ deployment_base_dir }}/tools` | string | Tools directory |

### Screen Session Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `screen_session_name` | `{{ custom_session_name \| default('DEV') }}` | string | Screen session name |
| `screen_logs_dir` | `{{ logs_dir }}/screen` | string | Screen session logs directory |

### Docker Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `docker_install_compose` | `true` | boolean | Install Docker Compose |
| `docker_compose_version` | `latest` | string | Docker Compose version |

### Node.js Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `nodejs_version` | `22` | string | Node.js LTS version |
| `nodejs_install_method` | `nodesource` | string | Installation method (nodesource or nvm) |
| `nodejs_npm_global_packages` | `["@anthropic-ai/claude-code"]` | array | Global npm packages to install |

### Package Repositories

| Variable | Default | Description |
|----------|---------|-------------|
| `nodejs_repository` | `https://deb.nodesource.com/node_{{ nodejs_version }}.x` | Node.js APT repository |
| `docker_repository` | `https://download.docker.com/linux/debian` | Docker APT repository |

### Git Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_git_credential_manager` | `true` | boolean | Install Git Credential Manager |
| `install_git_credential_oauth` | `false` | boolean | Install Git Credential OAuth |
| `generate_ssh_keys` | `true` | boolean | Generate SSH keys for users |
| `git_user_name` | `""` | string | Git user name (read from .env) |
| `git_user_email` | `""` | string | Git user email (read from .env) |

### Personal Access Token Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `use_env_file` | `true` | boolean | Use .env file for configuration |
| `env_file_required` | `false` | boolean | Require .env file to exist |
| `configure_pats` | `true` | boolean | Configure Personal Access Tokens |
| `configure_git_signing` | `false` | boolean | Configure Git commit signing |
| `enable_ssh_url_conversion` | `false` | boolean | Convert HTTPS URLs to SSH |

### Kubernetes Tools Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_kubectl` | `true` | boolean | Install kubectl |
| `install_kind` | `true` | boolean | Install kind (Kubernetes in Docker) |
| `install_kompose` | `true` | boolean | Install kompose (Docker Compose to Kubernetes) |
| `install_bash_completion` | `true` | boolean | Install bash completion for tools |
| `kubernetes_version` | `v1.33` | string | Kubernetes version |
| `kind_version` | `v0.29.0` | string | kind version |
| `kompose_version` | `v1.36.0` | string | kompose version |

### Service Management

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `services_to_enable` | `["docker", "containerd"]` | array | System services to enable |

### Security Settings

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `disable_ipv6` | `false` | boolean | Disable IPv6 networking |
| `update_cache` | `true` | boolean | Update package cache |
| `upgrade_packages` | `true` | boolean | Upgrade system packages |

## Role-specific Variables

### Common Role

Defined in `ansible/roles/common/defaults/main.yml`

#### System Update Settings

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `update_cache` | `true` | boolean | Update APT package cache |
| `upgrade_packages` | `safe` | string | Package upgrade mode (safe/full/none) |
| `cache_valid_time` | `3600` | integer | APT cache validity time in seconds |

#### Package Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `essential_packages` | See below | array | Essential packages to install |
| `optional_packages` | `["htop", "tree", "vim"]` | array | Optional packages to install |

**Essential Packages Default:**
```yaml
essential_packages:
  - curl
  - wget
  - gnupg
  - lsb-release
  - apt-transport-https
  - ca-certificates
  - software-properties-common
  - build-essential
  - git
  - unzip
  - python3-pip
  - jq
```

#### System Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `configure_timezone` | `false` | boolean | Configure system timezone |
| `timezone` | `UTC` | string | Target timezone |

#### Cleanup Settings

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `remove_unused_packages` | `true` | boolean | Remove unused packages |
| `autoremove_packages` | `true` | boolean | Auto-remove orphaned packages |

#### Directory Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `deployment_base_dir` | `{{ custom_deployment_dir \| default('/home/' + target_user + '/.claude-code-vm') }}` | Deployment base directory |
| `scripts_dir` | `{{ deployment_base_dir }}/scripts` | Scripts directory |
| `screen_logs_dir` | `{{ deployment_base_dir }}/logs/screen` | Screen logs directory |

#### Screen Session Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `screen_session_name` | `{{ custom_session_name \| default('DEV') }}` | Screen session name |

### Git Role

Defined in `ansible/roles/git/defaults/main.yml`

#### Git Credential Provider Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_git_credential_manager` | `true` | boolean | Install Git Credential Manager |
| `install_git_credential_oauth` | `false` | boolean | Install Git Credential OAuth |
| `generate_ssh_keys` | `false` | boolean | Generate SSH keys for Git |

#### Git Credential Manager Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `gcm_version` | `2.6.0` | Git Credential Manager version |
| `gcm_download_url` | `https://github.com/git-ecosystem/git-credential-manager/releases/download/v{{ gcm_version }}/gcm-linux_amd64.{{ gcm_version }}.deb` | Download URL |
| `gcm_package_name` | `gcm-linux_amd64.{{ gcm_version }}.deb` | Package filename |
| `gcm_temp_dir` | `/tmp` | Temporary download directory |

#### SSH Key Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `ssh_key_type` | `ed25519` | SSH key algorithm |
| `ssh_key_comment` | `Generated by Ansible for {{ target_user }}@{{ inventory_hostname }}` | SSH key comment |
| `ssh_key_path` | `~/.ssh/id_{{ ssh_key_type }}` | SSH key file path |

#### Environment File Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `use_env_file` | `true` | boolean | Use .env file for configuration |
| `env_file_path` | `{{ playbook_dir }}/../.env` | string | Environment file path |
| `env_file_required` | `false` | boolean | Require .env file to exist |

#### Git Identity Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `configure_git_user` | `true` | boolean | Configure Git user identity |
| `git_user_name` | `""` | string | Git user name |
| `git_user_email` | `""` | string | Git user email |

#### Personal Access Token Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `configure_pats` | `true` | boolean | Configure Personal Access Tokens |

**Git Hosting Services Configuration:**
```yaml
git_hosting_services:
  github:
    name: "GitHub"
    url: "https://github.com"
    username_var: "GITHUB_USERNAME"
    token_var: "GITHUB_PAT"
    protocol: "https"
  gitlab:
    name: "GitLab"
    url: "https://gitlab.com"
    username_var: "GITLAB_USERNAME"
    token_var: "GITLAB_PAT"
    protocol: "https"
  azuredevops:
    name: "Azure DevOps"
    url: "https://dev.azure.com"
    username_var: "AZUREDEVOPS_USERNAME"
    token_var: "AZUREDEVOPS_PAT"
    protocol: "https"
  bitbucket:
    name: "Bitbucket"
    url: "https://bitbucket.org"
    username_var: "BITBUCKET_USERNAME"
    token_var: "BITBUCKET_PAT"
    protocol: "https"
  gitea:
    name: "Gitea"
    url_var: "GITEA_URL"
    username_var: "GITEA_USERNAME"
    token_var: "GITEA_PAT"
    protocol: "https"
  custom:
    name: "Custom Git Server"
    url_var: "CUSTOM_GIT_URL"
    username_var: "CUSTOM_GIT_USERNAME"
    token_var: "CUSTOM_GIT_PAT"
    protocol: "https"
```

#### Target Users and Advanced Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `configure_git_for_users` | `["{{ target_user }}"]` | array | Users to configure Git for |
| `configure_git_signing` | `false` | boolean | Configure Git commit signing |
| `enable_ssh_url_conversion` | `false` | boolean | Convert HTTPS URLs to SSH |
| `default_git_service` | `github` | string | Default Git service |
| `validate_installation` | `true` | boolean | Validate Git installation |

### Docker Role

Defined in `ansible/roles/docker/defaults/main.yml`

#### Docker Repository Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `docker_repo_url` | `https://download.docker.com/linux/debian` | Docker APT repository URL |
| `docker_gpg_key_url` | `https://download.docker.com/linux/debian/gpg` | Docker GPG key URL |
| `docker_gpg_key_path` | `/etc/apt/keyrings/docker.asc` | Docker GPG key file path |
| `docker_repo_file` | `/etc/apt/sources.list.d/docker.list` | Docker APT source file |

#### Docker Packages

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `docker_packages` | See below | array | Docker packages to install |
| `docker_conflicting_packages` | See below | array | Conflicting packages to remove |

**Docker Packages Default:**
```yaml
docker_packages:
  - docker-ce
  - docker-ce-cli
  - containerd.io
  - docker-buildx-plugin
  - docker-compose-plugin
```

**Conflicting Packages Default:**
```yaml
docker_conflicting_packages:
  - docker.io
  - docker-compose
  - podman-docker
  - containerd
  - runc
```

#### Docker Daemon Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `docker_daemon_config` | See below | Docker daemon configuration |

**Docker Daemon Config Default:**
```yaml
docker_daemon_config:
  log-driver: "json-file"
  log-opts:
    max-size: "10m"
    max-file: "3"
  storage-driver: "overlay2"
```

#### Service and User Management

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `docker_services` | `["docker", "containerd"]` | array | Docker services to manage |
| `docker_users` | `[]` | array | Users to add to docker group |
| `add_users_to_docker_group` | `true` | boolean | Add users to docker group |
| `validate_installation` | `true` | boolean | Validate Docker installation |

### Node.js Role

Defined in `ansible/roles/nodejs/defaults/main.yml`

#### Node.js Version Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `nodejs_version` | `22` | string | Node.js LTS version |
| `nodejs_install_method` | `nodesource` | string | Installation method (nodesource or nvm) |

#### NodeSource Repository Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `nodejs_repo_url` | `https://deb.nodesource.com/node_{{ nodejs_version }}.x` | NodeSource repository URL |
| `nodejs_gpg_key_url` | `https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key` | NodeSource GPG key URL |
| `nodejs_gpg_key_path` | `/etc/apt/keyrings/nodesource.gpg` | NodeSource GPG key path |
| `nodejs_repo_codename` | `nodistro` | NodeSource repository codename |

#### npm Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `npm_global_packages` | `[]` | array | Global npm packages to install |
| `configure_npm_for_user` | `true` | boolean | Configure npm for target user |
| `update_npm_to_latest` | `true` | boolean | Update npm to latest version |

#### Validation Settings

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `validate_installation` | `true` | boolean | Validate Node.js installation |
| `test_npm_install` | `false` | boolean | Test npm package installation |

### Claude Code Role

Defined in `ansible/roles/claude-code/defaults/main.yml`

#### Claude Code Package Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `claude_code_package` | `@anthropic-ai/claude-code` | string | Claude Code npm package name |
| `claude_code_version` | `latest` | string | Claude Code version |

#### Installation Settings

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_globally` | `true` | boolean | Install Claude Code globally |
| `force_reinstall` | `false` | boolean | Force reinstallation |

#### Validation Settings

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `validate_installation` | `true` | boolean | Validate Claude Code installation |
| `display_help` | `true` | boolean | Display help after installation |

#### Authentication Note

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `authentication_required` | `true` | boolean | Authentication is required |
| `authentication_note` | See below | string | Authentication instructions |

**Authentication Note Default:**
```yaml
authentication_note: |
  Claude Code requires authentication with an Anthropic account.
  After installation, run 'claude' to start the authentication process.
  You will need an active Anthropic account with billing enabled.
```

### Kubernetes Role

Defined in `ansible/roles/kubernetes/defaults/main.yml`

#### Kubernetes Repository Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `kubernetes_version` | `v1.33` | Kubernetes major.minor version |
| `kubernetes_repo_url` | `https://pkgs.k8s.io/core:/stable:/{{ kubernetes_version }}/deb/` | Kubernetes repository URL |
| `kubernetes_gpg_key_url` | `https://pkgs.k8s.io/core:/stable:/{{ kubernetes_version }}/deb/Release.key` | Kubernetes GPG key URL |
| `kubernetes_gpg_key_path` | `/etc/apt/keyrings/kubernetes-apt-keyring.gpg` | Kubernetes GPG key path |

#### kubectl Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_kubectl` | `true` | boolean | Install kubectl |
| `kubectl_hold_package` | `true` | boolean | Prevent kubectl automatic updates |

#### kind Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_kind` | `false` | boolean | Install kind (Kubernetes in Docker) |
| `kind_version` | `v0.29.0` | string | kind version |
| `kind_binary_url` | `https://kind.sigs.k8s.io/dl/{{ kind_version }}/kind-linux-amd64` | kind binary URL |
| `kind_install_path` | `/usr/local/bin/kind` | kind installation path |

#### k3s Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_k3s` | `true` | boolean | Install k3s (preselected) |
| `install_docker_with_k3s` | `true` | boolean | Keep Docker alongside k3s |
| `k3s_version` | `""` | string | Specific k3s version (empty for latest) |
| `k3s_channel` | `""` | string | k3s channel (stable/latest/testing) |
| `k3s_install_script_url` | `https://get.k3s.io` | string | k3s installation script URL |
| `k3s_config_dir` | `/etc/rancher/k3s` | string | k3s configuration directory |
| `k3s_kubeconfig_path` | `/etc/rancher/k3s/k3s.yaml` | string | k3s kubeconfig path |
| `k3s_user_kubeconfig_path` | `{{ target_user_home }}/.kube/config` | string | User kubeconfig path |
| `k3s_data_dir` | `/var/lib/rancher/k3s` | string | k3s data directory |
| `k3s_service_name` | `k3s` | string | k3s systemd service name |

#### Ingress Controller Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_nginx_ingress` | `true` | boolean | Install NGINX Ingress Controller |
| `k3s_ingress_controller` | `nginx` | string | Ingress controller type |
| `nginx_ingress_version` | `""` | string | NGINX Ingress version (empty for latest) |
| `nginx_ingress_manifest_url` | `https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml` | string | NGINX Ingress manifest URL |

#### User Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `create_user_claude_config` | `true` | boolean | Create user CLAUDE.md configuration |
| `allow_command_execution` | `true` | boolean | Allow Claude Code to execute commands |

#### kompose Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_kompose` | `true` | boolean | Install kompose |
| `kompose_version` | `v1.36.0` | string | kompose version |
| `kompose_binary_url` | `https://github.com/kubernetes/kompose/releases/download/{{ kompose_version }}/kompose-linux-amd64` | string | kompose binary URL |
| `kompose_install_path` | `/usr/local/bin/kompose` | string | kompose installation path |

#### Bash Completion Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_bash_completion` | `true` | boolean | Install bash completion |
| `bash_completion_package` | `bash-completion` | string | Bash completion package name |
| `configure_completions_for_users` | `["{{ target_user }}"]` | array | Users to configure completions for |

#### Validation Settings

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `validate_installation` | `true` | boolean | Validate Kubernetes tools installation |

### MCP Role

Defined in `ansible/roles/mcp/defaults/main.yml`

#### Directory Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `deployment_base_dir` | `{{ custom_deployment_dir \| default('/home/' + target_user + '/.claude-code-vm') }}` | Deployment base directory |
| `tools_dir` | `{{ deployment_base_dir }}/tools` | Tools directory |
| `temp_dir` | `{{ deployment_base_dir }}/tmp` | Temporary directory |

#### MCP Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `mcp_config_dir` | `{{ target_user_home }}/.claude` | MCP configuration directory |
| `mcp_config_file` | `{{ mcp_config_dir }}/mcp-servers.json` | MCP configuration file path |
| `mcp_template_file` | `mcp-servers.template.json` | MCP template file name |

#### Environment File Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `use_env_file` | `true` | boolean | Use .env file for configuration |
| `env_file_path` | `{{ custom_env_file \| default(playbook_dir + '/../.env') }}` | string | Environment file path |
| `mcp_servers_file` | `{{ custom_mcp_servers_file \| default(playbook_dir + '/../mcp-servers.json') }}` | string | MCP servers file path |

#### claude-code-mcp-management Tool Configuration

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `mcp_management_dir` | `{{ tools_dir }}/claude-code-mcp-management` | string | MCP management tool directory |
| `mcp_scope` | `user` | string | MCP scope (user or project) |
| `mcp_project_path` | `.` | string | Project path (when scope is project) |

#### Deprecated Configuration (Kept for Reference)

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `install_mcp_packages` | `false` | boolean | Install MCP packages (deprecated) |
| `mcp_packages` | `[]` | array | MCP packages list (deprecated) |
| `pull_docker_images` | `false` | boolean | Pull Docker images (deprecated) |
| `mcp_docker_images` | `[]` | array | Docker images list (deprecated) |

#### Validation Settings

| Variable | Default | Type | Description |
|----------|---------|------|-------------|
| `validate_mcp_config` | `true` | boolean | Validate MCP configuration |
| `create_backup` | `true` | boolean | Create backup before changes |

#### Claude Code Configuration Location Detection

| Variable | Default | Description |
|----------|---------|-------------|
| `claude_config_locations` | See below | Claude Code config search paths |

**Claude Config Locations Default:**
```yaml
claude_config_locations:
  - "{{ target_user_home }}/.claude"
  - "{{ target_user_home }}/.config/claude-code"
  - "{{ target_user_home }}/.local/share/claude-code"
```

#### Environment Variables for MCP Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `mcp_env_vars` | See below | Environment variables to include |

**MCP Environment Variables Default:**
```yaml
mcp_env_vars:
  - "BRAVE_API_KEY"
  - "TAVILY_API_KEY" 
  - "KAGI_API_KEY"
  - "PERPLEXITY_API_KEY"
  - "JINA_AI_API_KEY"
  - "UPSTASH_REDIS_REST_URL"
  - "UPSTASH_REDIS_REST_TOKEN"
  - "OPENAI_API_KEY"
  - "ANTHROPIC_API_KEY"
```

## Usage Examples

### Basic Deployment

```bash
# Minimal deployment with required variables
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer

# Deployment with SSH key authentication
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer TARGET_SSH_KEY=~/.ssh/mykey

# Deployment with password authentication
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer USE_SSH_PASSWORD=true SSH_PASSWORD=mypassword
```

### Environment Variables

Set variables in your shell environment:

```bash
export VM_HOST=192.168.1.100
export TARGET_USER=developer
export CREATE_USER_CLAUDE_CONFIG=true
export ALLOW_COMMAND_EXECUTION=true
make deploy
```

### Custom Configuration

```bash
# Use custom environment and MCP files
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer ENV_FILE=production.env MCP_FILE=prod-mcp.json

# Custom deployment directory
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer DEPLOYMENT_DIR=/opt/claude-code-vm
```

### Ansible Variable Overrides

Override any Ansible variable using extra vars:

```bash
# Override role defaults
ansible-playbook ansible/playbooks/site.yml -e vm_host=192.168.1.100 -e target_vm_user=developer -e nodejs_version=20

# Override multiple variables
ansible-playbook ansible/playbooks/site.yml -e @custom-vars.yml
```

### Component-specific Deployments

```bash
# Deploy only specific components
ansible-playbook ansible/playbooks/site.yml --tags git,docker
ansible-playbook ansible/playbooks/site.yml --tags kubernetes,mcp

# Deploy with custom variables for specific roles
ansible-playbook ansible/playbooks/site.yml --tags nodejs -e nodejs_version=18 -e npm_global_packages='["@anthropic-ai/claude-code","typescript"]'
```

This variable reference provides complete coverage of all configurable options in the Claude Code VM deployment system. Variables are defined with their exact default values as they appear in the codebase, ensuring accuracy for all deployment scenarios.