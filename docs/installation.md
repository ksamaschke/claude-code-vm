# Installation Guide

Complete installation and setup guide for Claude Code VM deployment system.

## Prerequisites

### Local Machine (Control Node)
- **Ansible** 2.9+ installed
- **Git** for cloning the repository
- **Make** (usually pre-installed on Linux/macOS)
- **SSH client** with key-based authentication

### Target VM(s)
- **Debian 12+** (Bookworm) or compatible
- **SSH access** with sudo privileges
- **Internet connectivity** for package downloads
- **2GB+ RAM** recommended
- **10GB+ free disk space**

## Installation Methods

### Method 1: Quick Install (Recommended)

```bash
# Clone repository
git clone <repository-url>
cd claude-code-vm

# First-time setup
make setup

# Edit .env file with your credentials
nano .env

# Test connectivity
make check VM_HOST=your.vm.ip.address TARGET_USER=yourusername

# Deploy everything
make deploy VM_HOST=your.vm.ip.address TARGET_USER=yourusername
```

### Method 2: Manual Setup

```bash
# Clone repository
git clone <repository-url>
cd claude-code-vm

# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
nano inventory.yml  # If using group deployments

# Validate configuration
ansible-playbook --syntax-check ansible-debian-stack/playbooks/site.yml

# Deploy
ansible-playbook ansible-debian-stack/playbooks/site.yml -e "vm_host=IP target_vm_user=USER"
```

## Initial Configuration

### 1. Environment File (.env)

Configure at least one Git provider:

```bash
# Required: At least one Git server
GIT_SERVER_GITHUB_URL="https://github.com"
GIT_SERVER_GITHUB_USERNAME="yourusername"
GIT_SERVER_GITHUB_PAT="your_token"

# Optional: Additional Git providers
GIT_SERVER_GITLAB_URL="https://gitlab.com"
GIT_SERVER_GITLAB_USERNAME="yourusername"
GIT_SERVER_GITLAB_PAT="your_token"

# Optional: MCP API keys
BRAVE_API_KEY="your_brave_search_api_key"
TAVILY_API_KEY="your_tavily_api_key"
```

### 2. Target Configuration

Choose your deployment method:

**Single Machine (Default)**:
```bash
# No inventory changes needed
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer
```

**Multiple Machines**:
Edit `inventory.yml` to define your server groups:
```yaml
all:
  children:
    production:
      hosts:
        web-01:
          ansible_host: 10.0.1.10
          target_user: webapp
```

### 3. Authentication Setup

Choose your authentication method:

**SSH Key (Default)**:
```bash
# Ensure your SSH key is accessible
ssh-add ~/.ssh/id_rsa
make deploy VM_HOST=IP TARGET_USER=user
```

**Custom SSH Key**:
```bash
make deploy VM_HOST=IP TARGET_USER=user TARGET_SSH_KEY=~/.ssh/custom_key
```

**Direct User Connection**:
```bash
make deploy VM_HOST=IP TARGET_USER=user CONNECT_AS_TARGET=true
```

See [Authentication Guide](authentication.md) for more options.

## Verification

### Test Connectivity
```bash
# Basic connectivity test
make check VM_HOST=your.ip TARGET_USER=username

# Manual SSH test
ssh username@your.ip
```

### Validate Deployment
```bash
# Run validation playbook
make validate VM_HOST=your.ip TARGET_USER=username

# Manual verification on target VM
ssh username@your.ip
claude --version
docker --version
node --version
```

## Post-Installation

### 1. Update PATH
On the target VM, update your shell environment:
```bash
# Log out and back in, OR:
source ~/.bashrc
```

### 2. Configure Git
Git credentials are automatically configured, but verify:
```bash
git config --list
git clone https://github.com/yourusername/some-repo  # Should work without prompting
```

### 3. Test MCP Servers
If you configured MCP API keys:
```bash
claude  # Start Claude Code
# MCP servers should be automatically loaded
```

### 4. Persistent Sessions
Screen sessions are automatically configured:
```bash
ssh username@your.ip  # Automatically connects to persistent session
# OR manually:
~/scripts/connect-session.sh
```

## Troubleshooting

### Common Issues

**Ansible Connection Failed**:
```bash
# Test SSH manually
ssh -v username@your.ip

# Check SSH key
ssh-add -l
```

**Permission Denied**:
```bash
# Check sudo access
ssh username@your.ip 'sudo whoami'

# Use password authentication if needed
make deploy VM_HOST=IP TARGET_USER=user USE_SSH_PASSWORD=true SSH_PASSWORD=yourpassword
```

**Package Installation Failed**:
```bash
# Check internet connectivity on target
ssh username@your.ip 'ping -c 3 google.com'

# Update package lists
ssh username@your.ip 'sudo apt update'
```

See [Troubleshooting Guide](troubleshooting.md) for more solutions.

## Advanced Configuration

### Custom Deployment Paths
```bash
make deploy VM_HOST=IP TARGET_USER=user DEPLOYMENT_DIR=/custom/path/.claude-code-vm
```

### Selective Component Installation
```bash
# Install only specific components
make deploy-git VM_HOST=IP TARGET_USER=user
make deploy-docker VM_HOST=IP TARGET_USER=user
make deploy-mcp VM_HOST=IP TARGET_USER=user
```

### Environment-Specific Configuration
```bash
# Use different config files
make deploy VM_HOST=IP TARGET_USER=user ENV_FILE=/path/to/prod.env MCP_FILE=/path/to/prod-mcp.json
```

## Next Steps

- [Quick Start](quickstart.md) - Simple deployment
- [Configuration](configuration.md) - Detailed configuration options
- [Authentication](authentication.md) - Security and access options
- [Components](components-git.md) - Individual component configuration