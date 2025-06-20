# Ansible Configuration Reference

This document provides comprehensive documentation for all Ansible configuration options, variables, roles, and usage patterns in the Claude Code VM deployment system.

## Table of Contents

- [Overview](#overview)
- [Configuration Variables](#configuration-variables)
- [Ansible Roles](#ansible-roles)
- [Playbooks](#playbooks)
- [Tags and Selective Deployment](#tags-and-selective-deployment)
- [Direct Ansible Usage](#direct-ansible-usage)
- [Advanced Configuration](#advanced-configuration)
- [Troubleshooting](#troubleshooting)

## Overview

The deployment system uses Ansible to automate the setup of a complete development environment on Debian VMs. The architecture follows Ansible best practices with:

- **Role-based structure** for modular deployment
- **Tag-based execution** for selective deployment
- **Dynamic inventory generation** for single-machine deployments
- **Comprehensive validation** of deployed components
- **Flexible configuration** through group variables and overrides

## Configuration Variables

### Core Connection Variables

These variables define how to connect to and configure the target VM:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `vm_host` | Yes | - | Target VM IP address or hostname |
| `target_user` | Yes | - | Username on the target VM for deployment |
| `vm_user` | No | `root` | SSH user for initial connection |
| `ansible_become` | No | `yes` | Use sudo for privilege escalation |
| `ansible_become_method` | No | `sudo` | Method for privilege escalation |

### Authentication Variables

Configure SSH and sudo authentication:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `connect_as_target_user` | No | `false` | Connect directly as target user |
| `target_user_ssh_key` | No | `~/.ssh/id_rsa` | SSH private key for authentication |
| `use_ssh_password` | No | `false` | Use password instead of SSH key |
| `ssh_password` | No | - | SSH password (if use_ssh_password=true) |
| `use_become_password` | No | `false` | Sudo requires password |
| `become_password` | No | - | Sudo password (if use_become_password=true) |

### Component Configuration Variables

Control which components are installed and configured:

#### System Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `upgrade_packages` | `true` | Upgrade system packages during deployment |
| `configure_timezone` | `false` | Set system timezone |
| `timezone` | `UTC` | Timezone to configure |
| `autoremove_packages` | `true` | Remove unused packages |
| `remove_unused_packages` | `true` | Clean apt cache |

#### Git Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `configure_git_credentials` | `true` | Setup Git credential management |
| `install_git_credential_manager` | `true` | Install Git Credential Manager |
| `install_git_credential_oauth` | `false` | Install git-credential-oauth |
| `configure_git_global_settings` | `true` | Configure global Git settings |
| `generate_ssh_key` | `true` | Generate SSH key for Git |

#### Docker Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `install_docker` | `true` | Install Docker CE |
| `install_docker_compose` | `true` | Install Docker Compose |
| `add_user_to_docker_group` | `true` | Add target user to docker group |
| `configure_docker_logging` | `true` | Configure Docker logging |

#### Node.js Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `configure_npm_for_user` | `true` | Configure npm for user-level packages |
| `update_npm_to_latest` | `true` | Update npm to latest version |
| `validate_installation` | `true` | Validate Node.js installation |
| `test_npm_install` | `false` | Test npm package installation |

#### Kubernetes Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `install_kubectl` | `true` | Install kubectl |
| `install_kind` | `false` | Install KIND (Kubernetes in Docker) |
| `install_k3s` | `true` | Install k3s lightweight Kubernetes |
| `install_docker_with_k3s` | `true` | Install Docker alongside k3s |
| `install_kompose` | `true` | Install Kompose (Docker Compose to Kubernetes) |
| `configure_bash_completion` | `true` | Configure bash completion for kubectl |
| `install_nginx_ingress` | `true` | Install NGINX Ingress Controller |
| `k3s_ingress_controller` | `nginx` | Default ingress controller for k3s |
| `k3s_version` | `""` | Specific k3s version (empty for latest) |
| `k3s_channel` | `""` | k3s release channel |
| `nginx_ingress_version` | `""` | NGINX Ingress version (empty for latest) |
| `k3s_user_kubeconfig_path` | `~/.kube/config` | Location for user kubeconfig |

#### Claude Code Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `install_claude_code` | `true` | Install Claude Code CLI |
| `configure_claude_code` | `true` | Configure Claude Code for user |
| `create_user_claude_config` | `true` | Create ~/.claude/CLAUDE.md for user |
| `allow_command_execution` | `true` | Allow remote command execution in CLAUDE.md |

#### MCP Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `install_mcp_servers` | `true` | Install MCP servers |
| `configure_mcp_for_user` | `true` | Configure MCP for user scope |
| `validate_mcp_installation` | `true` | Validate MCP installation |

### File Path Variables

Configure file locations and deployment settings:

| Variable | Default | Description |
|----------|---------|-------------|
| `remote_deployment_dir` | `/home/{{ target_user }}/.claude-code-vm` | Remote deployment directory |
| `scripts_dir` | `{{ target_user_home }}/.local/bin` | Scripts installation directory |
| `screen_logs_dir` | `{{ target_user_home }}/.screen-logs` | Screen session logs directory |
| `custom_session_name` | `DEV` | Default screen session name |

## Ansible Roles

### 1. Common Role (`roles/common`)

**Purpose**: System preparation and essential packages installation.

**Key Tasks**:
- System package updates and upgrades
- Essential package installation (curl, wget, git, etc.)
- Locale configuration (UTF-8 support)
- Screen installation and session management
- User directory preparation

**Variables**:
- `essential_packages`: List of required system packages
- `optional_packages`: Additional packages to install
- `cache_valid_time`: APT cache validity time (3600 seconds)

**Tags**: `common`, `system`, `packages`, `screen`, `session-management`

### 2. Git Role (`roles/git`)

**Purpose**: Git installation and credential management configuration.

**Key Tasks**:
- Git Credential Manager installation
- Multi-provider credential configuration (GitHub, GitLab, etc.)
- SSH key generation
- Global Git configuration

**Variables**:
- Git server configurations from environment variables
- Credential storage settings
- SSH key configuration

**Tags**: `git`, `credentials`, `ssh`

### 3. Docker Role (`roles/docker`)

**Purpose**: Docker CE and Docker Compose installation.

**Key Tasks**:
- Docker repository setup
- Docker CE installation
- Docker Compose installation
- User group configuration
- Service configuration

**Variables**:
- `docker_apt_key_url`: Docker APT repository key URL
- `docker_apt_repository`: Docker APT repository

**Tags**: `docker`, `container-runtime`

### 4. Node.js Role (`roles/nodejs`)

**Purpose**: Node.js installation via NodeSource repository.

**Key Tasks**:
- NodeSource repository setup
- Node.js LTS installation
- npm configuration for user-level packages
- Global npm packages installation
- PATH configuration

**Variables**:
- `nodejs_version`: Node.js version to install
- `npm_global_packages`: List of global npm packages
- `nodejs_repo_url`: NodeSource repository URL

**Tags**: `nodejs`, `npm`, `packages`

### 5. Claude Code Role (`roles/claude-code`)

**Purpose**: Claude Code CLI installation and configuration.

**Key Tasks**:
- Claude Code CLI installation via npm
- User configuration setup
- CLAUDE.md template generation
- MCP integration preparation

**Variables**:
- Claude Code version and configuration
- User-specific settings

**Tags**: `claude-code`, `ai`, `cli`

### 6. Kubernetes Role (`roles/kubernetes`)

**Purpose**: Kubernetes tools installation (kubectl, k3s, KIND, kompose).

**Key Tasks**:
- kubectl installation and configuration
- k3s installation with optional components
- NGINX Ingress Controller deployment
- Bash completion setup
- kubeconfig management

**Variables**:
- Kubernetes tool versions
- k3s configuration options
- Ingress controller settings

**Tags**: `kubernetes`, `k3s`, `kubectl`, `nginx-ingress`

### 7. MCP Role (`roles/mcp`)

**Purpose**: Model Context Protocol server installation and configuration.

**Key Tasks**:
- MCP server package installation
- Configuration file generation
- User-scope MCP setup
- API key management

**Variables**:
- MCP server list and versions
- Configuration templates
- API key settings

**Tags**: `mcp`, `model-context-protocol`, `claude-code-mcp`, `ai`

## Playbooks

### 1. Site Playbook (`playbooks/site.yml`)

**Purpose**: Main deployment playbook that orchestrates all roles.

**Usage**:
```bash
ansible-playbook ansible/playbooks/site.yml
```

**Features**:
- Executes all roles in proper order
- Supports tag-based selective deployment
- Handles dependencies between roles
- Provides comprehensive error handling

### 2. Validation Playbook (`playbooks/validate.yml`)

**Purpose**: Validates that all deployed components are working correctly.

**Usage**:
```bash
ansible-playbook ansible/playbooks/validate.yml
```

**Validation Areas**:
- System information and health
- Docker functionality and service status
- Node.js and npm configuration
- Claude Code CLI functionality
- Git configuration and credentials
- Kubernetes tools and cluster status
- MCP server configuration
- Overall system health

### 3. Minimal Deploy Playbook (`playbooks/minimal-deploy.yml`)

**Purpose**: Minimal deployment for testing and development.

**Usage**:
```bash
ansible-playbook ansible/playbooks/minimal-deploy.yml
```

**Features**:
- Reduced component set for faster deployment
- Testing and development focus
- Essential components only

## Tags and Selective Deployment

The Ansible system supports tag-based selective deployment for flexibility:

### Component Tags

Deploy specific components:

```bash
# Deploy only Git configuration
ansible-playbook ansible/playbooks/site.yml --tags git

# Deploy Docker and Node.js
ansible-playbook ansible/playbooks/site.yml --tags docker,nodejs

# Deploy Kubernetes tools only
ansible-playbook ansible/playbooks/site.yml --tags kubernetes

# Deploy MCP servers only
ansible-playbook ansible/playbooks/site.yml --tags mcp
```

### Functional Tags

Deploy by functionality:

```bash
# System preparation only
ansible-playbook ansible/playbooks/site.yml --tags system

# Credential management
ansible-playbook ansible/playbooks/site.yml --tags credentials

# Container runtimes
ansible-playbook ansible/playbooks/site.yml --tags container-runtime

# Development tools
ansible-playbook ansible/playbooks/site.yml --tags nodejs,claude-code
```

### Available Tags

| Tag | Description | Roles |
|-----|-------------|-------|
| `common` | System preparation | common |
| `system` | System packages and configuration | common |
| `git` | Git and credential management | git |
| `credentials` | Authentication setup | git |
| `docker` | Docker and Docker Compose | docker |
| `container-runtime` | Container technologies | docker |
| `nodejs` | Node.js and npm | nodejs |
| `npm` | npm configuration | nodejs |
| `claude-code` | Claude Code CLI | claude-code |
| `ai` | AI tools | claude-code, mcp |
| `kubernetes` | Kubernetes tools | kubernetes |
| `k3s` | k3s specific functionality | kubernetes |
| `kubectl` | kubectl installation | kubernetes |
| `nginx-ingress` | NGINX Ingress Controller | kubernetes |
| `mcp` | MCP servers | mcp |
| `model-context-protocol` | MCP functionality | mcp |
| `screen` | Screen session management | common |
| `session-management` | Terminal session setup | common |
| `validation` | Component validation | validate.yml |

## Direct Ansible Usage

### Basic Commands

Execute playbooks directly with Ansible:

```bash
# Full deployment
ansible-playbook ansible/playbooks/site.yml -i inventory.yml

# Validation only
ansible-playbook ansible/playbooks/validate.yml -i inventory.yml

# Dry run (check mode)
ansible-playbook ansible/playbooks/site.yml --check --diff

# Syntax check
ansible-playbook --syntax-check ansible/playbooks/site.yml
```

### Variable Override

Override variables from command line:

```bash
# Override single variable
ansible-playbook ansible/playbooks/site.yml -e "install_k3s=false"

# Override multiple variables
ansible-playbook ansible/playbooks/site.yml -e "install_k3s=false install_kind=true"

# Use variable file
ansible-playbook ansible/playbooks/site.yml -e "@custom-vars.yml"
```

### Inventory Management

Use different inventory configurations:

```bash
# Use specific inventory file
ansible-playbook ansible/playbooks/site.yml -i custom-inventory.yml

# Use production inventory
ansible-playbook ansible/playbooks/site.yml -i ansible/inventories/production/

# Dynamic inventory (single machine)
# Generated automatically by Make targets
```

### Advanced Options

```bash
# Verbose output
ansible-playbook ansible/playbooks/site.yml -v
ansible-playbook ansible/playbooks/site.yml -vvv  # Very verbose

# Limit to specific hosts
ansible-playbook ansible/playbooks/site.yml --limit target

# Start at specific task
ansible-playbook ansible/playbooks/site.yml --start-at-task "Install Docker"

# Run specific tags with check mode
ansible-playbook ansible/playbooks/site.yml --tags kubernetes --check
```

## Advanced Configuration

### Custom Inventory

Create custom inventory for multiple machines:

```yaml
---
all:
  children:
    debian_servers:
      hosts:
        vm1:
          ansible_host: 192.168.1.100
          ansible_user: developer
          target_user: developer
        vm2:
          ansible_host: 192.168.1.101
          ansible_user: admin
          target_user: admin
      vars:
        ansible_become: yes
        ansible_python_interpreter: /usr/bin/python3
```

### Group Variables

Configure role-specific variables in `group_vars/all.yml`:

```yaml
---
# Custom Node.js packages
npm_global_packages:
  - "@vue/cli"
  - "@angular/cli"
  - "typescript"
  - "ts-node"

# Custom k3s configuration
k3s_version: "v1.28.0+k3s1"
install_nginx_ingress: true
k3s_ingress_controller: "nginx"

# Custom Git configuration
configure_git_credentials: true
install_git_credential_manager: true

# Custom MCP servers
mcp_servers_template: "custom-mcp-template.json"
```

### Host-Specific Variables

Configure per-host variables in `host_vars/`:

```yaml
# host_vars/vm1.yml
---
target_user: "developer"
install_k3s: true
install_kind: false
custom_session_name: "DEV-VM1"

# host_vars/vm2.yml
---
target_user: "admin"
install_k3s: false
install_kind: true
custom_session_name: "TEST-VM2"
```

### Environment-Specific Configuration

Use different configurations for different environments:

```bash
# Development environment
ansible-playbook ansible/playbooks/site.yml -i ansible/inventories/development/

# Production environment  
ansible-playbook ansible/playbooks/site.yml -i ansible/inventories/production/

# Staging environment
ansible-playbook ansible/playbooks/site.yml -i ansible/inventories/staging/
```

## Troubleshooting

### Common Issues and Solutions

#### 1. SSH Connection Issues

**Problem**: Cannot connect to target VM

**Solutions**:
```bash
# Test SSH connectivity
ssh -o ConnectTimeout=10 user@host

# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa

# Test with verbose output
ansible-playbook ansible/playbooks/site.yml -vvv
```

#### 2. Sudo Permission Issues

**Problem**: Privilege escalation fails

**Solutions**:
```bash
# Test sudo access
ssh user@host sudo whoami

# Use become password
ansible-playbook ansible/playbooks/site.yml -e "use_become_password=true become_password=yourpassword"

# Check sudoers configuration
ssh user@host sudo visudo
```

#### 3. Package Installation Failures

**Problem**: APT packages fail to install

**Solutions**:
```bash
# Update package cache
ansible-playbook ansible/playbooks/site.yml --tags system

# Skip package upgrades if needed
ansible-playbook ansible/playbooks/site.yml -e "upgrade_packages=false"

# Check for package manager conflicts
ssh user@host sudo apt list --upgradable
```

#### 4. Docker Group Membership

**Problem**: User cannot access Docker without sudo

**Solutions**:
```bash
# Verify group membership
ssh user@host groups

# Re-login to activate group membership
ssh user@host "logout; login"

# Restart Docker service
ansible-playbook ansible/playbooks/site.yml --tags docker
```

#### 5. Kubernetes/k3s Issues

**Problem**: k3s cluster not accessible

**Solutions**:
```bash
# Check k3s service status
ssh user@host sudo systemctl status k3s

# Verify kubeconfig
ssh user@host k3s kubectl get nodes

# Check NGINX Ingress Controller
ssh user@host k3s kubectl get pods -n ingress-nginx
```

### Debug Mode

Enable debug mode for detailed troubleshooting:

```bash
# Ansible debug mode
ansible-playbook ansible/playbooks/site.yml --check --diff -vvv

# Make target debug mode
make deploy-debug VM_HOST=192.168.1.100 TARGET_USER=user

# Manual debugging
ansible target -m setup -i inventory.yml  # Gather facts
ansible target -m ping -i inventory.yml   # Test connectivity
```

### Log Analysis

Check logs for specific issues:

```bash
# Ansible execution logs
tail -f ansible.log

# System logs on target
ssh user@host sudo journalctl -f

# Docker logs
ssh user@host docker logs container_name

# k3s logs
ssh user@host sudo journalctl -u k3s -f
```

### Performance Optimization

Optimize Ansible execution:

```bash
# Parallel execution
ansible-playbook ansible/playbooks/site.yml --forks=10

# Pipelining (if supported)
export ANSIBLE_PIPELINING=True

# SSH multiplexing
export ANSIBLE_SSH_PIPELINING=True
```

This comprehensive documentation covers all aspects of the Ansible configuration and usage in the Claude Code VM deployment system. For additional help, refer to the official Ansible documentation or use the `make help` command for quick reference.