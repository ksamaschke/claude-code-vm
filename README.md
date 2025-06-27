# Claude Code VM

**Automated 4-tier deployment system for Claude Code development environments on Debian VMs**

Deploy a complete AI-enabled development environment with Claude Code CLI, Docker, Node.js, Git, Kubernetes, and MCP servers using a flexible 4-tier architecture that scales from minimal to full-featured.

## 🚀 Quick Start

```bash
# Clone and setup
git clone https://github.com/ksamaschke/claude-code-vm.git
cd claude-code-vm
make setup

# Configure your environment (optional but recommended)
nano .env  # Add Git credentials and MCP API keys

# Choose your deployment tier
make deploy-baseline VM_HOST=192.168.1.100 TARGET_USER=developer      # Minimal
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=developer       # + MCPs + Docker
make deploy-containerized VM_HOST=192.168.1.100 TARGET_USER=developer  # + Docker Compose + shell
make deploy-full VM_HOST=192.168.1.100 TARGET_USER=developer           # + Kubernetes + everything
```

## 🏗️ 4-Tier Deployment Architecture

### Tier 1: Baseline (`deploy-baseline`)
**Minimal core development environment**
- ✅ **Git** with multi-provider credential management (GitHub, GitLab, Azure DevOps, custom)
- ✅ **Node.js 22 LTS** with npm global configuration and PATH setup
- ✅ **Claude Code CLI** installed globally and ready to use
- ✅ **uvx** for isolated Python package execution
- ✅ **Git repository management** (optional) - automatic cloning with branch selection

### Tier 2: Enhanced (`deploy-enhanced`)
**Baseline + AI capabilities + containerization**
- ✅ **Everything from Tier 1**
- ✅ **MCP servers** from template configuration:
  - 🧠 **No API keys needed**: memory, sequential-thinking, puppeteer, doc-forge (4 servers)
  - 🔍 **Require API keys**: brave-search, context7, omnisearch (3 additional servers)
- ✅ **Docker** with user group integration (passwordless container management)
- ✅ **Docker group setup** (needed for puppeteer-docker and other containerized MCPs)

### Tier 3: Containerized (`deploy-containerized`)
**Enhanced + orchestration + productivity**
- ✅ **Everything from Tier 2**
- ✅ **Docker Compose** with latest version auto-resolution
- ✅ **Enhanced bashrc** with Docker aliases and shortcuts
- ✅ **Shell integrations**: `dps`, `dcp`, `dcup`, `dcdown`, `dexec`, `dlogs` aliases
- ✅ **Productivity enhancements** for container development

### Tier 4: Full (`deploy-full`)
**Everything + Kubernetes + comprehensive tooling**
- ✅ **Everything from Tier 3**
- ✅ **Kubernetes tools**: kubectl, helm, kompose with bash completions
- ✅ **k3s cluster** (default) or **KIND** (alternative) - choose your Kubernetes backend
- ✅ **NGINX Ingress Controller** for production-ready ingress
- ✅ **Comprehensive bashrc**: Kubernetes aliases (`k`, `kgp`, `kgs`, `kdesc`, etc.)
- ✅ **Advanced functions**: `kctx`, `kns`, `drun`, `cdls`, `ff`
- ✅ **User CLAUDE.md** with environment-specific guidance

## 📋 Prerequisites

- **Local machine**: Ansible 2.9+ installed
- **Target VM**: Debian 12+ (Bookworm) with SSH access
- **Network**: SSH port 22 open between local and target
- **Permissions**: Target user with sudo access
- **Optional**: Git PATs for repository access, API keys for MCP servers

## 📁 Project Structure & Configuration

### Default Configuration Directory: `config/`
The project uses the `config/` directory for default configuration files:

```
config/
├── env.example                # Template for .env file with Git credentials and API keys
├── git-repos.env.example      # Template for Git repository configuration
├── mcp-servers.template.json  # Template for MCP server configuration
├── CLAUDE.common.md           # Common base configuration (shared by all)
├── CLAUDE.minimal.md          # Minimal deployment configuration
├── CLAUDE.enhanced.md         # Enhanced deployment with MCP/Docker
├── CLAUDE.containerized.md    # Containerized with Docker Compose
└── CLAUDE.full.md            # Full deployment with Kubernetes
```

### Configuration Files
1. **Environment File** (`.env`)
   - Default location: `config/.env` (create from `config/env.example`)
   - Override with: `ENV_FILE=/path/to/your/.env`
   - Contains: Git credentials, API keys for MCP servers

2. **MCP Configuration** (`mcp-servers.json`)
   - Default location: `config/mcp-servers.json`
   - Override with: `MCP_FILE=/path/to/your/mcp-servers.json`
   - Contains: MCP server definitions and settings
   - **Auto-generated**: If no config exists, system copies `config/mcp-servers.template.json` as default

3. **Git Repository Configuration** 
   - Default: Same as ENV_FILE
   - Override with: `GIT_CONFIG_FILE=/path/to/your/git-repos.conf`
   - Contains: Repository URLs, branches, and management settings

### First-Time Setup
```bash
# 1. Clone the repository
git clone https://github.com/yourusername/claude-code-vm.git
cd claude-code-vm

# 2. Run setup to create default configuration
make setup  # Creates config/.env from template

# 3. Edit configuration files
nano config/.env  # Add your Git PATs and API keys

# 4. Deploy
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=developer
```

## ⚙️ Configuration Options

### Kubernetes Backend Selection
```bash
# Use k3s (default - production-ready, lightweight)
make deploy-full VM_HOST=192.168.1.100 TARGET_USER=dev KUBERNETES_BACKEND=k3s

# Use KIND (development-focused, runs in Docker)
make deploy-full VM_HOST=192.168.1.100 TARGET_USER=dev KUBERNETES_BACKEND=kind
```

### Git Repository Management
```bash
# Deploy only Git repositories (after initial deployment)
make deploy-git-repos VM_HOST=192.168.1.100 TARGET_USER=dev

# Enable automatic repository cloning during deployment
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev MANAGE_GIT_REPOSITORIES=true

# Use separate Git configuration file
make deploy-git-repos VM_HOST=192.168.1.100 TARGET_USER=dev GIT_CONFIG_FILE=.git-repos.env

# Supports multiple Git URL formats in config files:
# GITHUB_URL=https://github.com/user/repo.git  (simple format)
# GIT_REPO_URL=https://github.com/user/repo.git (single repo)
# GIT_REPO_1_URL=... (multiple repos)
```

### Environment Files
```bash
# Use custom environment file
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev ENV_FILE=production.env

# Use custom MCP configuration
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev MCP_FILE=custom-mcp.json
```

## 🛠️ Essential Commands

```bash
# Setup and validation
make help                    # Show comprehensive help with all deployment options
make setup                   # Initialize environment files (.env, mcp-servers.json)
make check-config            # Validate configuration before deployment
make test-connection         # Test SSH connectivity to target VM
make validate               # Verify all deployed components are working
make clean                  # Clean up temporary files and logs

# 4-tier deployments
make deploy-baseline        # Tier 1: Git + Node.js + Claude Code + uvx
make deploy-enhanced        # Tier 2: Baseline + MCPs + Docker
make deploy-containerized   # Tier 3: Enhanced + Docker Compose + bashrc
make deploy-full           # Tier 4: Everything + Kubernetes + comprehensive tooling

# Legacy aliases (backward compatibility)
make deploy-base           # Alias for deploy-enhanced
make deploy                # Alias for deploy-full

# MCP management
make deploy-mcp           # Deploy/update MCP servers on target VM
make list-remote SSH_HOST=<ip> SSH_USER=<user>  # List MCP servers on remote VM

# Git repository management
make deploy-git-repos     # Clone and manage Git repositories on target VM
```

### 4. Claude Configuration (CLAUDE.md)

The system automatically deploys a `CLAUDE.md` file to `~/.claude/CLAUDE.md` on target VMs, providing Claude Code with context about the deployment environment.

**Features:**
- **Auto-detection**: Automatically selects the right configuration based on deployment tier
- **Modular templates**: Uses inheritance (common → minimal → enhanced → containerized → full)
- **Override support**: Use custom templates with `claude_config_template` parameter
- **Include processing**: Templates can include other templates for modularity

**Usage:**
```bash
# Auto-detection (default)
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev
# Deploys config/CLAUDE.enhanced.md automatically

# Custom template
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev \
  EXTRA_VARS="claude_config_template=config/CLAUDE.custom.md"

# Force override existing
make deploy VM_HOST=192.168.1.100 TARGET_USER=dev \
  EXTRA_VARS="claude_config_force_override=true"
```

See [docs/claude-config.md](docs/claude-config.md) for detailed documentation.

## 💡 Smart Features

### 🤖 AI-Enhanced Development
- **Claude Code CLI** with configurable MCP servers for enhanced AI capabilities
- **MCP servers** from `config/mcp-servers.template.json`:
  - No API keys needed: memory, sequential-thinking, puppeteer, doc-forge (4 servers)
  - Require API keys: brave-search, context7, omnisearch (3 servers)
  - Fully customizable through template or custom configuration files
  - GitHub/GitLab repository integration with PAT support
  - Sequential thinking for complex problem solving
  - Browser automation with Puppeteer (both local and Docker)
- **Environment-aware CLAUDE.md** generation on target VM with deployment-specific guidance
- **uvx integration** for running AI tools and Python packages in isolation

### 🐳 Container & Orchestration Intelligence
- **Dynamic Docker Compose version resolution** - always gets the latest stable version
- **Smart Kubernetes backend selection** - k3s for production, KIND for development
- **Automatic ingress configuration** - NGINX Ingress with k3s, built-in with KIND
- **User group management** - passwordless Docker and proper permissions

### 📁 Git Multi-Provider Excellence
- **Universal Git credential management** - GitHub, GitLab, Azure DevOps, Bitbucket, custom servers
- **Pattern-based configuration**: `GIT_{NAME}_{FIELD}` for unlimited Git server support
- **Automated repository management** with branch selection and post-clone commands
- **SSH key generation** and global Git configuration

### 🚀 Shell Productivity Enhancements
- **Docker aliases**: `dps`, `dpa`, `di`, `drm`, `dexec`, `dlogs`, `dcp`, `dcup`, `dcdown`, `dcps`, `dclogs`
- **Kubernetes aliases**: `k`, `kgp`, `kgs`, `kgd`, `kdesc`, `klogs`, `kexec`, `kapply`, `kdelete`
- **Custom functions**: 
  - `drun <image>` - Quick container execution
  - `kctx [context]` - Kubernetes context switching
  - `kns [namespace]` - Namespace switching
  - `cdls <dir>` - Change directory and list
  - `ff <pattern>` - Fast file find
- **Auto-completions** for kubectl, Docker, and all major tools

## 🎯 Use Cases & Examples

### Development Team Setup
```bash
# Containerized development environment with Git automation
make deploy-containerized VM_HOST=192.168.1.100 TARGET_USER=developer \
  MANAGE_GIT_REPOSITORIES=true GIT_CONFIG_FILE=team-repos.env
```

### AI/ML Development
```bash
# Full environment with uvx for Python tools and Kubernetes for ML workloads
make deploy-full VM_HOST=192.168.1.100 TARGET_USER=datascientist \
  KUBERNETES_BACKEND=k3s
```

### Microservices Development
```bash
# KIND for local Kubernetes development with Docker Compose fallback
make deploy-full VM_HOST=192.168.1.100 TARGET_USER=developer \
  KUBERNETES_BACKEND=kind
```

### Minimal CI/CD Agent
```bash
# Baseline environment for lightweight build agents
make deploy-baseline VM_HOST=192.168.1.100 TARGET_USER=ci-agent
```

## 🔧 Advanced Configuration

### Using External Configuration Files
```bash
# Use configuration files from another location
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev \
  ENV_FILE=/path/to/external/.env \
  MCP_FILE=/path/to/external/mcp-servers.json \
  GIT_CONFIG_FILE=/path/to/external/git-repos.conf

# Example: Using configurations from another project
make deploy-full VM_HOST=192.168.1.100 TARGET_USER=dev \
  ENV_FILE=~/my-configs/.env \
  MCP_FILE=~/my-configs/mcp-servers.json
```

### Authentication Options
```bash
# SSH key authentication
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev \
  TARGET_SSH_KEY=~/.ssh/custom_key

# Password authentication
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev \
  USE_SSH_PASSWORD=true SSH_PASSWORD=secure_password

# Sudo password required
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev \
  USE_BECOME_PASSWORD=true BECOME_PASSWORD=sudo_password
```

### Component-Specific Deployment
```bash
# Deploy specific components using Ansible directly
ansible-playbook ansible/playbooks/site.yml --tags git,git-repos
ansible-playbook ansible/playbooks/site.yml --tags docker -e install_docker=true
ansible-playbook ansible/playbooks/site.yml --tags kubernetes -e install_kubectl=true
ansible-playbook ansible/playbooks/site.yml --tags bashrc -e enable_bashrc_integrations=true
ansible-playbook ansible/playbooks/site.yml --tags uvx
```

## 📋 Requirements

- **Target VM**: Debian 12+ (Bookworm) with SSH access and sudo privileges
- **Local Machine**: Ansible 2.9+ installed
- **Network**: SSH connectivity between local machine and target VM
- **Optional**: Git Personal Access Tokens for automated credential setup
- **Optional**: MCP API keys (Brave Search, GitHub, GitLab) for AI enhancements

## 🔍 Troubleshooting

### Connection Issues
```bash
# Test basic connectivity
make test-connection VM_HOST=192.168.1.100 TARGET_USER=dev

# Check configuration
make check-config

# Manual verification
ssh dev@192.168.1.100 'docker --version && kubectl version --client && node --version'
```

### Deployment Issues
```bash
# Verbose deployment for debugging
ansible-playbook ansible/playbooks/site.yml -vvv

# Check specific component
ansible-playbook ansible/playbooks/site.yml --tags docker --check --diff

# Validate after deployment
make validate VM_HOST=192.168.1.100 TARGET_USER=dev
```

### Post-Deployment
```bash
# On target VM, update shell environment
source ~/.bashrc

# Verify installations
docker --version
kubectl version --client
claude --version
uvx --version
```

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** - Complete deployment reference and architecture
- **[Ansible Configuration](docs/ansible-configuration.md)** - Variables and role documentation
- **[MCP Server Setup](docs/components-mcp.md)** - AI extensions and API configuration
- **[Git Configuration](docs/git-configuration.md)** - Multi-provider Git setup
- **[Authentication Guide](docs/authentication.md)** - SSH keys, passwords, security

## 🔄 Migration & Compatibility

### Legacy Command Support
The new 4-tier system maintains backward compatibility:
- `make deploy-base` → `make deploy-enhanced` (legacy alias)
- `make deploy` → `make deploy-full` (legacy alias)

### Upgrading Existing Deployments
```bash
# From old deploy-base to new enhanced
make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=dev

# From old deploy to new full with k3s
make deploy-full VM_HOST=192.168.1.100 TARGET_USER=dev KUBERNETES_BACKEND=k3s
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Ready to deploy?** Start with `make setup` and choose your tier! 🚀

**Need help?** Check the [documentation](docs/) or [open an issue](../../issues) for support.