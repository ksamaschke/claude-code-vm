# Configuration Directory

This directory contains all default configuration templates and examples for the Claude Code VM deployment system.

## Files

### `env.example`
Template for the `.env` file containing:
- Git hosting service credentials (GitHub, GitLab, etc.)
- API keys for MCP servers (Brave Search, etc.)
- Git repository management settings

**Usage**: 
```bash
# Automatically created by make setup
make setup  # Creates config/.env from this template
```

### `git-repos.env.example`
Template for Git repository configuration containing:
- Repository URLs to clone
- Branch specifications
- Custom directory names
- Post-clone commands

**Usage**:
```bash
cp config/git-repos.env.example config/git-repos.env
# Edit with your repositories
make deploy-git-repos GIT_CONFIG_FILE=config/git-repos.env
```

### `mcp-servers.template.json`
Template for MCP (Model Context Protocol) server configuration:
- 11 pre-configured MCP servers
- Environment variable placeholders for API keys
- Server command specifications

**Usage**: Automatically used by the system when no `mcp-servers.json` exists.

### `CLAUDE.md.default`
Default CLAUDE.md file deployed to target VMs containing:
- Environment-specific instructions
- Available commands and aliases
- Deployment details

## Default Locations

The Makefile uses these defaults:
- `ENV_FILE`: `config/.env`
- `MCP_FILE`: `config/mcp-servers.json`
- `GIT_CONFIG_FILE`: Same as `ENV_FILE`

Override any default with command-line parameters:
```bash
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev \
  ENV_FILE=/path/to/custom/.env \
  MCP_FILE=/path/to/custom/mcp-servers.json
```

## Security Notes

- Never commit actual `.env` files or `mcp-servers.json` with real credentials
- The `.gitignore` file excludes these sensitive files
- Only commit the `.example` and `.template` files