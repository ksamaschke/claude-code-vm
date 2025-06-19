# Ansible Debian Stack Deployment

A comprehensive Ansible playbook that deploys a complete development environment on Debian VMs with enterprise-grade Git credential management, containerization tools, and modern development stack.

## 🚀 Features

### **Core Development Stack**
- **Git** with Git Credential Manager and SSH key authentication
- **Docker CE** with Docker Compose plugin
- **Node.js 22 LTS** via NodeSource repository  
- **Claude Code CLI** for AI-assisted development

### **Kubernetes Development Tools**
- **kubectl** v1.33.2 - Kubernetes command-line tool
- **kind** v0.29.0 - Local Kubernetes clusters using Docker
- **kompose** v1.36.0 - Convert Docker Compose to Kubernetes
- **Bash completions** and aliases for all CLI tools

### **🔐 Advanced Git Credential Management**
- **URL-based PAT system** - Support multiple Git hosting services
- **Multi-instance support** - Multiple GitLab, Gitea, Azure DevOps instances
- **Enterprise-friendly** - Handle complex corporate Git environments
- **Dynamic discovery** - No hardcoded services, extensible configuration
- **Secure storage** - Encrypted credentials via Git Credential Manager

## 📋 Prerequisites

1. **Ansible** installed on control machine
2. **SSH key access** to target VM
3. **Target user has sudo privileges**
4. **Target VM has internet connectivity**
5. **Debian 12+ (Bookworm)** on target VM

## 🏗️ Project Structure

```
ansible-debian-stack/
├── .env                           # Git credentials configuration (create from .env.example)
├── .env.example                   # Template with examples for all Git services
├── .gitignore                     # Protects .env from version control
├── ansible.cfg                    # Ansible configuration
├── README.md                      # This file
├── 999_progress-folder/           # Deployment progress tracking
├── inventories/
│   └── production/
│       ├── hosts.yml             # Target host configuration
│       └── group_vars/all.yml    # Global variables
├── playbooks/
│   ├── site.yml                  # Main deployment playbook
│   └── validate.yml              # Post-deployment validation
└── roles/
    ├── common/                   # System preparation
    ├── git/                      # Git + credential management
    ├── docker/                   # Docker installation
    ├── nodejs/                   # Node.js installation
    ├── claude-code/              # Claude Code installation
    └── kubernetes/               # Kubernetes tools
```

## ⚙️ Quick Start

### 1. **Clone and Navigate**
```bash
git clone <repository-url>
cd ansible-debian-stack
```

### 2. **Configure Target Host**
Edit `inventories/production/hosts.yml`:
```yaml
debian_servers:
  hosts:
    debian-vm:
      ansible_host: 192.168.1.111        # Your VM IP
      ansible_user: ksamaschke            # Your VM user
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### 3. **Configure Git Credentials**
```bash
# Copy template
cp .env.example .env

# Edit with your credentials
nano .env
```

### 4. **Test Connection**
```bash
ansible debian-vm -m ping
```

### 5. **Deploy Complete Stack**
```bash
# Syntax check
ansible-playbook --syntax-check playbooks/site.yml

# Dry run
ansible-playbook --check --diff playbooks/site.yml

# Deploy
ansible-playbook playbooks/site.yml

# Validate
ansible-playbook playbooks/validate.yml
```

## 🔐 Git Credential Configuration

### **URL-Based PAT System**

Instead of hardcoded service limitations, use this flexible pattern:

```bash
# Pattern: GIT_SERVER_{UNIQUE_ID}_{FIELD}
GIT_SERVER_{ID}_URL="https://git.server.com"
GIT_SERVER_{ID}_USERNAME="your-username"  
GIT_SERVER_{ID}_PAT="your-personal-access-token"
```

### **Example .env Configuration**

```bash
# Git Identity
GIT_USER_NAME="Your Full Name"
GIT_USER_EMAIL="your.email@example.com"

# GitHub.com
GIT_SERVER_GITHUB_URL="https://github.com"
GIT_SERVER_GITHUB_USERNAME="your-github-username"
GIT_SERVER_GITHUB_PAT="ghp_your_github_token_here"

# Company GitLab
GIT_SERVER_COMPANY_GITLAB_URL="https://gitlab.company.com"
GIT_SERVER_COMPANY_GITLAB_USERNAME="your-company-username"
GIT_SERVER_COMPANY_GITLAB_PAT="glpat-your_company_token_here"

# Client GitLab Instance
GIT_SERVER_CLIENT_GITLAB_URL="https://gitlab.client.com"
GIT_SERVER_CLIENT_GITLAB_USERNAME="your-client-username"
GIT_SERVER_CLIENT_GITLAB_PAT="glpat-your_client_token_here"

# Partner Gitea Server
GIT_SERVER_GITEA_PARTNER_URL="https://git.partner.com"
GIT_SERVER_GITEA_PARTNER_USERNAME="your-partner-username"
GIT_SERVER_GITEA_PARTNER_PAT="your_partner_gitea_token_here"

# Azure DevOps Organization
GIT_SERVER_AZURE_ORG1_URL="https://dev.azure.com/organization1"
GIT_SERVER_AZURE_ORG1_USERNAME="your-azure-username"
GIT_SERVER_AZURE_ORG1_PAT="your_azure_devops_token_here"

# GitHub Enterprise
GIT_SERVER_GHE_URL="https://github.company.com"
GIT_SERVER_GHE_USERNAME="your-enterprise-username"
GIT_SERVER_GHE_PAT="ghp_your_github_enterprise_token_here"

# Custom Git Server
GIT_SERVER_CUSTOM1_URL="https://git.custom.com"
GIT_SERVER_CUSTOM1_USERNAME="your-custom-username"
GIT_SERVER_CUSTOM1_PAT="your_custom_git_server_token_here"

# Advanced Configuration
DEFAULT_GIT_SERVICE="GITHUB"              # For SSH URL conversion
ENABLE_SSH_CONVERSION="false"             # Auto-convert HTTPS to SSH
```

### **Supported Git Services**

The system works with **ANY** Git hosting service:

- ✅ **GitHub** (github.com + GitHub Enterprise)
- ✅ **GitLab** (gitlab.com + self-hosted instances)
- ✅ **Azure DevOps** (multiple organizations)
- ✅ **Bitbucket** (bitbucket.org + Atlassian Cloud)
- ✅ **Gitea** (unlimited instances)
- ✅ **Gitiles**, **cgit**, **Gerrit**
- ✅ **Any custom Git server**

### **Adding New Git Servers**

Simply add three lines to your `.env` file:

```bash
GIT_SERVER_NEWSERVER_URL="https://git.newserver.com"
GIT_SERVER_NEWSERVER_USERNAME="your-username"
GIT_SERVER_NEWSERVER_PAT="your-token"
```

The Ansible playbook **automatically discovers** and configures it!

## 🎮 Usage Commands

### **Complete Deployment**
```bash
# Deploy everything
ansible-playbook playbooks/site.yml

# Validate everything
ansible-playbook playbooks/validate.yml
```

### **Component-Specific Deployment**
```bash
# Git configuration only
ansible-playbook playbooks/site.yml --tags git

# Docker only
ansible-playbook playbooks/site.yml --tags docker

# Node.js only
ansible-playbook playbooks/site.yml --tags nodejs

# Claude Code only
ansible-playbook playbooks/site.yml --tags claude-code

# Kubernetes tools only
ansible-playbook playbooks/site.yml --tags kubernetes
```

### **Testing and Validation**
```bash
# Syntax check
ansible-playbook --syntax-check playbooks/site.yml

# Dry run (see what would change)
ansible-playbook --check --diff playbooks/site.yml

# Validate specific components
ansible-playbook playbooks/validate.yml --tags git
ansible-playbook playbooks/validate.yml --tags docker
ansible-playbook playbooks/validate.yml --tags kubernetes
```

### **Debugging**
```bash
# Verbose output
ansible-playbook playbooks/site.yml --tags git -v

# Very verbose
ansible-playbook playbooks/site.yml --tags git -vvv

# Test connectivity
ansible debian-vm -m ping

# Check Git configuration
ansible debian-vm -m shell -a "git config --global --list" --become-user ksamaschke
```

## 🔧 Configuration

### **Global Variables** (`inventories/production/group_vars/all.yml`)

```yaml
# System configuration
target_user: ksamaschke
debian_version: bookworm

# Git configuration
install_git_credential_manager: true
generate_ssh_keys: true
use_env_file: true
configure_pats: true

# Docker configuration
docker_users: [ksamaschke]
docker_install_compose: true

# Node.js configuration
nodejs_version: "22"
nodejs_npm_global_packages:
  - "@anthropic-ai/claude-code"

# Kubernetes tools
install_kubectl: true
install_kind: true
install_kompose: true
install_bash_completion: true
```

### **Host Configuration** (`inventories/production/hosts.yml`)

```yaml
debian_servers:
  hosts:
    debian-vm:
      ansible_host: 192.168.1.111
      ansible_user: ksamaschke
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
      ansible_sudo_pass: "{{ vault_sudo_password | default(omit) }}"
      ansible_become: true
```

## 🔒 Security

### **Best Practices Implemented**

- ✅ **Official repositories only** - All packages from official sources
- ✅ **GPG signature verification** - Package integrity validated
- ✅ **No hardcoded secrets** - All credentials from .env file
- ✅ **Encrypted credential storage** - Git Credential Manager encryption
- ✅ **SSH key authentication** - ed25519 keys generated automatically
- ✅ **Version pinning** - Controlled package versions
- ✅ **.gitignore protection** - .env file never committed

### **Credential Security**

- 🔐 **PATs never logged** - `no_log: true` prevents exposure
- 🔐 **Encrypted storage** - Git Credential Manager handles encryption
- 🔐 **Per-host authentication** - Each Git server gets unique credentials
- 🔐 **File permissions** - Proper ownership and permissions
- 🔐 **Token rotation** - Easy to update tokens without affecting others

### **Generated SSH Key**

```bash
# Location
~/.ssh/id_ed25519      # Private key
~/.ssh/id_ed25519.pub  # Public key (add to Git hosting services)

# View public key
cat ~/.ssh/id_ed25519.pub
```

## 🧪 Post-Deployment Testing

### **Manual Verification**

```bash
# SSH into VM
ssh ksamaschke@192.168.1.111

# Check versions
docker --version
docker compose version
node --version
npm --version
claude --version
kubectl version --client
kind version
kompose version

# Test Docker
docker run --rm hello-world

# Test Git authentication (will use stored PATs)
git clone https://github.com/user/repo.git
git clone https://gitlab.company.com/team/project.git

# Check Git configuration
git config --global --list

# Test Kubernetes tools
kubectl completion bash
kind create cluster --name test
kubectl cluster-info --context kind-test
kind delete cluster --name test
```

### **Automated Validation**

```bash
# Run validation playbook
ansible-playbook playbooks/validate.yml

# Expected output:
# ✅ Git configured with multiple servers
# ✅ Docker working with group membership
# ✅ Node.js and npm properly installed
# ✅ Claude Code ready for authentication
# ✅ Kubernetes tools with bash completion
```

## 🚀 Advanced Usage

### **Multi-Environment Deployment**

```bash
# Production environment
ansible-playbook -i inventories/production playbooks/site.yml

# Development environment
ansible-playbook -i inventories/development playbooks/site.yml
```

### **Selective Updates**

```bash
# Update only Git credentials
ansible-playbook playbooks/site.yml --tags credentials,pats

# Update only Kubernetes tools
ansible-playbook playbooks/site.yml --tags kubernetes

# Update Node.js packages
ansible-playbook playbooks/site.yml --tags nodejs --skip-tags packages
```

### **Custom Configuration Override**

```bash
# Override variables
ansible-playbook playbooks/site.yml -e "nodejs_version=20" -e "gcm_version=2.7.0"

# Use different inventory
ansible-playbook -i custom_inventory.yml playbooks/site.yml
```

## 🌍 Enterprise Scenarios

### **Multi-Organization Setup**

Perfect for consulting firms, contractors, or large enterprises:

```bash
# Consultant working with multiple clients
GIT_SERVER_CLIENT_A_GITLAB_URL="https://gitlab.clienta.com"
GIT_SERVER_CLIENT_B_GITLAB_URL="https://gitlab.clientb.com"  
GIT_SERVER_CLIENT_C_AZURE_URL="https://dev.azure.com/clientc"
GIT_SERVER_PERSONAL_GITHUB_URL="https://github.com"
GIT_SERVER_COMPANY_GITEA_URL="https://git.company.com"
```

### **Large Enterprise Setup**

Handle complex corporate environments:

```bash
# Multiple internal Git services
GIT_SERVER_MAIN_GITLAB_URL="https://gitlab.corp.com"
GIT_SERVER_R_AND_D_GITLAB_URL="https://gitlab.rd.corp.com"
GIT_SERVER_LEGACY_GERRIT_URL="https://gerrit.legacy.corp.com"
GIT_SERVER_PARTNER_A_URL="https://git.partnera.com"
GIT_SERVER_PARTNER_B_URL="https://git.partnerb.com"
GIT_SERVER_PUBLIC_GITHUB_URL="https://github.com"
```

## 🔄 Maintenance

### **Updating PATs**

1. Edit `.env` file with new tokens
2. Re-run: `ansible-playbook playbooks/site.yml --tags credentials,pats`

### **Adding New Git Servers**

1. Add three lines to `.env`:
   ```bash
   GIT_SERVER_NEWSERVER_URL="https://git.new.com"
   GIT_SERVER_NEWSERVER_USERNAME="username"
   GIT_SERVER_NEWSERVER_PAT="token"
   ```
2. Re-run: `ansible-playbook playbooks/site.yml --tags git`

### **Version Updates**

Update versions in `inventories/production/group_vars/all.yml`:
```yaml
nodejs_version: "22"      # Update Node.js version
gcm_version: "2.6.0"      # Update Git Credential Manager
kind_version: "v0.29.0"   # Update kind version
```

## 🆘 Troubleshooting

### **Common Issues**

#### **SSH Connection Failed**
```bash
# Check VM is running and accessible
ping 192.168.1.111

# Verify SSH key
ssh-add ~/.ssh/id_rsa

# Test manual connection
ssh ksamaschke@192.168.1.111
```

#### **Permission Denied**
```bash
# Check sudo privileges
ssh ksamaschke@192.168.1.111 sudo -l

# Verify user in sudoers
```

#### **Docker Group Issues**
```bash
# Log out and back in after Docker installation
# Or start new shell session
newgrp docker
```

#### **Git Authentication Issues**
```bash
# Check stored credentials
git-credential-manager list

# Test specific server
git ls-remote https://github.com/user/repo.git

# Debug Git Credential Manager
GCM_TRACE=1 git clone https://github.com/user/repo.git
```

#### **Path Issues**
```bash
# Source ~/.bashrc to update PATH
source ~/.bashrc

# Or start new shell session
```

### **Debug Mode**

```bash
# Enable debug output
ansible-playbook playbooks/site.yml --tags git -vvv

# Check specific configuration
ansible debian-vm -m shell -a "git config --global --list" --become-user ksamaschke

# Verify .env file parsing
ansible-playbook playbooks/site.yml --tags env-file -v
```

### **Log Files**

- **Ansible execution**: `./ansible.log`
- **System logs**: `/var/log/syslog` on target VM
- **Git Credential Manager**: Debug with `GCM_TRACE=1`

## 🏆 Success Criteria

After successful deployment, you should have:

- ✅ **Seamless Git authentication** across all configured servers
- ✅ **Docker containers** running without sudo
- ✅ **Node.js applications** working with global packages
- ✅ **Claude Code** ready for AI-assisted development
- ✅ **Kubernetes development** with local clusters via kind
- ✅ **Bash completions** for all CLI tools
- ✅ **SSH keys** configured for additional security

### **Verification Commands**

```bash
# Test complete workflow
git clone https://github.com/user/repo.git      # Should work without prompts
docker run --rm hello-world                     # Should work without sudo
node --version && npm --version                  # Should show v22.x and v10.x
claude --version                                # Should show Claude Code version
kubectl version --client                        # Should show v1.33.2
kind create cluster --name test                  # Should create local cluster
kompose version                                 # Should show v1.36.0
```

## 📞 Support

### **Getting Help**

1. **Check logs**: Review Ansible output and system logs
2. **Validate syntax**: `ansible-playbook --syntax-check playbooks/site.yml`
3. **Test connectivity**: `ansible debian-vm -m ping`
4. **Run validation**: `ansible-playbook playbooks/validate.yml`

### **Common Commands Reference**

```bash
# Quick deployment
ansible-playbook playbooks/site.yml --tags git

# Full validation
ansible-playbook playbooks/validate.yml

# Debug connection
ansible debian-vm -m ping -vvv

# Check Git config
ansible debian-vm -m shell -a "git config --global --list" --become-user ksamaschke
```

---

## 🎉 Conclusion

This Ansible playbook provides a **production-ready development environment** with:

- **Flexible Git credential management** supporting multiple hosting services
- **Complete containerization stack** with Docker and Kubernetes tools
- **Modern Node.js development environment** with AI assistance
- **Security-first approach** with encrypted credential storage
- **Zero-maintenance operation** after deployment

Perfect for **developers**, **DevOps teams**, **consultants**, and **enterprises** who need reliable, scalable, and secure development environments.

A reliable foundation for modern development workflows.