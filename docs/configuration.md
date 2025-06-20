# Configuration Guide

Comprehensive configuration options for the Claude Code VM deployment system.

## Configuration Files

### Primary Configuration
- **`.env`** - Environment variables, Git credentials, API keys
- **`group_vars/all.yml`** - Global Ansible variables
- **`inventory.yml`** - Target host definitions
- **`ansible.cfg`** - Ansible behavior settings

### Templates and Examples
- **`.env.example`** - Environment template
- **`mcp-servers.template.json`** - MCP configuration template
- **`docs/inventory-examples.yml`** - Inventory examples

## Environment Variables (.env)

### Required Git Configuration
At least one Git server must be configured:

```bash
# GitHub
GIT_SERVER_GITHUB_URL="https://github.com"
GIT_SERVER_GITHUB_USERNAME="yourusername"
GIT_SERVER_GITHUB_PAT="ghp_xxxxxxxxxxxxxxxxxxxx"

# GitLab
GIT_SERVER_GITLAB_URL="https://gitlab.com"
GIT_SERVER_GITLAB_USERNAME="yourusername"
GIT_SERVER_GITLAB_PAT="glpat-xxxxxxxxxxxxxxxxxxxx"

# Azure DevOps
GIT_SERVER_AZURE_URL="https://dev.azure.com/yourorg"
GIT_SERVER_AZURE_USERNAME="yourusername"
GIT_SERVER_AZURE_PAT="xxxxxxxxxxxxxxxxxxxxxxx"

# Custom Git Server
GIT_SERVER_CUSTOM_URL="https://git.company.com"
GIT_SERVER_CUSTOM_USERNAME="yourusername"
GIT_SERVER_CUSTOM_PAT="your-token"
```

### MCP Server API Keys (Optional)
```bash
# Search Providers
BRAVE_API_KEY="your_brave_search_api_key"
TAVILY_API_KEY="your_tavily_api_key"
KAGI_API_KEY="your_kagi_api_key"
PERPLEXITY_API_KEY="your_perplexity_api_key"
JINA_API_KEY="your_jina_api_key"

# Context7 (Upstash Redis)
UPSTASH_REDIS_REST_URL="https://your-redis-url.upstash.io"
UPSTASH_REDIS_REST_TOKEN="your_redis_token"
```

## Ansible Variables (group_vars/all.yml)

### Connection Settings
```yaml
# Connection credentials (required)
vm_host: "{{ vm_host | mandatory }}"
vm_user: "{{ vm_user | default('root') }}"
vm_ssh_key: "{{ vm_ssh_key | default('~/.ssh/id_rsa') }}"
target_vm_user: "{{ target_vm_user | mandatory }}"

# Authentication options
connect_as_target_user: "{{ connect_as_target_user | default(false) }}"
target_user_ssh_key: "{{ target_user_ssh_key | default(vm_ssh_key) }}"
use_ssh_password: "{{ use_ssh_password | default(false) }}"
use_become_password: "{{ use_become_password | default(false) }}"
```

### Deployment Paths
```yaml
# Base deployment directory (hidden)
deployment_base_dir: "/home/{{ target_user }}/.claude-code-vm"

# Subdirectories
scripts_dir: "{{ deployment_base_dir }}/scripts"
config_dir: "{{ deployment_base_dir }}/config"
logs_dir: "{{ deployment_base_dir }}/logs"
temp_dir: "{{ deployment_base_dir }}/tmp"
screen_logs_dir: "{{ logs_dir }}/screen"
```

### Component Versions
```yaml
# Software versions
nodejs_version: "22"
docker_compose_version: "v2.24.0"
gcm_version: "2.4.1"
kubectl_version: "v1.28.0"
kind_version: "v0.20.0"
```

### Feature Toggles
```yaml
# Component installation flags
install_git: true
install_docker: true
install_nodejs: true
install_claude_code: true
install_kubernetes_tools: true
install_mcp_servers: true

# Git configuration
setup_git_credentials: true
install_git_credential_manager: true

# Screen session configuration
setup_screen_sessions: true
screen_session_name: "{{ custom_session_name | default('KS') }}"
```

## Inventory Configuration

### Single Machine Deployment
Default configuration in `inventory.yml`:
```yaml
all:
  children:
    single:
      hosts:
        target:
          ansible_host: "{{ vm_host }}"
          ansible_user: "{{ effective_ansible_user }}"
          ansible_ssh_private_key_file: "{{ effective_ssh_key }}"
          target_user: "{{ target_vm_user }}"
```

### Group Deployment
Example multi-host configuration:
```yaml
all:
  children:
    production:
      hosts:
        web-01:
          ansible_host: 10.0.1.10
          ansible_user: root
          target_user: webapp
        web-02:
          ansible_host: 10.0.1.11
          ansible_user: root
          target_user: webapp
      vars:
        screen_session_name: PROD
        install_kubernetes_tools: true
        
    staging:
      hosts:
        staging-01:
          ansible_host: 10.0.2.10
          target_user: developer
      vars:
        screen_session_name: STAGING
        install_kubernetes_tools: false
```

## Makefile Configuration

### Environment Variables
Override any setting via environment variables:
```bash
export VM_HOST="192.168.1.100"
export TARGET_USER="developer"
export ENV_FILE="/path/to/production.env"
export DEPLOYMENT_DIR="/opt/claude-code-vm"

make deploy
```

### Command Line Parameters
```bash
# Basic deployment
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer

# Custom authentication
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer \
    CONNECT_AS_TARGET=true TARGET_SSH_KEY=~/.ssh/dev_key

# Custom configuration files
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer \
    ENV_FILE=/path/to/custom.env MCP_FILE=/path/to/mcp.json

# Group deployment
make deploy DEPLOY_TARGET=production
```

## Per-Host Configuration

### Host-Specific Variables
```yaml
# inventory.yml
all:
  children:
    production:
      hosts:
        high-mem-server:
          ansible_host: 10.0.1.10
          target_user: webapp
          # Custom deployment path for this host
          deployment_base_dir: "/opt/claude-code-vm"
          # Skip Kubernetes tools on this server
          install_kubernetes_tools: false
```

### Group Variables
```yaml
# group_vars/production.yml
screen_session_name: PROD
install_docker: true
install_kubernetes_tools: true

# Stricter security for production
connect_as_target_user: true
use_become_password: true
```

## MCP Server Configuration

### Automatic Configuration
MCP servers are automatically configured based on available API keys in `.env`:

```bash
# Only configure servers with valid API keys
BRAVE_API_KEY="key123"     # Brave Search MCP will be configured
TAVILY_API_KEY=""          # Tavily MCP will be skipped
# KAGI_API_KEY not set     # Kagi MCP will be skipped
```

### Manual Configuration
Create `mcp-servers.json` for custom MCP setup:
```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "your_api_key"
      }
    }
  }
}
```

## Advanced Configuration

### Custom SSH Configuration
```yaml
# inventory.yml
target:
  ansible_host: "{{ vm_host }}"
  ansible_user: "{{ effective_ansible_user }}"
  ansible_ssh_private_key_file: "{{ effective_ssh_key }}"
  ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  ansible_ssh_pipelining: true
```

### Docker Configuration
```yaml
# group_vars/all.yml
docker_users:
  - "{{ target_user }}"
docker_daemon_options:
  storage-driver: overlay2
  log-driver: json-file
  log-opts:
    max-size: 100m
    max-file: "3"
```

### Git Configuration
```yaml
# group_vars/all.yml
git_global_config:
  user.name: "{{ git_user_name | default('Claude Code User') }}"
  user.email: "{{ git_user_email | default('user@example.com') }}"
  init.defaultBranch: main
  pull.rebase: false
```

## Validation and Testing

### Configuration Validation
```bash
# Validate Ansible syntax
ansible-playbook --syntax-check ansible-debian-stack/playbooks/site.yml

# Test variable resolution
ansible-playbook ansible-debian-stack/playbooks/site.yml --list-tasks -e "vm_host=test target_vm_user=test"

# Dry run
make dry-run VM_HOST=192.168.1.100 TARGET_USER=developer
```

### Configuration Testing
```bash
# Test connectivity
make check VM_HOST=192.168.1.100 TARGET_USER=developer

# Test specific components
make validate-git VM_HOST=192.168.1.100 TARGET_USER=developer
make validate-docker VM_HOST=192.168.1.100 TARGET_USER=developer
make validate-mcp VM_HOST=192.168.1.100 TARGET_USER=developer
```

## Configuration Examples

See [Inventory Examples](inventory-examples.yml) for complete configuration examples including:
- Single machine deployment
- Multi-environment setup
- Custom authentication
- Host-specific configurations
- Production-ready configurations

## Next Steps

- [Authentication Guide](authentication.md) - Security and access configuration
- [Deployment Guide](deployment-single.md) - Single machine deployment
- [Component Guides](components-git.md) - Individual component configuration