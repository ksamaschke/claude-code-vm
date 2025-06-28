# CLAUDE Configuration Deployment Guide

This guide covers the `deploy-claude-config` Make target and localhost deployment support.

## Overview

The `deploy-claude-config` target allows you to deploy both CLAUDE.md and settings.json configuration files to target VMs without running a full deployment. This is useful for:

- Updating Claude Code context on existing deployments
- Testing different CLAUDE.md templates
- Configuring Claude Code permissions with settings.json
- Quick configuration changes without infrastructure modifications
- Local testing before remote deployment

## Usage

### Basic Deployment

Deploy CLAUDE.md and settings.json with auto-detection based on installed components:

```bash
make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=developer
```

### Specific Template Deployment

Deploy a specific CLAUDE.md template:

```bash
make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=developer \
  CLAUDE_CONFIG_TEMPLATE=config/CLAUDE.full.md
```

Available templates:
- `config/CLAUDE.common.md` - Base template (included by all others)
- `config/CLAUDE.minimal.md` - For baseline deployments
- `config/CLAUDE.enhanced.md` - For enhanced deployments with MCP/Docker
- `config/CLAUDE.containerized.md` - For containerized deployments
- `config/CLAUDE.full.md` - For full deployments with Kubernetes

### Force Override

Override existing CLAUDE.md and/or settings.json files:

```bash
# Override CLAUDE.md only
make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=developer \
  CLAUDE_CONFIG_FORCE_OVERRIDE=true

# Override settings.json only
make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=developer \
  CLAUDE_SETTINGS_FORCE_OVERRIDE=true

# Override both files
make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=developer \
  CLAUDE_CONFIG_FORCE_OVERRIDE=true \
  CLAUDE_SETTINGS_FORCE_OVERRIDE=true
```

### Localhost Deployment

Deploy to your local machine without SSH:

```bash
make deploy-claude-config VM_HOST=localhost TARGET_USER=$USER
```

## Localhost Deployment Support

The system automatically detects localhost deployments when `VM_HOST` is set to:
- `localhost`
- `127.0.0.1`

### Features for Localhost

- **No SSH Required**: Uses Ansible local connection
- **No Sudo Required**: Runs with current user permissions
- **Instant Testing**: Test configurations locally before remote deployment
- **Same Interface**: Uses the same Make commands as remote deployments

### Example Workflow

1. Test locally first:
   ```bash
   make deploy-claude-config VM_HOST=localhost TARGET_USER=$USER \
     CLAUDE_CONFIG_TEMPLATE=config/CLAUDE.minimal.md
   ```

2. Verify the deployment:
   ```bash
   cat ~/.claude/CLAUDE.md
   ```

3. Deploy to remote VM:
   ```bash
   make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=developer \
     CLAUDE_CONFIG_TEMPLATE=config/CLAUDE.minimal.md
   ```

## Parameters

### CLAUDE.md Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `VM_HOST` | Target host (IP or hostname) | Required |
| `TARGET_USER` | User on target system | Required |
| `CLAUDE_CONFIG_TEMPLATE` | Path to CLAUDE.md template file | Auto-detected |
| `CLAUDE_CONFIG_FORCE_OVERRIDE` | Force override existing CLAUDE.md | false |

### settings.json Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `CLAUDE_SETTINGS_TEMPLATE` | Path to settings.json template | config/claude-settings.template.json |
| `CLAUDE_SETTINGS_FORCE_OVERRIDE` | Force override existing settings.json | false |

## How It Works

1. **Configuration Check**: Validates required parameters
2. **Connection Test**: 
   - For remote hosts: Tests SSH connectivity
   - For localhost: Skips SSH checks
3. **Template Resolution**:
   - CLAUDE.md: If template specified, uses it; otherwise auto-detects based on deployment tier
   - settings.json: Uses specified template or default config/claude-settings.template.json
4. **Deployment**:
   - Creates `~/.claude/` directory if needed
   - For CLAUDE.md: Processes template includes and deploys
   - For settings.json: Copies template directly
   - Creates backups if overriding existing files

## Template Auto-Detection

When no template is specified, the system detects the deployment tier:

1. Checks for Kubernetes tools → Uses `CLAUDE.full.md`
2. Checks for Docker Compose → Uses `CLAUDE.containerized.md`
3. Checks for Docker/MCP → Uses `CLAUDE.enhanced.md`
4. Otherwise → Uses `CLAUDE.minimal.md`

## Claude Settings Security Rules

The default `config/claude-settings.template.json` includes comprehensive allow/deny rules:

### Allowed Operations
- **File operations**: Read, Edit, Write, Glob, Grep, LS, find
- **Development tools**: Make, npm, node, python, git (including branch/merge), docker, kubectl
- **Safe shell commands**: ls, cat, grep, find, curl, wget (with restrictions)
- **Project cleanup**: rm -rf within current directory (./* and ./*/*)
- **SSH/SCP**: Operations to localhost, 10.0.0.*, 192.168.1.*, 192.168.0.*
- **AI tools**: sequential-thinking, context7, web search/fetch
- **Container operations**: Docker commands, docker-compose, kubernetes

### Denied Operations
- **Destructive commands**: rm -rf /, disk formatting, fork bombs
- **Security risks**: Reverse shells, privilege escalation, credential exposure
- **System modifications**: User management, firewall disabling, kernel changes
- **Dangerous git operations**: Force push to main/master (basic push not included)
- **System operations**: Log deletion, crypto mining

### Notable Exclusions
- **git push**: Not included in allow rules (neither allowed nor denied - requires explicit permission)

*Template inspired by [claude-settings](https://github.com/dwillitzer/claude-settings) project*

## Troubleshooting

### Template Not Found

```
❌ Template file not found: config/CLAUDE.custom.md
💡 Available templates in config/:
  config/CLAUDE.common.md
  config/CLAUDE.enhanced.md
  config/CLAUDE.full.md
  config/CLAUDE.minimal.md
```

**Solution**: Check template path and spelling.

### File Already Exists

```
Status: Skipped - file exists (use claude_config_force_override=true to override)
```

**Solution**: Add `CLAUDE_CONFIG_FORCE_OVERRIDE=true` to override.

### Localhost on Non-Debian Systems

Full stack deployments to localhost may fail on non-Debian systems (e.g., macOS) due to:
- Different package managers
- System-specific paths
- Sudo requirements

**Solution**: Use `deploy-claude-config` for configuration-only deployments on non-Debian localhost.

## Best Practices

1. **Test Locally First**: Use localhost deployment to verify templates
2. **Use Version Control**: Keep custom templates in version control
3. **Document Changes**: Update templates with clear comments
4. **Backup Important Configs**: System creates automatic backups when overriding

## See Also

- [CLAUDE Configuration Guide](claude-config.md) - Template creation and customization
- [Make Targets Reference](make-targets.md) - Complete list of available targets
- [Deployment Tiers](../README.md#-4-tier-deployment-architecture) - Understanding deployment levels