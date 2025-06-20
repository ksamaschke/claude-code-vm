# =============================================================================
# Claude Code VM Deployment Makefile
# =============================================================================
# 
# Configurable deployment system for Claude Code development environments
# 
# Usage Examples:
#   make deploy                                    # Deploy with defaults
#   make deploy VM_HOST=192.168.1.100             # Custom VM host
#   make deploy-mcp ENV_FILE=/path/to/.env         # Custom env file
#   make deploy-mcp MCP_FILE=/path/to/mcp.json     # Custom MCP config
#   make deploy TARGET_USER=myuser                 # Custom target user
#
# =============================================================================

.PHONY: help deploy deploy-mcp deploy-screen validate dry-run clean setup setup-mcp-tool generate-mcp-config

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

# Authentication settings (optional)
CONNECT_AS_TARGET ?= false
TARGET_SSH_KEY ?= 
USE_SSH_PASSWORD ?= false
SSH_PASSWORD ?= 
USE_BECOME_PASSWORD ?= false
BECOME_PASSWORD ?= 

# Deployment target (single machine vs group)
DEPLOY_TARGET ?= single

# File paths (can be overridden)
ENV_FILE ?= .env
MCP_FILE ?= mcp-servers.json
SSH_KEY ?= ~/.ssh/id_rsa
TEMP_BASE_PATH ?= .tmp

# Ansible configuration
ANSIBLE_PLAYBOOK := ansible-playbook
PLAYBOOK_DIR := ansible/playbooks
LIMIT_FLAG := $(if $(filter single,$(DEPLOY_TARGET)),--limit target,--limit $(DEPLOY_TARGET))
EXTRA_VARS := vm_host=$(VM_HOST) vm_user=$(if $(and $(filter root,$(VM_USER)),$(TARGET_USER)),$(TARGET_USER),$(VM_USER)) target_vm_user=$(TARGET_USER) remote_deployment_dir=$(DEPLOYMENT_DIR) custom_session_name=$(SESSION_NAME)

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

# =============================================================================
# Help & Information
# =============================================================================
help: ## Show this help message
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                    Claude Code VM Deployment System                       ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)📋 Available Commands:$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { \
		printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 \
	}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(WHITE)🎯 Configuration Variables:$(NC)"
	@echo "  $(YELLOW)VM_HOST$(NC)         Target VM IP address (REQUIRED)"
	@echo "  $(YELLOW)VM_USER$(NC)         SSH user for deployment (default: $(VM_USER))"
	@echo "  $(YELLOW)TARGET_USER$(NC)     Target user on VM (REQUIRED)"
	@echo "  $(YELLOW)DEPLOY_TARGET$(NC)   Deployment target: single/production/staging (default: $(DEPLOY_TARGET))"
	@echo "  $(YELLOW)ENV_FILE$(NC)        Environment file path (default: $(ENV_FILE))"
	@echo "  $(YELLOW)MCP_FILE$(NC)        MCP servers config file (default: $(MCP_FILE))"
	@echo "  $(YELLOW)SESSION_NAME$(NC)    Screen session name (default: $(SESSION_NAME))"
	@echo "  $(YELLOW)DEPLOYMENT_DIR$(NC)  Remote deployment directory (default: $(DEPLOYMENT_DIR))"
	@echo "  $(YELLOW)TEMP_BASE_PATH$(NC)  Temporary files base directory (default: $(TEMP_BASE_PATH))"
	@echo ""
	@echo "$(WHITE)🔐 Authentication Options:$(NC)"
	@echo "  $(YELLOW)CONNECT_AS_TARGET$(NC)    Connect directly as target user (default: $(CONNECT_AS_TARGET))"
	@echo "  $(YELLOW)TARGET_SSH_KEY$(NC)       SSH key for target user (optional)"
	@echo "  $(YELLOW)USE_SSH_PASSWORD$(NC)     Use password instead of key (default: $(USE_SSH_PASSWORD))"
	@echo "  $(YELLOW)SSH_PASSWORD$(NC)         SSH password (if USE_SSH_PASSWORD=true)"
	@echo "  $(YELLOW)USE_BECOME_PASSWORD$(NC)  Sudo requires password (default: $(USE_BECOME_PASSWORD))"
	@echo "  $(YELLOW)BECOME_PASSWORD$(NC)      Sudo password (if USE_BECOME_PASSWORD=true)"
	@echo ""
	@echo "$(WHITE)📝 Usage Examples:$(NC)"
	@echo "  $(CYAN)# Single machine deployment (most common):$(NC)"
	@echo "  $(CYAN)make deploy VM_HOST=192.168.1.100 TARGET_USER=developer$(NC)"
	@echo "  $(CYAN)make deploy-mcp VM_HOST=10.0.1.5 TARGET_USER=user ENV_FILE=/path/to/.env$(NC)"
	@echo ""
	@echo "  $(CYAN)# Authentication variations:$(NC)"
	@echo "  $(CYAN)make deploy VM_HOST=10.0.1.5 TARGET_USER=dev CONNECT_AS_TARGET=true$(NC)"
	@echo "  $(CYAN)make deploy VM_HOST=10.0.1.5 TARGET_USER=dev TARGET_SSH_KEY=~/.ssh/dev_key$(NC)"
	@echo "  $(CYAN)make deploy VM_HOST=10.0.1.5 TARGET_USER=dev USE_SSH_PASSWORD=true SSH_PASSWORD=secret$(NC)"
	@echo "  $(CYAN)make deploy VM_HOST=10.0.1.5 TARGET_USER=dev USE_BECOME_PASSWORD=true BECOME_PASSWORD=sudo123$(NC)"
	@echo ""
	@echo "  $(CYAN)# Group deployment (multiple machines):$(NC)"
	@echo "  $(CYAN)make deploy DEPLOY_TARGET=production$(NC)"
	@echo "  $(CYAN)make deploy DEPLOY_TARGET=staging$(NC)"
	@echo ""
	@echo "  $(CYAN)# Custom temporary directory:$(NC)"
	@echo "  $(CYAN)make deploy VM_HOST=10.0.1.5 TARGET_USER=dev TEMP_BASE_PATH=/tmp$(NC)"
	@echo "  $(CYAN)make deploy VM_HOST=10.0.1.5 TARGET_USER=dev TEMP_BASE_PATH=~/tmp$(NC)"

# =============================================================================
# Main Deployment Commands
# =============================================================================
deploy: check-config test-connection create-dynamic-inventory ## Deploy complete development stack
	@echo "$(CYAN)🚀 Deploying complete development stack...$(NC)"
	@echo "$(WHITE)Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "$(WHITE)Host: $(YELLOW)$(if $(and $(filter root,$(VM_USER)),$(TARGET_USER)),$(TARGET_USER),$(VM_USER))@$(VM_HOST)$(NC)"
	@echo "$(WHITE)User: $(YELLOW)$(TARGET_USER)$(NC)"
	@echo "$(WHITE)Deployment Dir: $(YELLOW)$(DEPLOYMENT_DIR)$(NC)"
	@echo ""
	@echo "$(WHITE)🎯 Starting Ansible deployment with timeout protection...$(NC)"
	@timeout 1800 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Deployment failed or timed out$(NC)"; \
		echo "$(YELLOW)💡 Possible issues:$(NC)"; \
		echo "$(YELLOW)  - VM became unreachable during deployment$(NC)"; \
		echo "$(YELLOW)  - Network connectivity issues$(NC)"; \
		echo "$(YELLOW)  - Deployment took longer than 30 minutes$(NC)"; \
		echo "$(YELLOW)🔧 Troubleshooting:$(NC)"; \
		echo "$(YELLOW)  - Run 'make test-connection' to verify VM status$(NC)"; \
		echo "$(YELLOW)  - Check VM resources (disk space, memory)$(NC)"; \
		echo "$(YELLOW)  - Review deployment logs for specific errors$(NC)"; \
		exit 1; \
	}
	@echo ""
	@echo "$(GREEN)✅ Deployment complete!$(NC)"

deploy-mcp: check-config test-connection setup-mcp-tool deploy-claude ## Deploy MCP servers only (requires Claude Code)
	@echo "$(CYAN)🔌 Deploying MCP servers using claude-code-mcp-management...$(NC)"
	@DEPLOY_USER="$(if $(and $(filter root,$(VM_USER)),$(TARGET_USER)),$(TARGET_USER),$(VM_USER))"; \
	SSH_OPTS="-o StrictHostKeyChecking=no"; \
	if [ -n "$(TARGET_SSH_KEY)" ]; then \
		SSH_OPTS="$$SSH_OPTS -i $(TARGET_SSH_KEY)"; \
	fi; \
	echo "$(WHITE)Target: $(YELLOW)$$DEPLOY_USER@$(VM_HOST)$(NC)"; \
	echo "$(WHITE)Env File: $(YELLOW)$(ENV_FILE)$(NC)"; \
	echo "$(WHITE)MCP File: $(YELLOW)$(MCP_FILE)$(NC)"; \
	echo "$(WHITE)SSH Options: $(YELLOW)$$SSH_OPTS$(NC)"; \
	echo ""; \
	echo "$(WHITE)🎯 Step 1: Installing dependencies on VM...$(NC)"; \
	ssh $$SSH_OPTS $$DEPLOY_USER@$(VM_HOST) 'sudo apt update && sudo apt install -y pipx && pipx install uv && pipx ensurepath && echo "uv installed via pipx"'; \
	echo ""; \
	echo "$(WHITE)🎯 Step 2: Creating deployment directory...$(NC)"; \
	ssh $$SSH_OPTS $$DEPLOY_USER@$(VM_HOST) 'mkdir -p /home/'$$DEPLOY_USER'/mcp-manager'; \
	echo ""; \
	echo "$(WHITE)🎯 Step 3: Copying tool files to VM...$(NC)"; \
	rsync -avz --exclude='.git' --exclude='__pycache__' --exclude='*.pyc' -e "ssh $$SSH_OPTS" tools/claude-code-mcp-management/ $$DEPLOY_USER@$(VM_HOST):/home/$$DEPLOY_USER/mcp-manager/; \
	echo ""; \
	echo "$(WHITE)🎯 Step 4: Copying configuration files to VM...$(NC)"; \
	scp $$SSH_OPTS $(MCP_FILE) $$DEPLOY_USER@$(VM_HOST):/home/$$DEPLOY_USER/mcp-manager/mcp-servers.json; \
	scp $$SSH_OPTS $(ENV_FILE) $$DEPLOY_USER@$(VM_HOST):/home/$$DEPLOY_USER/mcp-manager/.env; \
	echo ""; \
	echo "$(WHITE)🎯 Step 5: Setting execute permissions on scripts...$(NC)"; \
	ssh $$SSH_OPTS $$DEPLOY_USER@$(VM_HOST) 'chmod +x /home/'$$DEPLOY_USER'/mcp-manager/scripts/*.sh'; \
	echo ""; \
	echo "$(WHITE)🎯 Step 6: Running dependency check on the VM...$(NC)"; \
	ssh $$SSH_OPTS $$DEPLOY_USER@$(VM_HOST) 'cd /home/'$$DEPLOY_USER'/mcp-manager && export PATH="/home/'$$DEPLOY_USER'/.local/bin:/home/'$$DEPLOY_USER'/.npm-global/bin:$$PATH" && export LC_ALL=C.UTF-8 && export LANG=C.UTF-8 && make check || echo "Dependencies check completed with warnings"'; \
	echo ""; \
	echo "$(WHITE)🎯 Step 7: Running MCP sync on the VM...$(NC)"; \
	ssh $$SSH_OPTS $$DEPLOY_USER@$(VM_HOST) 'cd /home/'$$DEPLOY_USER'/mcp-manager && export PATH="/home/'$$DEPLOY_USER'/.local/bin:/home/'$$DEPLOY_USER'/.npm-global/bin:$$PATH" && export LC_ALL=C.UTF-8 && export LANG=C.UTF-8 && make sync CONFIG_FILE=/home/'$$DEPLOY_USER'/mcp-manager/mcp-servers.json ENV_FILE=/home/'$$DEPLOY_USER'/mcp-manager/.env SCOPE=user'; \
	echo ""; \
	echo "$(GREEN)✅ MCP deployment complete!$(NC)"

deploy-screen: check-config test-connection create-dynamic-inventory ## Deploy screen session management
	@echo "$(CYAN)📺 Deploying screen sessions...$(NC)"
	@echo "$(WHITE)Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "$(WHITE)Session Name: $(YELLOW)$(SESSION_NAME)$(NC)"
	@timeout 300 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags screen,session-management -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Screen deployment failed$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}
	@echo ""
	@echo "$(GREEN)✅ Screen sessions deployed!$(NC)"

# =============================================================================
# Component-specific Deployments
# =============================================================================
deploy-git: check-config test-connection create-dynamic-inventory ## Deploy Git configuration only
	@echo "$(CYAN)🔐 Deploying Git configuration...$(NC)"
	@timeout 300 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags git -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Git deployment failed$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}

deploy-docker: check-config test-connection create-dynamic-inventory ## Deploy Docker only
	@echo "$(CYAN)🐳 Deploying Docker...$(NC)"
	@timeout 600 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags docker -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Docker deployment failed$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}

deploy-nodejs: check-config test-connection create-dynamic-inventory ## Deploy Node.js only
	@echo "$(CYAN)📦 Deploying Node.js...$(NC)"
	@timeout 600 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags nodejs -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Node.js deployment failed$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}

deploy-claude: check-config test-connection create-dynamic-inventory ## Deploy Claude Code only
	@echo "$(CYAN)🤖 Deploying Claude Code...$(NC)"
	@timeout 600 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags claude-code -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Claude Code deployment failed$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}

deploy-k8s: check-config test-connection create-dynamic-inventory ## Deploy Kubernetes tools only
	@echo "$(CYAN)☸️ Deploying Kubernetes tools...$(NC)"
	@timeout 600 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags kubernetes -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Kubernetes deployment failed$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}

# =============================================================================
# Validation & Testing
# =============================================================================
validate: check-config test-connection create-dynamic-inventory ## Validate deployed components
	@echo "$(CYAN)✅ Validating deployment...$(NC)"
	@timeout 300 $(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/validate.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Validation failed$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' to verify VM status$(NC)"; \
		exit 1; \
	}

dry-run: check-config create-dynamic-inventory ## Perform dry-run of deployment without making changes
	@echo "$(CYAN)🔍 Performing dry-run deployment...$(NC)"
	@echo "$(WHITE)Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "$(WHITE)Host: $(YELLOW)$(if $(and $(filter root,$(VM_USER)),$(TARGET_USER)),$(TARGET_USER),$(VM_USER))@$(VM_HOST)$(NC)"
	@echo "$(WHITE)User: $(YELLOW)$(TARGET_USER)$(NC)"
	@echo ""
	@echo "$(WHITE)🎯 Running Ansible dry-run (check mode)...$(NC)"
	@$(ANSIBLE_PLAYBOOK) --check --diff $(PLAYBOOK_DIR)/site.yml -i $(TEMP_BASE_PATH)/claude-code-vm/$(VM_HOST)/inventory.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Dry-run failed - configuration issues detected$(NC)"; \
		echo "$(YELLOW)💡 Review the output above for undefined variables or other issues$(NC)"; \
		exit 1; \
	}
	@echo ""
	@echo "$(GREEN)✅ Dry-run completed successfully!$(NC)"
	@echo "$(WHITE)No undefined variables or configuration issues detected$(NC)"

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
	@echo "$(WHITE)🎯 Testing connectivity to $(VM_HOST)...$(NC)"
	@# Determine which user to use for SSH connection
	@TEST_USER="$(VM_USER)"; \
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
	if timeout 10 bash -c "</dev/tcp/$(VM_HOST)/22" 2>/dev/null; then \
		echo "$(GREEN)✅ SSH port 22 is open on $(VM_HOST)$(NC)"; \
	else \
		echo "$(RED)❌ SSH port 22 is not accessible on $(VM_HOST)$(NC)"; \
		echo "$(YELLOW)💡 Possible issues:$(NC)"; \
		echo "$(YELLOW)  - VM is not running$(NC)"; \
		echo "$(YELLOW)  - Firewall blocking SSH (port 22)$(NC)"; \
		echo "$(YELLOW)  - SSH service not running$(NC)"; \
		echo "$(YELLOW)  - Wrong IP address$(NC)"; \
		exit 1; \
	fi; \
	echo ""; \
	echo "$(WHITE)🎯 Step 3: Testing SSH authentication...$(NC)"; \
	SSH_CMD="ssh -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=no"; \
	if [ -n "$(TARGET_SSH_KEY)" ]; then \
		SSH_CMD="$$SSH_CMD -i $(TARGET_SSH_KEY)"; \
	fi; \
	SSH_CMD="$$SSH_CMD $$TEST_USER@$(VM_HOST) echo connection-test-successful"; \
	if timeout 15 $$SSH_CMD 2>/dev/null | grep -q "connection-test-successful"; then \
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
	if timeout 15 $$SSH_CMD 2>/dev/null | grep -q "root"; then \
		echo "$(GREEN)✅ Sudo access confirmed (passwordless)$(NC)"; \
	elif [ "$(USE_BECOME_PASSWORD)" = "true" ] && [ -n "$(BECOME_PASSWORD)" ]; then \
		echo "$(GREEN)✅ Sudo password provided for deployment$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ Sudo access requires password$(NC)"; \
		echo "$(YELLOW)💡 Add USE_BECOME_PASSWORD=true BECOME_PASSWORD=your_sudo_password$(NC)"; \
	fi; \
	echo ""; \
	echo "$(GREEN)✅ Connectivity test completed successfully!$(NC)"; \
	echo "$(WHITE)Ready to deploy to $(YELLOW)$$TEST_USER@$(VM_HOST)$(NC)"

test-ansible: ## Test Ansible connectivity with proper timeout
	@echo "$(WHITE)🔍 Testing Ansible connectivity...$(NC)"
	@timeout 30 ansible $(DEPLOY_TARGET) -m ping -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Ansible connection failed$(NC)"; \
		echo "$(YELLOW)💡 Run 'make test-connection' for detailed diagnostics$(NC)"; \
		exit 1; \
	}
	@echo "$(GREEN)✅ Ansible connectivity confirmed$(NC)"

# =============================================================================
# MCP Tool Setup (Local)
# =============================================================================
setup-mcp-tool: ## Setup claude-code-mcp-management tool locally
	@echo "$(WHITE)🔧 Setting up claude-code-mcp-management tool locally...$(NC)"
	@if [ ! -d "tools/claude-code-mcp-management" ]; then \
		echo "$(YELLOW)📥 Downloading claude-code-mcp-management...$(NC)"; \
		mkdir -p tools; \
		cd tools && git clone https://github.com/ksamaschke/claude-code-mcp-management.git; \
		echo "$(GREEN)✅ Downloaded claude-code-mcp-management$(NC)"; \
	else \
		echo "$(GREEN)✅ claude-code-mcp-management already available$(NC)"; \
	fi

generate-mcp-config: setup-mcp-tool ## Generate MCP configuration locally
	@echo "$(WHITE)🔧 Generating MCP configuration locally...$(NC)"
	@cd tools/claude-code-mcp-management && \
		make sync CONFIG_FILE=../../$(MCP_FILE) ENV_FILE=../../$(ENV_FILE) SCOPE=user --dry-run
	@echo "$(GREEN)✅ MCP configuration generated$(NC)"

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
	echo "          ansible_user: $$DEPLOY_USER" >> "$$INVENTORY_FILE"; \
	if [ -n "$(TARGET_SSH_KEY)" ]; then \
		echo "          ansible_ssh_private_key_file: $(TARGET_SSH_KEY)" >> "$$INVENTORY_FILE"; \
	fi; \
	echo "          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'" >> "$$INVENTORY_FILE"; \
	echo "          ansible_become: yes" >> "$$INVENTORY_FILE"; \
	echo "          ansible_become_method: sudo" >> "$$INVENTORY_FILE"; \
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

info: ## Show current configuration
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                        Current Configuration                              ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)🎯 Target Configuration:$(NC)"
	@echo "  Deploy Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "  VM Host: $(if $(VM_HOST),$(YELLOW)$(VM_HOST)$(NC),$(RED)NOT SET (required)$(NC))"
	@echo "  VM User: $(YELLOW)$(VM_USER)$(NC)"
	@echo "  Target User: $(if $(TARGET_USER),$(YELLOW)$(TARGET_USER)$(NC),$(RED)NOT SET (required)$(NC))"
	@echo "  Deployment Dir: $(YELLOW)$(DEPLOYMENT_DIR)$(NC)"
	@echo ""
	@echo "$(WHITE)📁 File Configuration:$(NC)"
	@echo "  Environment File: $(if $(shell test -f $(ENV_FILE) && echo "exists"),$(GREEN)✅ $(ENV_FILE)$(NC),$(RED)❌ $(ENV_FILE) (missing)$(NC))"
	@echo "  MCP Config File: $(if $(shell test -f $(MCP_FILE) && echo "exists"),$(GREEN)✅ $(MCP_FILE)$(NC),$(YELLOW)⚠️ $(MCP_FILE) (will use template)$(NC))"
	@echo "  Screen Session: $(YELLOW)$(SESSION_NAME)$(NC)"