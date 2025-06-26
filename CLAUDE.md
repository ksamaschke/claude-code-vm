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

### Git Repository Management

The system includes automated repository cloning and management features:

**Repository Configuration:**
- `GIT_REPO_{NUMBER}_URL` - Repository URL (required)
- `GIT_REPO_{NUMBER}_BRANCH` - Specific branch to checkout
- `GIT_REPO_{NUMBER}_DIR` - Custom directory name
- `GIT_REPO_{NUMBER}_DEPTH` - Clone depth for shallow clones

**Advanced Configuration:**
- `GIT_REPO_{NUMBER}_CONFIG_{KEY}` - Per-repository Git configuration
- `GIT_REPO_{NUMBER}_REMOTE_{NAME}` - Additional remote repositories
- `GIT_REPO_{NUMBER}_POST_CLONE` - Commands to execute after cloning

**Management Options:**
- `MANAGE_GIT_REPOSITORIES="true"` - Enable repository management
- `GIT_REPOS_BASE_DIR` - Base directory for all repositories
- `GIT_DEFAULT_BRANCH` - Default branch for all repositories
- `GIT_UPDATE_EXISTING` - Update existing repositories on subsequent runs

### Deployment Target Architecture

This system deploys to **remote Debian VMs**, not your local machine. The deployment includes:
- Core development tools (Git, Node.js)
- Optional containerization (Docker, Docker Compose)
- Optional Kubernetes tools (kubectl, k3s, kind, kompose)
- Claude Code CLI installation on the target VM
- Credential management for Git hosting services
- Optional MCP server configuration for the remote Claude Code installation

## Essential Commands

### 4-Tier Deployment System

The deployment system offers four distinct tiers, each building upon the previous:

```bash
# Setup (run once)
make setup                                              # First-time setup, creates .env from template
make check-config                                       # Validate configuration
make test-connection VM_HOST=<ip> TARGET_USER=<user>   # Test SSH connectivity to target VM

# Tier 1: Baseline - Git + Node.js + Claude Code + uvx
make deploy-baseline VM_HOST=<ip> TARGET_USER=<user>    # Minimal core development environment

# Tier 2: Enhanced - Baseline + MCPs + Docker
make deploy-enhanced VM_HOST=<ip> TARGET_USER=<user>    # Adds MCP servers and Docker (needed for many MCPs)

# Tier 3: Containerized - Enhanced + Docker Compose + bashrc integrations
make deploy-containerized VM_HOST=<ip> TARGET_USER=<user> # Adds container orchestration and shell enhancements

# Tier 4: Full - Everything + Kubernetes + comprehensive bashrc
make deploy-full VM_HOST=<ip> TARGET_USER=<user>        # Complete development stack with k3s (default)
make deploy-full VM_HOST=<ip> TARGET_USER=<user> KUBERNETES_BACKEND=kind # Use KIND instead of k3s

# Validation
make validate VM_HOST=<ip> TARGET_USER=<user>           # Verify all components on remote VM
```

### Advanced Configuration Options
```bash
# Git repository management
make deploy-enhanced VM_HOST=<ip> TARGET_USER=<user> MANAGE_GIT_REPOSITORIES=true
make deploy-enhanced VM_HOST=<ip> TARGET_USER=<user> GIT_CONFIG_FILE=.git-repos.env

# Kubernetes backend selection
make deploy-full VM_HOST=<ip> TARGET_USER=<user> KUBERNETES_BACKEND=k3s    # Default
make deploy-full VM_HOST=<ip> TARGET_USER=<user> KUBERNETES_BACKEND=kind   # Alternative

# Component-specific deployment (use Ansible directly)
ansible-playbook ansible/playbooks/site.yml --tags git,git-repos -e vm_host=<ip> -e target_vm_user=<user>
ansible-playbook ansible/playbooks/site.yml --tags docker -e vm_host=<ip> -e target_vm_user=<user> -e install_docker=true
ansible-playbook ansible/playbooks/site.yml --tags kubernetes -e vm_host=<ip> -e target_vm_user=<user> -e install_kubectl=true
ansible-playbook ansible/playbooks/site.yml --tags bashrc -e vm_host=<ip> -e target_vm_user=<user> -e enable_bashrc_integrations=true
```

### Maintenance and Updates
```bash
# Update configurations on target VM (redeploy same tier)
make deploy-baseline VM_HOST=<ip> TARGET_USER=<user>     # Update baseline components
make deploy-enhanced VM_HOST=<ip> TARGET_USER=<user>     # Update enhanced components
make deploy-containerized VM_HOST=<ip> TARGET_USER=<user> # Update containerized components
make deploy-full VM_HOST=<ip> TARGET_USER=<user>         # Update full deployment

# Validate after changes
make validate VM_HOST=<ip> TARGET_USER=<user>           # Verify all components

# MCP Management (for target VM configuration)
cd tools/claude-code-mcp-management
make help                                               # Show available MCP management commands
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
3. **Choose deployment type**:
   - Base system: `make deploy-base VM_HOST=192.168.1.100 TARGET_USER=developer`
   - Full system: `make deploy VM_HOST=192.168.1.100 TARGET_USER=developer`
4. **Validate remote deployment**: `make validate VM_HOST=192.168.1.100 TARGET_USER=developer`
5. **Update configuration**: Edit `.env` → redeploy with appropriate make command

**Important**: All deployment happens TO the target VM, not on your local machine. The Makefile provides colored output and comprehensive help via `make help`.

### Git Repository Management Usage

**Option 1: Using main .env file**
```bash
# Edit .env file to include repository definitions and enable management
MANAGE_GIT_REPOSITORIES="true"
GIT_REPO_1_URL="https://github.com/yourusername/project1.git"
GIT_REPO_2_URL="https://github.com/yourusername/project2.git"
GIT_REPO_2_BRANCH="develop"

# Deploy with repository management enabled
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=developer MANAGE_GIT_REPOSITORIES=true
```

**Option 2: Using separate Git configuration file**
```bash
# Create dedicated Git configuration file
cp config/git-repos.env.example .git-repos.env
# Edit .git-repos.env with your repositories

# Deploy using separate Git config file
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=developer GIT_CONFIG_FILE=.git-repos.env MANAGE_GIT_REPOSITORIES=true
```

**Option 3: Repository management only**
```bash
# Deploy only Git repository management (requires existing Git setup)
ansible-playbook ansible/playbooks/site.yml --tags git-repos -e vm_host=192.168.1.100 -e target_vm_user=developer -e manage_git_repositories=true
```

## Post-Deployment (What Gets Installed on Target VM)

### Tier 1: Baseline Deployment (`deploy-baseline`)
- **System preparation**: Package updates, locale configuration, essential packages
- **Git**: Configured with encrypted credential storage for all defined hosting services
- **Git repository management** (optional): Automatic repository cloning and configuration
- **Node.js 22 LTS**: With npm global configuration and PATH setup
- **Claude Code CLI**: Installed globally via npm and ready to use
- **uvx**: Python package runner for isolated tool execution

### Tier 2: Enhanced Deployment (`deploy-enhanced`)
- **Everything from Tier 1**
- **MCP servers**: Configured based on your mcp-servers.json with environment variables
- **Docker**: Running without sudo for the target user (needed for many MCP servers)
- **Docker group integration**: User added to docker group for passwordless container management

### Tier 3: Containerized Deployment (`deploy-containerized`)
- **Everything from Tier 2**
- **Docker Compose**: Latest version with proper binary installation and dynamic version resolution
- **Enhanced bashrc**: Docker aliases, shortcuts, and productivity enhancements
- **Shell integrations**: Comprehensive aliases for Docker commands (dps, dcp, dcup, etc.)

### Tier 4: Full Deployment (`deploy-full`)
- **Everything from Tier 3**
- **Kubernetes tools**: kubectl, k3s (default) or KIND, kompose, helm with bash completions
- **k3s cluster** (default): Production-ready Kubernetes with NGINX Ingress Controller
- **KIND cluster** (optional): Development-focused Kubernetes in Docker
- **Comprehensive bashrc**: Kubernetes aliases, kubectl completions, custom functions
- **Development enhancements**: Advanced shell functions for container and cluster management
- **User CLAUDE.md configuration**: Environment-specific guidance on target VM

### Component Details

**Bashrc Integrations (Tiers 3 & 4):**
- Docker aliases: `dps`, `dpa`, `di`, `drm`, `dexec`, `dlogs`, `dcp`, `dcup`, `dcdown`
- Kubernetes aliases: `k`, `kgp`, `kgs`, `kgd`, `kdesc`, `klogs`, `kexec`, `kapply`
- Custom functions: `drun`, `kctx`, `kns`, `cdls`, `ff`
- Auto-completions for kubectl and Docker
- Development shortcuts and productivity enhancements

**Kubernetes Backend Options (Tier 4):**
- **k3s** (default): Lightweight, production-ready Kubernetes with built-in load balancer
- **KIND** (optional): Kubernetes in Docker, ideal for development and testing

### User CLAUDE.md Configuration (on Target VM)

The deployment can optionally create `~/.claude/CLAUDE.md` on the target VM containing:
- **Environment Overview**: What was actually deployed (k3s/KIND/Docker)
- **Command Execution Policy**: Remote command execution settings
- **Git Workflow**: Branch policy with required .gitignore patterns
- **Quick Reference**: Aliases, paths, and environment-specific commands

**Important**: Users on the target VM must log out/in or run `source ~/.bashrc` to update PATH and group memberships after deployment.