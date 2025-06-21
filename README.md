# Claude Code VM

**Automated deployment system for Claude Code development environments on Debian VMs**

Deploy a complete AI-enabled development environment with Claude Code CLI, Docker, Node.js, Git, and MCP servers in minutes.

## 🚀 Quick Start

```bash
# Clone and setup
git clone https://github.com/ksamaschke/claude-code-vm.git
cd claude-code-vm
make setup

# OPTIONAL: Configure automated Git setup
nano .env  # Add your Git credentials for automated setup

# Deploy to your VM
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer
```

## ✨ What You Get

- **🤖 Claude Code CLI** - Ready to use with MCP server integration and subagent support
- **🐳 Docker & Docker Compose** - Complete container development environment
- **📦 Node.js 22 LTS** - Latest LTS with global package support and PATH configuration
- **🔐 Git Multi-Provider Support** - GitHub, GitLab, Azure DevOps, Bitbucket, unlimited custom servers
- **☸️ Kubernetes Stack** - k3s (lightweight) with NGINX Ingress Controller, kubectl, kompose
- **🧠 MCP Servers** - AI extensions: search, memory, document processing, browser automation
- **📺 Persistent Sessions** - Screen-based terminal sessions that survive disconnects

## 📋 Requirements

- **Target VM**: Debian 12+ with SSH access and sudo privileges
- **Local Machine**: Ansible installed
- **Optional**: Git Personal Access Tokens for automated Git credential setup

## 🛠️ Essential Commands

```bash
make help              # Show comprehensive help and usage examples
make setup             # Initialize environment files (.env, mcp-servers.json)
make deploy            # Deploy complete development stack
make validate          # Verify all deployed components are working
make deploy-mcp        # Deploy MCP servers only (after initial deployment)
make clean             # Clean up temporary files
```

**Required for all deployments:**
- `VM_HOST` - Target VM IP address 
- `TARGET_USER` - Username on the target VM

## 🎯 Common Usage Patterns

### Complete First-Time Setup
```bash
make setup                                          # Initialize project
nano .env                                          # Add Git credentials (optional)
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev  # Deploy everything
make validate VM_HOST=192.168.1.100 TARGET_USER=dev # Verify deployment
```

### Deploy Individual Components
```bash
# Use Ansible directly with tags for component-specific deployment
ansible-playbook ansible/playbooks/site.yml --tags git
ansible-playbook ansible/playbooks/site.yml --tags docker,nodejs
ansible-playbook ansible/playbooks/site.yml --tags kubernetes,mcp

# Available tags: common, git, docker, nodejs, claude-code, kubernetes, mcp
```

### MCP Server Management
```bash
make setup-mcp-tool                                 # Setup local MCP management
make generate-mcp-config                           # Generate MCP configuration
make deploy-mcp VM_HOST=192.168.1.100 TARGET_USER=dev # Deploy MCP servers
```

## 🔧 Authentication Options

```bash
# Use specific SSH key
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev TARGET_SSH_KEY=~/.ssh/custom_key

# Use password authentication
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev USE_SSH_PASSWORD=true SSH_PASSWORD=mypass

# Custom environment files
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev ENV_FILE=production.env
```

## 🌟 Key Features

### AI-Enhanced Development
- **Claude Code CLI** with MCP server ecosystem for enhanced AI capabilities
- **Subagent support** for parallel task execution and complex workflows
- **Automated CLAUDE.md generation** with environment-specific guidance

### Container & Orchestration
- **k3s** as default lightweight Kubernetes runtime
- **NGINX Ingress Controller** for production-ready ingress
- **Docker** for development workflows and container building
- **Seamless integration** between Docker and k3s

### Git Multi-Provider Support
- **Unlimited Git servers** with URL-based credential management
- **Automatic credential setup** for GitHub, GitLab, Azure DevOps, Bitbucket
- **SSH key generation** and Git configuration

### Production-Ready Setup
- **Package manager conflict handling** for reliable deployments
- **Comprehensive validation** with clear status reporting
- **Screen session management** for persistent development environments
- **User configuration templates** with deployment-specific guidance

## 🔍 Quick Troubleshooting

```bash
# Test connectivity
make test-connection VM_HOST=192.168.1.100 TARGET_USER=dev

# Check configuration
make check-config

# Manual SSH test
ssh dev@192.168.1.100
```

## 📚 Documentation

For detailed configuration, troubleshooting, and advanced usage:

- **[Ansible Configuration Reference](docs/ansible-configuration.md)** - Complete variable and role documentation
- **[MCP Server Setup](docs/components-mcp.md)** - AI extensions and API key configuration
- **[Troubleshooting Guide](docs/troubleshooting.md)** - Common issues and solutions
- **[Authentication Guide](docs/authentication.md)** - SSH keys, passwords, security setup

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Need help?** Check the [documentation](docs/) or [open an issue](../../issues).