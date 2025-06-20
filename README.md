# Claude Code VM

**Automated deployment system for Claude Code development environments on Debian VMs**

Deploy a complete development environment with Claude Code CLI, Docker, Node.js, Git, and MCP servers in minutes.

## 🚀 Quick Start

```bash
# Clone and setup
git clone https://github.com/ksamaschke/claude-code-vm.git
cd claude-code-vm
make setup

# OPTIONAL: Configure automated Git setup
nano .env  # Skip this if you prefer manual Git setup

# Deploy to your VM
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer
```

## ✨ What You Get

- **Claude Code CLI** - Ready to use with MCP server integration
- **Docker & Docker Compose** - Container development environment
- **Node.js 22 LTS** - Latest LTS with global package support
- **Git with Multi-Provider Support** - GitHub, GitLab, Azure DevOps, Bitbucket, custom servers
- **Kubernetes Tools** - kubectl, k3s (lightweight), kompose with bash completions
- **MCP Servers** - Search, memory, document processing, browser automation
- **Persistent Sessions** - Screen-based terminal sessions that survive disconnects

## 📋 Requirements

- **Target VM**: Debian 12+ with SSH access
- **Local**: Ansible installed
- **Optional**: Git Personal Access Tokens for automated Git setup

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

### Environment File (.env) - OPTIONAL

**⚠️ IMPORTANT**: The .env file is **optional** but provides powerful automation:

```bash
# OPTIONAL: Automated Git credential setup
# These credentials will be securely stored on the target VM

# Well-known providers (URL is automatic)
GITHUB_USERNAME="yourusername"
GITHUB_PAT="your_token"  # Your Personal Access Token

# Custom Git servers (unlimited)
# GIT_COMPANY_URL="https://gitlab.company.com"
# GIT_COMPANY_USERNAME="yourusername"
# GIT_COMPANY_PAT="your_token"

# OPTIONAL: MCP API keys for enhanced AI functionality
BRAVE_API_KEY="your_api_key"  # For web search capabilities
```

**What this does**:
- **Git credentials**: Automatically configures encrypted Git authentication on the target VM
- **MCP API keys**: Enables advanced AI features like web search, memory, document processing
- **Your tokens are stored securely** on the VM using Git Credential Manager encryption

**Without .env file**: System works fine, but you'll need to configure Git authentication manually on each VM.

### MCP Servers (Model Context Protocol)

MCP servers extend Claude Code with powerful capabilities:
- **🔍 Web Search** - Real-time web search via Brave, Tavily, or other providers
- **🧠 Memory** - Persistent memory across sessions
- **📄 Document Processing** - PDF, Word, Excel file handling
- **🌐 Browser Automation** - Puppeteer for web interaction
- **🔗 Integrations** - Connect to databases, APIs, and external services

See [MCP Documentation](docs/components-mcp.md) for detailed configuration.

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
- **[🔗 Git Configuration Guide](docs/git-configuration.md)** - Multiple Git providers, enterprise setups
- **[🔌 MCP Servers Guide](docs/components-mcp.md)** - Model Context Protocol server setup

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

## 🛠️ Make Targets Reference

### Essential Commands

**First-time setup and deployment:**
```bash
make help              # Show comprehensive help and usage examples
make setup             # Initialize environment files (.env, mcp-servers.json)
make deploy            # Deploy complete development stack
make validate          # Verify all deployed components are working
```

**Connectivity and configuration:**
```bash
make check-config      # Validate configuration files and requirements
make test-connection   # Test network connectivity and SSH authentication
make clean             # Clean up temporary files and generated inventories
```

### MCP (Model Context Protocol) Management

**MCP server deployment and configuration:**
```bash
make deploy-mcp        # Deploy MCP servers only (requires Claude Code)
make setup-mcp-tool    # Setup local MCP management tool
make generate-mcp-config # Generate MCP configuration from environment
```

### Common Usage Patterns

**Complete first-time deployment:**
```bash
# 1. Initialize project
make setup

# 2. Edit .env file with your Git credentials and MCP API keys
nano .env

# 3. Deploy complete stack
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer

# 4. Validate deployment
make validate VM_HOST=192.168.1.100 TARGET_USER=developer
```

**MCP-only deployment (after initial setup):**
```bash
# Update MCP configuration and deploy
make generate-mcp-config
make deploy-mcp VM_HOST=192.168.1.100 TARGET_USER=developer
```

**Troubleshooting connectivity:**
```bash
# Test all connection aspects
make test-connection VM_HOST=192.168.1.100 TARGET_USER=developer

# Check configuration
make check-config
```

### Required Variables

**All deployment commands require these variables:**
- `VM_HOST` - Target VM IP address (REQUIRED)
- `TARGET_USER` - Target user on VM (REQUIRED)

**Example:**
```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer
```

### Optional Variables

**Authentication options:**
```bash
# Use specific SSH key
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev TARGET_SSH_KEY=~/.ssh/custom_key

# Use password authentication
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev USE_SSH_PASSWORD=true SSH_PASSWORD=mypass

# Specify sudo password
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev USE_BECOME_PASSWORD=true BECOME_PASSWORD=sudopass
```

**Custom configuration files:**
```bash
# Use custom environment file
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev ENV_FILE=production.env

# Use custom MCP configuration
make deploy-mcp VM_HOST=192.168.1.100 TARGET_USER=dev MCP_FILE=custom-mcp.json
```

**Deployment customization:**
```bash
# Custom deployment directory
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev DEPLOYMENT_DIR=/opt/claude-code-vm

# Custom session name
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev SESSION_NAME=PRODUCTION
```

### Component-Specific Deployments

**For deploying individual components, use Ansible directly with tags:**
```bash
# Deploy only Git configuration
ansible-playbook ansible/playbooks/site.yml --tags git

# Deploy Docker and Node.js
ansible-playbook ansible/playbooks/site.yml --tags docker,nodejs

# Deploy Kubernetes tools and MCP servers
ansible-playbook ansible/playbooks/site.yml --tags kubernetes,mcp

# Available tags: common, git, docker, nodejs, claude-code, kubernetes, mcp
```

### Advanced Usage

**Dry run and testing:**
```bash
# Check what would change without applying
ansible-playbook ansible/playbooks/site.yml --check --diff

# Syntax check
ansible-playbook --syntax-check ansible/playbooks/site.yml
```

**Custom inventory:**
```bash
# Use custom inventory file
ansible-playbook ansible/playbooks/site.yml -i custom-inventory.yml
```

### Troubleshooting Make Targets

**Common issues and solutions:**

1. **Connection failures:**
   ```bash
   # Test connectivity step by step
   make test-connection VM_HOST=192.168.1.100 TARGET_USER=developer
   ```

2. **Configuration errors:**
   ```bash
   # Validate all configuration files
   make check-config
   ```

3. **SSH authentication problems:**
   ```bash
   # Check SSH key permissions
   chmod 600 ~/.ssh/id_rsa
   
   # Test manual SSH connection
   ssh developer@192.168.1.100
   ```

4. **Deployment timeouts:**
   - Default timeout is 30 minutes for full deployment
   - Check VM resources (CPU, memory, disk space)
   - Verify network stability

5. **MCP deployment issues:**
   ```bash
   # Ensure full stack is deployed first
   make deploy VM_HOST=192.168.1.100 TARGET_USER=developer
   
   # Then deploy MCP servers
   make deploy-mcp VM_HOST=192.168.1.100 TARGET_USER=developer
   ```

**Environment file troubleshooting:**
- `.env` file is optional but recommended for automation
- If missing, Git credentials must be configured manually on target VM
- MCP servers require API keys in `.env` file to function

**Cleanup and reset:**
```bash
# Clean temporary files
make clean

# Reset environment (removes .env and mcp-servers.json)
rm .env mcp-servers.json
make setup
```

### Internal Targets

**These targets are automatically called by main commands but can be used independently:**

```bash
make create-dynamic-inventory # Generate Ansible inventory for single machine
```

This target creates a temporary inventory file at `.tmp/claude-code-vm/{VM_HOST}/inventory.yml` with the appropriate connection settings for your deployment. It's automatically called by `deploy`, `validate`, and `deploy-mcp` targets.

### Make vs Ansible Usage

**When to use Make:**
- Quick deployment and validation
- Standardized workflows with error handling
- Automatic inventory generation for single machines
- Built-in connectivity testing and configuration validation

**When to use Ansible directly:**
- Component-specific deployments with tags
- Custom inventory files for multiple machines
- Advanced Ansible features (vault, callbacks, etc.)
- Fine-grained control over deployment process

**Examples:**
```bash
# Make: Full deployment with built-in checks
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer

# Ansible: Component-specific deployment
ansible-playbook ansible/playbooks/site.yml --tags git,docker

# Ansible: Custom inventory
ansible-playbook ansible/playbooks/site.yml -i production-inventory.yml
```

## 🔍 Additional Troubleshooting

**For detailed troubleshooting beyond Make targets:**
- **[MCP Configuration](docs/components-mcp.md)** - Set up AI extensions
- **[Troubleshooting Guide](docs/troubleshooting.md)** - Common issues and solutions
- **[Authentication Guide](docs/authentication.md)** - SSH keys, passwords, security

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Need help?** Check the [documentation](docs/) or [open an issue](../../issues).