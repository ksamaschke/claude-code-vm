# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Architecture

This repository contains an **Ansible-based deployment system** that automates the setup of a complete development environment on Debian VMs. The architecture follows Ansible best practices with a role-based structure for modular deployment of development tools.

### Core Components

- **Ansible Playbooks**: Main orchestration (`ansible-debian-stack/playbooks/site.yml`)
- **Role-based Architecture**: Modular components in `ansible-debian-stack/roles/`
  - `common`: System preparation and updates
  - `git`: Git with credential management for multiple hosting services  
  - `docker`: Docker CE with Docker Compose
  - `nodejs`: Node.js 22 LTS with npm global packages
  - `claude-code`: Claude Code CLI installation
  - `kubernetes`: kubectl, k3s (preselected), kind (optional), kompose with bash completions
- **Environment Configuration**: URL-based PAT system via `.env` file
- **MCP Server Support**: `mcp-servers.json` for Claude Code extensions

### URL-Based Git Credential System

The project implements a flexible credential management system supporting unlimited Git hosting services through environment variables:

Pattern: `GIT_SERVER_{UNIQUE_ID}_{FIELD}`
- `GIT_SERVER_GITHUB_URL="https://github.com"`
- `GIT_SERVER_GITHUB_USERNAME="username"`  
- `GIT_SERVER_GITHUB_PAT="token"`

Supports GitHub, GitLab, Azure DevOps, Bitbucket, Gitea, and any custom Git servers.

### MCP Server Integration

The project includes automated installation and configuration of **Model Context Protocol (MCP) servers** for Claude Code. MCP servers extend Claude Code's capabilities with specialized tools and integrations.

**Included MCP Servers:**
- **Sequential Thinking**: Enhanced reasoning capabilities
- **Memory**: Persistent memory across sessions
- **Brave Search**: Web search functionality (requires API key)
- **Context7**: Upstash Redis integration (requires Redis credentials)
- **Doc Forge**: Document processing and generation
- **Omnisearch**: Multi-provider search (supports Tavily, Kagi, Perplexity, Jina AI)
- **Puppeteer**: Browser automation via Docker

**API Key Management:** All MCP server API keys are externalized to the `.env` file following the same security patterns as Git credentials. The system automatically configures only the MCP servers for which API keys are provided.

## Essential Commands

### Primary Deployment Commands
```bash
# Full deployment workflow
make setup                    # First-time setup, creates .env from template
make check                    # Validate configuration and connectivity
make deploy                   # Deploy complete development stack
make validate                 # Verify all components after deployment

# Component-specific deployment
make deploy-git               # Git configuration and credential management only
make deploy-docker            # Docker and Docker Compose only
make deploy-nodejs            # Node.js and npm packages only
make deploy-claude            # Claude Code CLI only
make deploy-k8s               # Kubernetes tools (kubectl, kind, kompose) only
make deploy-mcp               # MCP servers for Claude Code
```

### Maintenance and Updates
```bash
make update-pats              # Update Git Personal Access Tokens from .env
make update-git               # Update complete Git configuration
make update-mcp               # Update MCP server configuration and API keys
make status                   # Show deployment status and configured Git servers
```

### Validation and Testing
```bash
make validate-git             # Validate Git configuration only
make validate-docker          # Validate Docker installation only
make validate-k8s             # Validate Kubernetes tools only
make validate-mcp             # Validate MCP server configuration
make dry-run                  # Show what would change without applying
make test-connection          # Test SSH connectivity to target VM
make test-git-config          # Show current Git configuration on target
```

### Debugging and Troubleshooting
```bash
make debug                    # Debug deployment issues with verbose output
make debug-git                # Debug Git configuration specifically
make info                     # Show system information and dependencies
make clean                    # Clean up temporary files and logs
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
1. Target VM running Debian 12+ (Bookworm)
2. SSH access with sudo privileges for target user
3. `.env` file configured with Git credentials (use `make setup` to create from template)
4. Ansible installed on control machine

### Critical Configuration Files
- `ansible-debian-stack/inventories/production/hosts.yml`: Target VM configuration
- `ansible-debian-stack/inventories/production/group_vars/all.yml`: Component versions and settings
- `ansible-debian-stack/.env`: Git credentials, PATs, and MCP API keys (create from `.env.example`)
- `mcp-servers.template.json`: Template for MCP server configuration

### Environment Variables Setup
Edit `.env` file with your Git hosting service credentials and MCP API keys following the URL-based pattern. The system automatically discovers and configures any Git servers defined in the environment file. MCP servers are configured based on available API keys - only servers with valid credentials are included in the final configuration.

## Development Workflow

1. **First-time setup**: `make setup` → edit `.env` → `make check`
2. **Deploy stack**: `make deploy` → `make validate`
3. **Update credentials**: Edit `.env` → `make update-pats` or `make update-mcp`
4. **Add new Git server**: Add 3 lines to `.env` → `make deploy-git`
5. **Add MCP server**: Add API key to `.env` → `make deploy-mcp`

The Makefile provides colored output, progress tracking, and comprehensive help via `make help` and `make examples`.

## Post-Deployment

After successful deployment, the target VM will have:
- Docker running without sudo for the target user
- Node.js 22 LTS with Claude Code CLI globally installed
- Git configured with encrypted credential storage for all defined hosting services
- Kubernetes development tools with bash completions
- MCP servers installed and configured for Claude Code with externalized API keys
- SSH keys generated for additional authentication options
- **User CLAUDE.md configuration** with environment-specific guidance

### User CLAUDE.md Configuration

The deployment optionally creates `~/.claude/CLAUDE.md` (preselected) containing:

- **Environment Overview**: Actual deployed components (k3s/KIND/Docker)
- **Command Execution Policy**: Optional remote command execution (preselected)
- **Git Workflow**: Branch policy with required .gitignore patterns
- **Build & Deployment**: Runtime-specific development workflows
- **Quick Reference**: Aliases, paths, and environment-specific commands

**Configuration Options:**
- `create_user_claude_config: true` - Generate user CLAUDE.md (preselected)
- `allow_command_execution: true` - Enable remote command execution (preselected)

**Command Execution Feature:**
When enabled, Claude Code can automatically execute common commands:
- Kubernetes: `kubectl get pods`, `kubectl logs`, `kubectl port-forward`
- Docker: `docker ps`, `docker logs`, `docker compose up`
- System: `ls`, `cat`, `ps`, `git status`, `npm list`
- Development: All configured aliases and shortcuts

Users must log out/in or run `source ~/.bashrc` to update PATH and group memberships after deployment. MCP servers will be automatically available in Claude Code after restart.