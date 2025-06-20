# Claude Code VM

**Automated deployment system for Claude Code development environments on Debian VMs**

Deploy a complete development environment with Claude Code CLI, Docker, Node.js, Git, and MCP servers in minutes.

## 🚀 Quick Start

```bash
# Clone and setup
git clone https://github.com/ksamaschke/claude-code-vm.git
cd claude-code-vm
make setup

# Configure Git credentials in .env
nano .env

# Deploy to your VM
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer
```

## ✨ What You Get

- **Claude Code CLI** - Ready to use with MCP server integration
- **Docker & Docker Compose** - Container development environment
- **Node.js 22 LTS** - Latest LTS with global package support
- **Git with Multi-Provider Support** - GitHub, GitLab, Azure DevOps, Bitbucket, custom servers
- **Kubernetes Tools** - kubectl, kind, kompose with bash completions
- **MCP Servers** - Search, memory, document processing, browser automation
- **Persistent Sessions** - Screen-based terminal sessions that survive disconnects

## 📋 Requirements

- **Target VM**: Debian 12+ with SSH access
- **Local**: Ansible installed
- **Credentials**: Git Personal Access Tokens for at least one provider

## 🎯 Use Cases

### Single Machine Deployment (Most Common)
```bash
make deploy VM_HOST=your.vm.ip TARGET_USER=username
```

### Multiple Machine Deployment
```bash
# Edit inventory.yml with your server groups
make deploy DEPLOY_TARGET=production
```

### Component-Specific Deployment
```bash
make deploy-git VM_HOST=your.ip TARGET_USER=user      # Git only
make deploy-mcp VM_HOST=your.ip TARGET_USER=user      # MCP servers only
make deploy-docker VM_HOST=your.ip TARGET_USER=user   # Docker only
```

## 🔧 Configuration

### Environment File (.env)
```bash
# Required: At least one Git provider
GIT_SERVER_GITHUB_URL="https://github.com"
GIT_SERVER_GITHUB_USERNAME="yourusername"
GIT_SERVER_GITHUB_PAT="your_token"

# Optional: MCP API keys for enhanced functionality
BRAVE_API_KEY="your_api_key"
```

### Authentication Options
```bash
# Default: SSH key authentication
make deploy VM_HOST=ip TARGET_USER=user

# Direct user connection (more secure)
make deploy VM_HOST=ip TARGET_USER=user CONNECT_AS_TARGET=true

# Custom SSH key
make deploy VM_HOST=ip TARGET_USER=user TARGET_SSH_KEY=~/.ssh/custom_key

# Password authentication
make deploy VM_HOST=ip TARGET_USER=user USE_SSH_PASSWORD=true SSH_PASSWORD=pass
```

## 📚 Documentation

- **[📖 Complete Documentation](docs/)** - Detailed guides and configuration
- **[⚡ Quick Start Guide](docs/quickstart.md)** - 5-minute deployment
- **[🔧 Installation Guide](docs/installation.md)** - Prerequisites and setup
- **[🔐 Authentication Guide](docs/authentication.md)** - SSH keys, passwords, security
- **[⚙️ Configuration Guide](docs/configuration.md)** - Environment variables and settings

## 🏗️ Project Structure

```
claude-code-vm/
├── ansible/           # Ansible playbooks and roles
├── config/           # Configuration templates (optional)
├── docs/             # Documentation
├── group_vars/       # Ansible group variables
├── scripts/          # Deployment scripts
├── inventory.yml     # Target host definitions
├── Makefile         # Deployment commands
└── README.md        # This file
```

## 🛠️ Available Commands

```bash
make help              # Show all commands
make setup             # First-time setup
make deploy            # Full deployment
make deploy-mcp        # MCP servers only
make validate          # Verify deployment
make check             # Test connectivity
```

## 🔍 Troubleshooting

**Connection Issues**:
```bash
make check VM_HOST=your.ip TARGET_USER=user
```

**SSH Problems**:
```bash
ssh -v user@your.ip  # Test manually
```

**See [Troubleshooting Guide](docs/troubleshooting.md) for more solutions**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Need help?** Check the [documentation](docs/) or [open an issue](../../issues).