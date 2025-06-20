# Quick Start

Deploy Claude Code to a Debian VM in 5 minutes.

## Prerequisites

- Target VM running Debian 12+ with SSH access
- Ansible installed on your local machine
- SSH key access to the target VM

## 1. Clone and Setup

```bash
git clone <this-repo>
cd claude-code-vm
make setup
```

## 2. Configure Environment

Edit the generated `.env` file with your Git credentials:

```bash
# Required Git server (at least one)
GIT_SERVER_GITHUB_URL="https://github.com"
GIT_SERVER_GITHUB_USERNAME="yourusername"
GIT_SERVER_GITHUB_PAT="your_personal_access_token"

# Optional: MCP API keys
BRAVE_API_KEY="your_brave_api_key"
```

## 3. Deploy

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer
```

## 4. Connect

SSH to your VM and enjoy your development environment:

```bash
ssh developer@192.168.1.100
# Automatically connects to persistent screen session
claude --version  # Claude Code CLI ready to use
```

## What You Get

- ✅ Claude Code CLI installed and configured
- ✅ Docker and Docker Compose
- ✅ Node.js 22 LTS with global packages
- ✅ Git with encrypted credential storage
- ✅ Kubernetes tools (kubectl, kind, kompose)
- ✅ MCP servers for enhanced Claude Code functionality
- ✅ Persistent screen sessions

## Next Steps

- [Configure additional Git providers](components-git.md)
- [Set up MCP servers](components-mcp.md)
- [Learn about authentication options](authentication.md)
- [Deploy to multiple machines](deployment-groups.md)

## Need Help?

- [Troubleshooting](troubleshooting.md) - Common issues
- [Configuration](configuration.md) - Detailed settings
- [Authentication](authentication.md) - SSH and credential options