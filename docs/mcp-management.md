# MCP Management Subsystem

This document covers the complete MCP (Model Context Protocol) management subsystem located in `tools/claude-code-mcp-management/`. This is a standalone tool for managing MCP servers across local and remote environments.

## Overview

The MCP management subsystem provides tools for installing, configuring, and managing MCP servers. It supports both user-level and project-level server management, with deployment capabilities to remote VMs.

**Location**: `/tools/claude-code-mcp-management/`

## Core Components

### Makefile Targets

The subsystem provides the following Make targets:

#### Local MCP Server Management
- `help` - Show comprehensive help and usage examples
- `list` - List all configured MCP servers
- `sync` - Sync all servers from configuration file
- `dry-run` - Check configuration without making changes
- `add` - Add specific servers (requires SERVERS=...)
- `add-all` - Add ALL servers from configuration file
- `remove` - Remove specific servers (requires SERVERS=...)
- `check` - Check dependencies only
- `clean` - Remove orphaned servers
- `show-config` - Display current configuration

#### Project-Specific Targets
- `project-list` - List servers in current project
- `project-sync` - Sync servers for current project
- `project-add` - Add servers to current project
- `project-add-all` - Add ALL servers to current project
- `project-remove` - Remove servers from current project
- `project-clean` - Clean orphaned servers in project
- `project-config` - Show configuration for project scope

#### VM Deployment Targets
- `deploy-vm` - Deploy to single VM (VM=user@host or HOST=ip)
- `deploy-group` - Deploy to VM group (requires GROUP=groupname)
- `deploy-all` - Deploy to all VMs in inventory
- `create-deploy-playbook` - Create/recreate Ansible deployment playbook

#### Setup and Dependencies
- `install-deps` - Install required dependencies (Ansible, etc.)
- `setup` - Check dependencies and run initial sync

### Configuration Variables

#### File Locations
- `CONFIG_FILE` - Path to mcp-servers.json (default: `mcp-servers.json`)
- `ENV_FILE` - Path to .env file (default: `.env`)
- `SCOPE` - Installation scope: user|project (default: `user`)
- `PROJECT` - Project path for project scope (default: `.`)

#### SSH and Deployment Configuration
- `SSH_USER` - SSH username (default: from .env or `ubuntu`)
- `SSH_KEY_FILE` - SSH private key path (default: from .env or `~/.ssh/id_rsa`)
- `SSH_PORT` - SSH port (default: from .env or `22`)
- `SSH_OPTIONS` - SSH options (default: from .env or `-o StrictHostKeyChecking=no`)
- `DEPLOY_DIR` - Target deployment directory (default: from .env or `/opt/mcp-manager`)
- `ANSIBLE_INVENTORY` - Ansible inventory file (default: `ansible/inventory/hosts.yml`)

#### Server Management Variables
- `SERVERS` - Comma-separated list of servers (for add/remove operations)
- `VM` - Target VM for deployment (user@hostname format)
- `HOST` - Target hostname/IP (uses SSH_USER from config)
- `GROUP` - VM group name from inventory

### Shell Scripts

The subsystem includes four shell scripts in the `scripts/` directory:

1. **`manage-mcp.sh`** - Main management script
2. **`mcp-add.sh`** - Add specific MCP servers
3. **`mcp-remove.sh`** - Remove specific MCP servers  
4. **`mcp-sync.sh`** - Sync all servers from configuration

### Ansible Integration

The subsystem includes Ansible playbooks for remote deployment:

- `ansible/manage-mcp.yml` - Main MCP management playbook
- `ansible/deploy.yml` - VM deployment playbook (generated)
- `ansible/inventory/hosts.yml` - Inventory configuration
- `ansible/roles/mcp-servers/` - MCP server management role

## Usage Examples

### Local Server Management

**List current servers:**
```bash
make list
```

**Sync all servers from configuration:**
```bash
make sync
```

**Add specific servers:**
```bash
make add SERVERS=memory,brave-search
```

**Add all servers from configuration:**
```bash
make add-all
```

**Remove servers:**
```bash
make remove SERVERS=github
```

**Check configuration without changes:**
```bash
make dry-run
```

### Project-Specific Management

**Sync servers for current project:**
```bash
make project-sync
```

**Add servers to specific project:**
```bash
make project-add SERVERS=memory PROJECT=/path/to/project
```

**Use project scope:**
```bash
make sync SCOPE=project PROJECT=/my/project
```

### Custom Configuration Files

**Use custom configuration files:**
```bash
make sync CONFIG_FILE=/path/to/config.json ENV_FILE=/path/to/.env
```

**Add all servers with custom config:**
```bash
make add-all CONFIG_FILE=~/mcp-servers.json
```

### Remote VM Deployment

**Deploy to single VM (direct SSH format):**
```bash
make deploy-vm VM=user@server1.example.com
```

**Deploy to VM using .env SSH configuration:**
```bash
make deploy-vm HOST=192.168.1.100
```

**Deploy with custom SSH settings:**
```bash
make deploy-vm HOST=server1 SSH_USER=admin SSH_KEY_FILE=~/.ssh/prod.pem
```

**Deploy to VM group:**
```bash
make deploy-group GROUP=production
```

**Deploy to all VMs:**
```bash
make deploy-all
```

### Setup and Dependencies

**Check dependencies:**
```bash
make check
```

**Install dependencies:**
```bash
make install-deps
```

**Complete setup (check dependencies and sync):**
```bash
make setup
```

**Show current configuration:**
```bash
make show-config
```

## Configuration Files

### MCP Servers Configuration

The `mcp-servers.json` file defines available MCP servers:

```json
{
  "memory": {
    "command": "npx",
    "args": ["@modelcontextprotocol/server-memory"]
  },
  "brave-search": {
    "command": "npx", 
    "args": ["@modelcontextprotocol/server-brave-search"],
    "env": {
      "BRAVE_API_KEY": "${BRAVE_API_KEY}"
    }
  }
}
```

### Environment Configuration

The `.env` file provides environment variables and SSH configuration:

```bash
# MCP Server API Keys
BRAVE_API_KEY=your_api_key
TAVILY_API_KEY=your_api_key

# SSH Configuration
SSH_USER=ubuntu
SSH_KEY_FILE=~/.ssh/id_rsa
SSH_PORT=22
SSH_OPTIONS=-o StrictHostKeyChecking=no
DEPLOY_DIR=/opt/mcp-manager

# Ansible Configuration
ANSIBLE_INVENTORY=ansible/inventory/hosts.yml
```

### Ansible Inventory

The `ansible/inventory/hosts.yml` file defines VM groups:

```yaml
all:
  children:
    production:
      hosts:
        server1:
          ansible_host: 192.168.1.100
        server2:
          ansible_host: 192.168.1.101
    development:
      hosts:
        dev1:
          ansible_host: 192.168.1.200
```

## Scope Management

### User Scope (Default)

Installs MCP servers at the user level (`~/.claude/mcp-servers.json`):

```bash
make sync                    # User scope
make add SERVERS=memory      # User scope
```

### Project Scope

Installs MCP servers for a specific project:

```bash
make project-sync                              # Current project
make sync SCOPE=project PROJECT=/my/project    # Specific project
```

## Error Handling and Validation

The subsystem includes comprehensive error handling:

- **Configuration validation** before making changes
- **Dependency checking** for required tools
- **Server validation** before installation
- **Dry-run mode** for safe configuration testing
- **Orphaned server cleanup** for maintenance

## Dependencies

Required dependencies for the MCP management subsystem:

- **Claude Code CLI** - For MCP server management
- **Ansible** - For remote VM deployment (optional)
- **rsync** - For file synchronization during deployment
- **SSH** - For remote access (deployment only)

## Integration with Main Deployment System

The MCP management subsystem integrates with the main deployment system through:

1. **Makefile targets** in the main system:
   - `make setup-mcp-tool` - Setup the MCP management tool
   - `make deploy-mcp` - Deploy MCP servers to VM
   - `make generate-mcp-config` - Generate MCP configuration

2. **Shared configuration** through `.env` files and MCP server templates

3. **Ansible role integration** for VM deployment

This MCP management subsystem provides comprehensive tooling for managing MCP servers across development workflows and deployment environments.