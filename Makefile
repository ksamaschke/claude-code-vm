# =============================================================================
# Claude Code VM Deployment Makefile
# =============================================================================
# 
# Streamlined deployment system for Claude Code development environments
# 
# Usage Examples:
#   make deploy-full VM_HOST=192.168.1.100 TARGET_USER=dev      # Full deployment
#   make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=dev  # CLAUDE.md and settings.json
#   make validate VM_HOST=192.168.1.100 TARGET_USER=dev         # Validate deployment
#   make setup                                                  # First-time setup
#
# =============================================================================

.PHONY: help deploy-baseline deploy-enhanced deploy-containerized deploy-full validate clean setup check-config test-connection create-dynamic-inventory deploy-git-repos deploy-mcp deploy-claude-config

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[1;37m
NC := \033[0m

# =============================================================================
# Configuration Variables (Override with environment or command line)
# =============================================================================
# Connection settings (REQUIRED)
VM_HOST ?= 
VM_USER ?= root
TARGET_USER ?= 

# Optional settings with defaults
SESSION_NAME ?= DEV
DEPLOYMENT_DIR ?= /home/$(TARGET_USER)/.claude-code-vm

# Deployment tier settings (optional)
KUBERNETES_BACKEND ?= k3s
MANAGE_GIT_REPOSITORIES ?= false

# Authentication settings (optional)
CONNECT_AS_TARGET ?= false
TARGET_SSH_KEY ?= 
USE_SSH_PASSWORD ?= false
SSH_PASSWORD ?= 
USE_BECOME_PASSWORD ?= false
BECOME_PASSWORD ?= 

# Deployment target (single machine vs group)
DEPLOY_TARGET ?= single

# File paths (can be overridden) - defaults to config directory
ENV_FILE ?= config/.env
MCP_FILE ?= config/mcp-servers.json
GIT_CONFIG_FILE ?= $(ENV_FILE)
CLAUDE_SETTINGS_FILE ?= config/claude-settings.json
SSH_KEY ?= ~/.ssh/id_rsa
TEMP_BASE_PATH ?= .tmp

# Ansible configuration
ANSIBLE_PLAYBOOK := ansible-playbook
PLAYBOOK_DIR := ansible/playbooks
LIMIT_FLAG := $(if $(filter single,$(DEPLOY_TARGET)),--limit target,--limit $(DEPLOY_TARGET))
EXTRA_VARS := vm_host=$(VM_HOST) vm_user=$(if $(and $(filter root,$(VM_USER)),$(TARGET_USER)),$(TARGET_USER),$(VM_USER)) target_vm_user=$(TARGET_USER) remote_deployment_dir=$(DEPLOYMENT_DIR) custom_session_name=$(SESSION_NAME)

# Detect localhost deployment
IS_LOCALHOST := $(filter localhost 127.0.0.1,$(VM_HOST))
ANSIBLE_CONNECTION := $(if $(IS_LOCALHOST),--connection=local,)

# Add authentication variables if provided
ifneq ($(CONNECT_AS_TARGET),false)
	EXTRA_VARS += connect_as_target_user=$(CONNECT_AS_TARGET)
endif

ifneq ($(TARGET_SSH_KEY),)
	EXTRA_VARS += target_user_ssh_key=$(TARGET_SSH_KEY)
endif

ifneq ($(USE_SSH_PASSWORD),false)
	EXTRA_VARS += use_ssh_password=$(USE_SSH_PASSWORD)
endif

ifneq ($(SSH_PASSWORD),)
	EXTRA_VARS += ssh_password=$(SSH_PASSWORD)
endif

ifneq ($(USE_BECOME_PASSWORD),false)
	EXTRA_VARS += use_become_password=$(USE_BECOME_PASSWORD)
endif

ifneq ($(BECOME_PASSWORD),)
	EXTRA_VARS += become_password=$(BECOME_PASSWORD)
endif

# Add custom file paths if provided
ifneq ($(ENV_FILE),.env)
	EXTRA_VARS += custom_env_file=$(ENV_FILE)
endif

ifneq ($(MCP_FILE),mcp-servers.json)
	EXTRA_VARS += custom_mcp_servers_file=$(MCP_FILE)
endif

ifneq ($(GIT_CONFIG_FILE),$(ENV_FILE))
	EXTRA_VARS += custom_git_config_file=$(GIT_CONFIG_FILE)
endif

ifneq ($(CLAUDE_SETTINGS_FILE),config/claude-settings.json)
	EXTRA_VARS += custom_claude_settings_file=$(CLAUDE_SETTINGS_FILE)
endif

# Add user configuration options
ifneq ($(CREATE_USER_CLAUDE_CONFIG),)
	EXTRA_VARS += create_user_claude_config=$(CREATE_USER_CLAUDE_CONFIG)
endif

ifneq ($(ALLOW_COMMAND_EXECUTION),)
	EXTRA_VARS += allow_command_execution=$(ALLOW_COMMAND_EXECUTION)
endif

# Add Git user configuration options
ifneq ($(GIT_USER_NAME),)
	EXTRA_VARS += git_user_name='$(GIT_USER_NAME)'
endif

ifneq ($(GIT_USER_EMAIL),)
	EXTRA_VARS += git_user_email='$(GIT_USER_EMAIL)'
endif

# Add package management options
ifneq ($(SKIP_PACKAGE_UPGRADE),)
	EXTRA_VARS += upgrade_packages=false
endif

# Add Git repository management options
ifneq ($(MANAGE_GIT_REPOSITORIES),)
	EXTRA_VARS += manage_git_repositories=$(MANAGE_GIT_REPOSITORIES)
endif

# =============================================================================
# Help & Information
# =============================================================================
help: ## Show this help message
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                    Claude Code VM Deployment System                       ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)📋 Essential Commands:$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { \
		printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 \
	}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(WHITE)🎯 Required Variables:$(NC)"
	@echo "  $(YELLOW)VM_HOST$(NC)         Target VM IP address (REQUIRED)"
	@echo "  $(YELLOW)TARGET_USER$(NC)     Target user on VM (REQUIRED)"
	@echo ""
	@echo "$(WHITE)🔧 Optional Variables:$(NC)"
	@echo "  $(YELLOW)VM_USER$(NC)             SSH user for deployment (default: $(VM_USER))"
	@echo "  $(YELLOW)ENV_FILE$(NC)            Environment file path (default: $(ENV_FILE))"
	@echo "  $(YELLOW)GIT_CONFIG_FILE$(NC)     Git configuration file path (default: same as ENV_FILE)"
	@echo "  $(YELLOW)KUBERNETES_BACKEND$(NC)  Kubernetes backend: k3s or kind (default: $(KUBERNETES_BACKEND))"
	@echo "  $(YELLOW)MANAGE_GIT_REPOSITORIES$(NC) Enable Git repository management (default: $(MANAGE_GIT_REPOSITORIES))"
	@echo "  $(YELLOW)TARGET_SSH_KEY$(NC)      SSH key for target user (optional)"
	@echo "  $(YELLOW)USE_SSH_PASSWORD$(NC)    Use password instead of key (default: $(USE_SSH_PASSWORD))"
	@echo "  $(YELLOW)USE_BECOME_PASSWORD$(NC) Sudo requires password (default: $(USE_BECOME_PASSWORD))"
	@echo ""
	@echo "$(WHITE)📝 Common Usage Examples:$(NC)"
	@echo "  $(CYAN)# Complete deployment:$(NC)"
	@echo "  $(CYAN)make deploy-full VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo ""
	@echo "  $(CYAN)# First-time setup:$(NC)"
	@echo "  $(CYAN)make setup$(NC)"
	@echo "  $(CYAN)# Edit .env file with your credentials, then:$(NC)"
	@echo "  $(CYAN)make deploy-full VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo ""
	@echo "  $(CYAN)# Validate existing deployment:$(NC)"
	@echo "  $(CYAN)make validate VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo ""
	@echo "$(WHITE)🏗️ 4-Tier Deployment System:$(NC)"
	@echo "  $(CYAN)# Tier 1 - Baseline: Git + Node.js + Claude Code + uvx$(NC)"
	@echo "  $(CYAN)make deploy-baseline VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo ""
	@echo "  $(CYAN)# Tier 2 - Enhanced: Baseline + MCPs + Docker$(NC)"
	@echo "  $(CYAN)make deploy-enhanced VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo ""
	@echo "  $(CYAN)# Tier 3 - Containerized: Enhanced + Docker Compose + bashrc$(NC)"
	@echo "  $(CYAN)make deploy-containerized VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo ""
	@echo "  $(CYAN)# Tier 4 - Full: Everything + Kubernetes (k3s default)$(NC)"
	@echo "  $(CYAN)make deploy-full VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo "  $(CYAN)make deploy-full VM_HOST=192.168.1.100 TARGET_USER=developer KUBERNETES_BACKEND=kind$(NC)"
	@echo ""
	@echo "$(WHITE)⚙️ Component-Specific Deployments:$(NC)"
	@echo "  $(CYAN)# Deploy CLAUDE.md and settings.json:$(NC)"
	@echo "  $(CYAN)make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo "  $(CYAN)make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=developer CLAUDE_CONFIG_TEMPLATE=config/CLAUDE.full.md$(NC)"
	@echo "  $(CYAN)make deploy-claude-config VM_HOST=192.168.1.100 TARGET_USER=developer CLAUDE_SETTINGS_FILE=/path/to/settings.json$(NC)"
	@echo "  $(CYAN)make deploy-claude-config VM_HOST=localhost TARGET_USER=\$$USER$(NC)"
	@echo ""
	@echo "  $(CYAN)# Deploy MCP servers only:$(NC)"
	@echo "  $(CYAN)make deploy-mcp VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo ""
	@echo "  $(CYAN)# Deploy Git repositories only:$(NC)"
	@echo "  $(CYAN)make deploy-git-repos VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo ""
	@echo "$(WHITE)🔍 Advanced Ansible Usage:$(NC)"
	@echo "  $(CYAN)# Dry run (check mode):$(NC)"
	@echo "  $(CYAN)ansible-playbook ansible/playbooks/site.yml --check --diff$(NC)"
	@echo ""
	@echo "  $(CYAN)# Deploy with custom variables:$(NC)"
	@echo "  $(CYAN)ansible-playbook ansible/playbooks/site.yml -e vm_host=192.168.1.100 -e target_vm_user=dev$(NC)"
	@echo ""
	@echo "  $(CYAN)# Use custom inventory file:$(NC)"
	@echo "  $(CYAN)ansible-playbook ansible/playbooks/site.yml -i your_inventory.yml$(NC)"

# =============================================================================
# 4-Tier Deployment System
# =============================================================================

# Tier 1: Baseline - Claude Code + Node.js + uvx + Git functionalities
deploy-baseline: check-config test-connection create-dynamic-inventory ## Deploy baseline system (Git, Node.js, Claude Code, uvx)
	@echo "$(WHITE)Deployment Dir: $(YELLOW)$(DEPLOYMENT_DIR)$(NC)"
	@echo ""
	@echo "$(WHITE)🎯 Starting baseline deployment (Git, Node.js, Claude Code, uvx)...$(NC)"
	@if command -v timeout >/dev/null 2>&1; then \
		timeout 1800 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i ansible/inventories/production -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" --tags "common,git,git-repos,nodejs,uvx" $(LIMIT_FLAG); \
	else \
		$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i ansible/inventories/production -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" --tags "common,git,git-repos,nodejs,uvx" $(LIMIT_FLAG); \
	fi || { \
		echo "$(RED)❌ Deployment failed or timed out$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ Baseline deployment complete!$(NC)"

# Tier 2: Enhanced - Baseline + MCPs + Docker + Virtual Development Team
deploy-enhanced: check-config test-connection create-dynamic-inventory ## Deploy enhanced system (Baseline + MCPs + Docker + Virtual Team)
	@echo "$(WHITE)Deployment Dir: $(YELLOW)$(DEPLOYMENT_DIR)$(NC)"
	@echo ""
	@echo "$(WHITE)🎯 Starting enhanced deployment (Baseline + MCPs + Docker + Virtual Team)...$(NC)"
	@if command -v timeout >/dev/null 2>&1; then \
		timeout 1800 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i ansible/inventories/production -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS) install_docker=true intelligent_claude_code_enabled=true" --tags "common,git,git-repos,nodejs,uvx,mcp,docker,claude-config,intelligent-claude-code" $(LIMIT_FLAG); \
	else \
		$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i ansible/inventories/production -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS) install_docker=true intelligent_claude_code_enabled=true" --tags "common,git,git-repos,nodejs,uvx,mcp,docker,claude-config,intelligent-claude-code" $(LIMIT_FLAG); \
	fi || { \
		echo "$(RED)❌ Deployment failed or timed out$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ Enhanced deployment complete!$(NC)"

# Tier 3: Containerized - Enhanced + Docker Compose + bashrc integrations + Virtual Team
deploy-containerized: check-config test-connection create-dynamic-inventory ## Deploy containerized system (Enhanced + Docker Compose + bashrc + Virtual Team)
	@echo "$(WHITE)Deployment Dir: $(YELLOW)$(DEPLOYMENT_DIR)$(NC)"
	@echo ""
	@echo "$(WHITE)🎯 Starting containerized deployment (Enhanced + Docker Compose + bashrc + Virtual Team)...$(NC)"
	@if command -v timeout >/dev/null 2>&1; then \
		timeout 1800 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i ansible/inventories/production -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS) install_docker=true enable_bashrc_integrations=true intelligent_claude_code_enabled=true" --tags "common,git,git-repos,nodejs,uvx,mcp,docker,bashrc,claude-config,intelligent-claude-code" $(LIMIT_FLAG); \
	else \
		$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i ansible/inventories/production -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS) install_docker=true enable_bashrc_integrations=true intelligent_claude_code_enabled=true" --tags "common,git,git-repos,nodejs,uvx,mcp,docker,bashrc,claude-config,intelligent-claude-code" $(LIMIT_FLAG); \
	fi || { \
		echo "$(RED)❌ Deployment failed or timed out$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ Containerized deployment complete!$(NC)"

# Tier 4: Full - Containerized + Kubernetes tools + all CLI tools + comprehensive bashrc + Virtual Team
deploy-full: check-config test-connection create-dynamic-inventory ## Deploy full system (Everything + Kubernetes + comprehensive bashrc + Virtual Team)
	@echo "$(WHITE)Deployment Dir: $(YELLOW)$(DEPLOYMENT_DIR)$(NC)"
	@echo ""
	@echo "$(WHITE)🎯 Starting full deployment (Everything + Kubernetes + Virtual Team)...$(NC)"
	@KUBERNETES_BACKEND="$(KUBERNETES_BACKEND)"; \
	if [ "$$KUBERNETES_BACKEND" = "kind" ]; then \
		KUBERNETES_FLAGS="install_docker=true install_kubectl=true install_kind=true install_k3s=false install_kompose=true"; \
	else \
		KUBERNETES_FLAGS="install_docker=true install_kubectl=true install_k3s=true install_kind=false install_kompose=true"; \
	fi; \
	if command -v timeout >/dev/null 2>&1; then \
		timeout 1800 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i ansible/inventories/production -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS) $$KUBERNETES_FLAGS enable_bashrc_integrations=true intelligent_claude_code_enabled=true" $(LIMIT_FLAG); \
	else \
		$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i ansible/inventories/production -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS) $$KUBERNETES_FLAGS enable_bashrc_integrations=true intelligent_claude_code_enabled=true" $(LIMIT_FLAG); \
	fi || { \
		echo "$(RED)❌ Deployment failed or timed out$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ Full deployment complete!$(NC)"



# =============================================================================
# Validation & Testing
# =============================================================================
validate: check-config test-connection create-dynamic-inventory ## Validate deployed components
	@echo "$(CYAN)✅ Validating deployment...$(NC)"
	@if command -v timeout >/dev/null 2>&1; then \
		timeout 300 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/validate.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG); \
	else \
		$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/validate.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG); \
	fi || { \
		echo "$(RED)❌ Validation failed$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}


check-config: ## Validate configuration and connectivity
	@echo "$(WHITE)🔍 Checking configuration...$(NC)"
	@if [ -z "$(VM_HOST)" ]; then \
		echo "$(RED)❌ VM_HOST is required$(NC)"; \
		echo "$(YELLOW)💡 Usage: make deploy VM_HOST=192.168.1.111 TARGET_USER=username$(NC)"; \
		exit 1; \
	fi
	@if [ -z "$(TARGET_USER)" ]; then \
		echo "$(RED)❌ TARGET_USER is required$(NC)"; \
		echo "$(YELLOW)💡 Usage: make deploy VM_HOST=192.168.1.111 TARGET_USER=username$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "$(RED)❌ Environment file not found: $(ENV_FILE)$(NC)"; \
		echo "$(YELLOW)💡 Create it or specify with ENV_FILE=path$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(MCP_FILE)" ]; then \
		echo "$(YELLOW)⚠️ MCP file not found: $(MCP_FILE) (will use template)$(NC)"; \
	fi
	@echo "$(GREEN)✅ Configuration check passed$(NC)"

test-connection: ## Test network connectivity to target VM
	@if [ -n "$(IS_LOCALHOST)" ]; then \
		echo "$(WHITE)🎯 Local deployment detected ($(VM_HOST))$(NC)"; \
		echo "$(GREEN)✅ No SSH connectivity test needed for localhost$(NC)"; \
		echo "$(WHITE)Target User: $(YELLOW)$(TARGET_USER)$(NC)"; \
		echo ""; \
		echo "$(GREEN)✅ Ready for local deployment!$(NC)"; \
	else \
		echo "$(WHITE)🎯 Testing connectivity to $(VM_HOST)...$(NC)"; \
		TEST_USER="$(VM_USER)"; \
	if [ "$(VM_USER)" = "root" ] && [ -n "$(TARGET_USER)" ]; then \
		TEST_USER="$(TARGET_USER)"; \
		echo "$(WHITE)Note: Auto-detected to connect as target user since VM_USER=root$(NC)"; \
	fi; \
	echo "$(WHITE)Host: $(YELLOW)$(VM_HOST)$(NC)"; \
	echo "$(WHITE)SSH User: $(YELLOW)$$TEST_USER$(NC)"; \
	echo "$(WHITE)Target User: $(YELLOW)$(TARGET_USER)$(NC)"; \
	echo "$(WHITE)SSH Key: $(YELLOW)$(if $(TARGET_SSH_KEY),$(TARGET_SSH_KEY),default)$(NC)"; \
	echo ""; \
	echo "$(WHITE)🎯 Step 1: Testing network connectivity...$(NC)"; \
	if ping -c 1 -W 3 $(VM_HOST) >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Host $(VM_HOST) is reachable via ping$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ Host $(VM_HOST) not responding to ping (firewall may block ICMP)$(NC)"; \
	fi; \
	echo ""; \
	echo "$(WHITE)🎯 Step 2: Testing SSH port connectivity...$(NC)"; \
	PORT_OPEN=false; \
	if command -v nc >/dev/null 2>&1; then \
		if nc -z -w 5 $(VM_HOST) 22 2>/dev/null || nc -zv -w 5 $(VM_HOST) 22 2>&1 | grep -q "succeeded\|connected"; then \
			PORT_OPEN=true; \
		fi; \
	fi; \
	if [ "$$PORT_OPEN" = "false" ] && command -v timeout >/dev/null 2>&1; then \
		if timeout 10 bash -c "</dev/tcp/$(VM_HOST)/22" 2>/dev/null; then \
			PORT_OPEN=true; \
		fi; \
	fi; \
	if [ "$$PORT_OPEN" = "true" ]; then \
		echo "$(GREEN)✅ SSH port 22 is open on $(VM_HOST)$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  SSH port 22 check inconclusive (continuing anyway)$(NC)"; \
		echo "$(YELLOW)💡 Will attempt SSH connection to verify access$(NC)"; \
	fi; \
	echo ""; \
	echo "$(WHITE)🎯 Step 3: Testing SSH authentication...$(NC)"; \
	SSH_CMD="ssh -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=no"; \
	if [ -n "$(TARGET_SSH_KEY)" ]; then \
		SSH_CMD="$$SSH_CMD -i $(TARGET_SSH_KEY)"; \
	fi; \
	SSH_CMD="$$SSH_CMD $$TEST_USER@$(VM_HOST) echo connection-test-successful"; \
	if $$SSH_CMD 2>/dev/null | grep -q "connection-test-successful"; then \
		echo "$(GREEN)✅ SSH authentication successful$(NC)"; \
	else \
		echo "$(RED)❌ SSH authentication failed$(NC)"; \
		echo "$(YELLOW)💡 Possible issues:$(NC)"; \
		echo "$(YELLOW)  - Wrong SSH key: $(if $(TARGET_SSH_KEY),$(TARGET_SSH_KEY),~/.ssh/id_rsa)$(NC)"; \
		echo "$(YELLOW)  - Wrong username: $$TEST_USER$(NC)"; \
		echo "$(YELLOW)  - SSH key not added to VM's authorized_keys$(NC)"; \
		echo "$(YELLOW)  - SSH key has wrong permissions (should be 600)$(NC)"; \
		echo "$(YELLOW)🔧 Quick fixes:$(NC)"; \
		echo "$(YELLOW)  - Check key perms: chmod 600 $(if $(TARGET_SSH_KEY),$(TARGET_SSH_KEY),~/.ssh/id_rsa)$(NC)"; \
		echo "$(YELLOW)  - Test manually: ssh $(if $(TARGET_SSH_KEY),-i $(TARGET_SSH_KEY) ,)$$TEST_USER@$(VM_HOST)$(NC)"; \
		echo "$(YELLOW)  - Try setting VM_USER explicitly: VM_USER=$(TARGET_USER)$(NC)"; \
		exit 1; \
	fi; \
	echo ""; \
	echo "$(WHITE)🎯 Step 4: Testing sudo access...$(NC)"; \
	SSH_CMD="ssh -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=no"; \
	if [ -n "$(TARGET_SSH_KEY)" ]; then \
		SSH_CMD="$$SSH_CMD -i $(TARGET_SSH_KEY)"; \
	fi; \
	SSH_CMD="$$SSH_CMD $$TEST_USER@$(VM_HOST) sudo -n whoami"; \
	if $$SSH_CMD 2>/dev/null | grep -q "root"; then \
		echo "$(GREEN)✅ Sudo access confirmed (passwordless)$(NC)"; \
	elif [ "$(USE_BECOME_PASSWORD)" = "true" ] && [ -n "$(BECOME_PASSWORD)" ]; then \
		echo "$(GREEN)✅ Sudo password provided for deployment$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ Sudo access requires password$(NC)"; \
		echo "$(YELLOW)💡 Add USE_BECOME_PASSWORD=true BECOME_PASSWORD=your_sudo_password$(NC)"; \
	fi; \
	echo ""; \
		echo "$(GREEN)✅ Connectivity test completed successfully!$(NC)"; \
		echo "$(WHITE)Ready to deploy to $(YELLOW)$$TEST_USER@$(VM_HOST)$(NC)"; \
	fi



# =============================================================================
# Git Repository Management
# =============================================================================
deploy-git-repos: check-config test-connection create-dynamic-inventory ## Clone and manage Git repositories
	@echo "$(CYAN)📦 Deploying Git repositories...$(NC)"
	@echo "$(WHITE)Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "$(WHITE)Host: $(YELLOW)$(if $(and $(filter root,$(VM_USER)),$(TARGET_USER)),$(TARGET_USER),$(VM_USER))@$(VM_HOST)$(NC)"
	@echo "$(WHITE)User: $(YELLOW)$(TARGET_USER)$(NC)"
	@echo ""
	@echo "$(WHITE)🎯 Managing Git repositories with Ansible...$(NC)"
	@ANSIBLE_VERBOSITY=""; \
	if [ -n "$(VERBOSE)" ]; then ANSIBLE_VERBOSITY="-$(VERBOSE)"; fi; \
	if command -v timeout >/dev/null 2>&1; then \
		timeout 600 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS) manage_git_repositories=true" $(LIMIT_FLAG) --tags git,git-repos $$ANSIBLE_VERBOSITY; \
	else \
		$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS) manage_git_repositories=true" $(LIMIT_FLAG) --tags git,git-repos $$ANSIBLE_VERBOSITY; \
	fi || { \
		echo "$(RED)❌ Git repository deployment failed$(NC)"; \
		echo "$(YELLOW)💡 Possible issues:$(NC)"; \
		echo "$(YELLOW)  - Invalid Git configuration file format$(NC)"; \
		echo "$(YELLOW)  - Missing Git credentials or URLs$(NC)"; \
		echo "$(YELLOW)  - Network connectivity issues$(NC)"; \
		echo "$(YELLOW)🔧 Troubleshooting:$(NC)"; \
		echo "$(YELLOW)  - Check $(GIT_CONFIG_FILE) for proper format$(NC)"; \
		echo "$(YELLOW)  - Ensure Git URLs are defined (GITHUB_URL, GIT_REPO_URL, etc.)$(NC)"; \
		echo "$(YELLOW)  - Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}
	@echo ""
	@echo "$(GREEN)✅ Git repository deployment complete!$(NC)"

# =============================================================================
# MCP (Model Context Protocol) Management
# =============================================================================
deploy-mcp: check-config test-connection create-dynamic-inventory ## Deploy MCP servers only (requires Claude Code)
	@echo "$(CYAN)🤖 Deploying MCP servers...$(NC)"
	@echo "$(WHITE)Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "$(WHITE)Host: $(YELLOW)$(if $(and $(filter root,$(VM_USER)),$(TARGET_USER)),$(TARGET_USER),$(VM_USER))@$(VM_HOST)$(NC)"
	@echo "$(WHITE)User: $(YELLOW)$(TARGET_USER)$(NC)"
	@echo ""
	@echo "$(WHITE)🎯 Deploying MCP servers with Ansible...$(NC)"
	@if command -v timeout >/dev/null 2>&1; then \
		timeout 600 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) --tags mcp $(ANSIBLE_CONNECTION); \
	else \
		$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) --tags mcp $(ANSIBLE_CONNECTION); \
	fi || { \
		echo "$(RED)❌ MCP deployment failed$(NC)"; \
		echo "$(YELLOW)💡 Possible issues:$(NC)"; \
		echo "$(YELLOW)  - Claude Code not installed (deploy full stack first)$(NC)"; \
		echo "$(YELLOW)  - Missing MCP configuration or environment variables$(NC)"; \
		echo "$(YELLOW)  - Network connectivity issues$(NC)"; \
		echo "$(YELLOW)🔧 Troubleshooting:$(NC)"; \
		echo "$(YELLOW)  - Run 'make deploy' for full stack first$(NC)"; \
		echo "$(YELLOW)  - Check $(ENV_FILE) and $(MCP_FILE) files$(NC)"; \
		echo "$(YELLOW)  - Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}
	@echo ""
	@echo "$(GREEN)✅ MCP servers deployed successfully!$(NC)"

deploy-claude-config: check-config test-connection create-dynamic-inventory ## Deploy CLAUDE.md and settings.json to target VM
	@echo "$(WHITE)🎯 Deploying CLAUDE configuration...$(NC)"
	@echo "$(WHITE)Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "$(WHITE)Host: $(YELLOW)$(if $(and $(filter root,$(VM_USER)),$(TARGET_USER)),$(TARGET_USER),$(VM_USER))@$(VM_HOST)$(NC)"
	@echo "$(WHITE)User: $(YELLOW)$(TARGET_USER)$(NC)"
	@if [ -n "$(CLAUDE_CONFIG_TEMPLATE)" ] && [ ! -f "$(CLAUDE_CONFIG_TEMPLATE)" ]; then \
		echo "$(RED)❌ Template file not found: $(CLAUDE_CONFIG_TEMPLATE)$(NC)"; \
		echo "$(YELLOW)💡 Available templates in config/:$(NC)"; \
		ls -1 config/CLAUDE.*.md 2>/dev/null || echo "$(YELLOW)  No CLAUDE templates found$(NC)"; \
		exit 1; \
	fi
	@# Check settings file/template
	@if [ -n "$(CLAUDE_SETTINGS_TEMPLATE)" ] && [ ! -f "$(CLAUDE_SETTINGS_TEMPLATE)" ]; then \
		echo "$(RED)❌ Settings template not found: $(CLAUDE_SETTINGS_TEMPLATE)$(NC)"; \
		echo "$(YELLOW)💡 Default template: config/claude-settings.template.json$(NC)"; \
		exit 1; \
	fi
	@if [ -n "$(CLAUDE_SETTINGS_FILE)" ] && [ "$(CLAUDE_SETTINGS_FILE)" != "config/claude-settings.json" ] && [ ! -f "$(CLAUDE_SETTINGS_FILE)" ]; then \
		echo "$(RED)❌ Settings file not found: $(CLAUDE_SETTINGS_FILE)$(NC)"; \
		echo "$(YELLOW)💡 Default: config/claude-settings.json$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@echo "$(WHITE)🎯 Deploying CLAUDE configuration with Ansible...$(NC)"
	@EXTRA_ANSIBLE_VARS="$(EXTRA_VARS)"; \
	if [ -n "$(CLAUDE_CONFIG_TEMPLATE)" ]; then \
		EXTRA_ANSIBLE_VARS="$$EXTRA_ANSIBLE_VARS claude_config_template=$(CLAUDE_CONFIG_TEMPLATE)"; \
		echo "$(WHITE)📄 Using CLAUDE.md template: $(YELLOW)$(CLAUDE_CONFIG_TEMPLATE)$(NC)"; \
	fi; \
	if [ -n "$(CLAUDE_CONFIG_FORCE_OVERRIDE)" ]; then \
		EXTRA_ANSIBLE_VARS="$$EXTRA_ANSIBLE_VARS claude_config_force_override=$(CLAUDE_CONFIG_FORCE_OVERRIDE)"; \
		echo "$(WHITE)🔄 Force override CLAUDE.md: $(YELLOW)$(CLAUDE_CONFIG_FORCE_OVERRIDE)$(NC)"; \
	fi; \
	if [ -n "$(CLAUDE_SETTINGS_TEMPLATE)" ]; then \
		EXTRA_ANSIBLE_VARS="$$EXTRA_ANSIBLE_VARS claude_settings_template=$(CLAUDE_SETTINGS_TEMPLATE)"; \
		echo "$(WHITE)📄 Using settings template: $(YELLOW)$(CLAUDE_SETTINGS_TEMPLATE)$(NC)"; \
	elif [ -n "$(CLAUDE_SETTINGS_FILE)" ] && [ "$(CLAUDE_SETTINGS_FILE)" != "config/claude-settings.json" ]; then \
		EXTRA_ANSIBLE_VARS="$$EXTRA_ANSIBLE_VARS claude_settings_template=$(CLAUDE_SETTINGS_FILE)"; \
		echo "$(WHITE)📄 Using settings file: $(YELLOW)$(CLAUDE_SETTINGS_FILE)$(NC)"; \
	fi; \
	if [ -n "$(CLAUDE_SETTINGS_FORCE_OVERRIDE)" ]; then \
		EXTRA_ANSIBLE_VARS="$$EXTRA_ANSIBLE_VARS claude_settings_force_override=$(CLAUDE_SETTINGS_FORCE_OVERRIDE)"; \
		echo "$(WHITE)🔄 Force override settings.json: $(YELLOW)$(CLAUDE_SETTINGS_FORCE_OVERRIDE)$(NC)"; \
	fi; \
	if command -v timeout >/dev/null 2>&1; then \
		timeout 300 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$$EXTRA_ANSIBLE_VARS" --tags claude-config,claude-settings $(LIMIT_FLAG) $(ANSIBLE_CONNECTION); \
	else \
		$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$$EXTRA_ANSIBLE_VARS" --tags claude-config,claude-settings $(LIMIT_FLAG) $(ANSIBLE_CONNECTION); \
	fi || { \
		echo "$(RED)❌ CLAUDE configuration deployment failed$(NC)"; \
		echo "$(YELLOW)💡 Possible issues:$(NC)"; \
		echo "$(YELLOW)  - Template files not found or invalid$(NC)"; \
		echo "$(YELLOW)  - Network connectivity issues$(NC)"; \
		echo "$(YELLOW)  - Target VM permissions$(NC)"; \
		echo "$(YELLOW)🔧 Troubleshooting:$(NC)"; \
		echo "$(YELLOW)  - Check template files exist: ls config/CLAUDE.*.md config/claude-settings.*.json$(NC)"; \
		echo "$(YELLOW)  - Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}
	@echo ""
	@echo "$(GREEN)✅ CLAUDE configuration deployed successfully!$(NC)"



# =============================================================================
# Dynamic Inventory Generation
# =============================================================================
create-dynamic-inventory: ## Create dynamic inventory for single machine deployment
	@echo "$(WHITE)📝 Creating dynamic inventory...$(NC)"
	@# Create project-specific temp directory
	@INVENTORY_DIR="$(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)"; \
	mkdir -p "$$INVENTORY_DIR"; \
	INVENTORY_FILE="$$INVENTORY_DIR/inventory.yml"; \
	DEPLOY_USER="$(if $(and $(filter root,$(VM_USER)),$(TARGET_USER)),$(TARGET_USER),$(VM_USER))"; \
	echo "---" > "$$INVENTORY_FILE"; \
	echo "all:" >> "$$INVENTORY_FILE"; \
	echo "  children:" >> "$$INVENTORY_FILE"; \
	echo "    debian_servers:" >> "$$INVENTORY_FILE"; \
	echo "      hosts:" >> "$$INVENTORY_FILE"; \
	echo "        target:" >> "$$INVENTORY_FILE"; \
	echo "          ansible_host: $(VM_HOST)" >> "$$INVENTORY_FILE"; \
	if [ -n "$(IS_LOCALHOST)" ]; then \
		echo "          ansible_connection: local" >> "$$INVENTORY_FILE"; \
		echo "          ansible_user: $(TARGET_USER)" >> "$$INVENTORY_FILE"; \
		echo "          ansible_become: no" >> "$$INVENTORY_FILE"; \
	else \
		echo "          ansible_user: $$DEPLOY_USER" >> "$$INVENTORY_FILE"; \
		if [ -n "$(TARGET_SSH_KEY)" ]; then \
			echo "          ansible_ssh_private_key_file: $(TARGET_SSH_KEY)" >> "$$INVENTORY_FILE"; \
		fi; \
		echo "          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'" >> "$$INVENTORY_FILE"; \
		echo "          ansible_become: yes" >> "$$INVENTORY_FILE"; \
		echo "          ansible_become_method: sudo" >> "$$INVENTORY_FILE"; \
	fi; \
	if [ "$(USE_BECOME_PASSWORD)" = "true" ] && [ -n "$(BECOME_PASSWORD)" ]; then \
		echo "          ansible_become_password: $(BECOME_PASSWORD)" >> "$$INVENTORY_FILE"; \
	fi; \
	echo "          ansible_python_interpreter: /usr/bin/python3" >> "$$INVENTORY_FILE"; \
	echo "          target_user: $(TARGET_USER)" >> "$$INVENTORY_FILE"; \
	echo "$(GREEN)✅ Dynamic inventory created at $$INVENTORY_FILE$(NC)"

# =============================================================================
# Setup & Initialization
# =============================================================================
setup: ## First-time setup
	@echo "$(CYAN)🚀 Setting up deployment environment...$(NC)"
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "$(YELLOW)📝 Creating environment file...$(NC)"; \
		if [ -f "config/env.example" ]; then \
			cp config/env.example $(ENV_FILE); \
		else \
			echo "# Claude Code VM Environment Configuration" > $(ENV_FILE); \
			echo "# Add your Git credentials here:" >> $(ENV_FILE); \
			echo "# GIT_SERVER_GITHUB_URL=https://github.com" >> $(ENV_FILE); \
			echo "# GIT_SERVER_GITHUB_USERNAME=yourusername" >> $(ENV_FILE); \
			echo "# GIT_SERVER_GITHUB_PAT=your_token" >> $(ENV_FILE); \
		fi; \
		echo "$(GREEN)✅ Created $(ENV_FILE)$(NC)"; \
		echo "$(YELLOW)⚠️ Please edit $(ENV_FILE) with your credentials$(NC)"; \
	fi
	@if [ ! -f "$(MCP_FILE)" ]; then \
		echo "$(YELLOW)📝 Creating MCP configuration...$(NC)"; \
		if [ -f "config/mcp-servers.template.json" ]; then \
			cp config/mcp-servers.template.json $(MCP_FILE); \
		else \
			echo '{"mcpServers":{}}' > $(MCP_FILE); \
		fi; \
		echo "$(GREEN)✅ Created $(MCP_FILE)$(NC)"; \
	fi
	@echo "$(YELLOW)📦 Downloading external dependencies...$(NC)"
	@cd ansible && ansible-playbook playbooks/download-dependencies.yml
	@echo "$(GREEN)✅ Setup complete!$(NC)"

# =============================================================================
# Utilities
# =============================================================================
clean: ## Clean up temporary files
	@echo "$(CYAN)🧹 Cleaning up...$(NC)"
	@rm -f deployment.log ansible.log *.retry
	@if [ -d "$(TEMP_BASE_PATH)/claude-code-vm" ]; then \
		rm -rf "$(TEMP_BASE_PATH)/claude-code-vm"; \
		echo "$(GREEN)✅ Removed temporary inventories at $(TEMP_BASE_PATH)/claude-code-vm$(NC)"; \
	fi
	@echo "$(GREEN)✅ Cleanup complete!$(NC)"

