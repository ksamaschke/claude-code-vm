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

.PHONY: help deploy deploy-mcp deploy-screen validate clean setup

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
SESSION_NAME ?= KS
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

# Ansible configuration
ANSIBLE_PLAYBOOK := ansible-playbook
PLAYBOOK_DIR := ansible/playbooks
LIMIT_FLAG := $(if $(filter single,$(DEPLOY_TARGET)),--limit target,--limit $(DEPLOY_TARGET))
EXTRA_VARS := vm_host=$(VM_HOST) vm_user=$(VM_USER) target_vm_user=$(TARGET_USER) remote_deployment_dir=$(DEPLOYMENT_DIR) custom_session_name=$(SESSION_NAME)

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
	EXTRA_VARS += custom_mcp_file=$(MCP_FILE)
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

# =============================================================================
# Main Deployment Commands
# =============================================================================
deploy: check-config ## Deploy complete development stack
	@echo "$(CYAN)🚀 Deploying complete development stack...$(NC)"
	@echo "$(WHITE)Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "$(WHITE)Host: $(YELLOW)$(VM_USER)@$(VM_HOST)$(NC)"
	@echo "$(WHITE)User: $(YELLOW)$(TARGET_USER)$(NC)"
	@echo "$(WHITE)Deployment Dir: $(YELLOW)$(DEPLOYMENT_DIR)$(NC)"
	@$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG)
	@echo ""
	@echo "$(GREEN)✅ Deployment complete!$(NC)"

deploy-mcp: check-config ## Deploy MCP servers only
	@echo "$(CYAN)🔌 Deploying MCP servers...$(NC)"
	@echo "$(WHITE)Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "$(WHITE)Env File: $(YELLOW)$(ENV_FILE)$(NC)"
	@echo "$(WHITE)MCP File: $(YELLOW)$(MCP_FILE)$(NC)"
	@$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags mcp -e "$(EXTRA_VARS)" $(LIMIT_FLAG)
	@echo ""
	@echo "$(GREEN)✅ MCP deployment complete!$(NC)"

deploy-screen: check-config ## Deploy screen session management
	@echo "$(CYAN)📺 Deploying screen sessions...$(NC)"
	@echo "$(WHITE)Target: $(YELLOW)$(DEPLOY_TARGET)$(NC)"
	@echo "$(WHITE)Session Name: $(YELLOW)$(SESSION_NAME)$(NC)"
	@$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags screen,session-management -e "$(EXTRA_VARS)" $(LIMIT_FLAG)
	@echo ""
	@echo "$(GREEN)✅ Screen sessions deployed!$(NC)"

# =============================================================================
# Component-specific Deployments
# =============================================================================
deploy-git: check-config ## Deploy Git configuration only
	@echo "$(CYAN)🔐 Deploying Git configuration...$(NC)"
	@$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags git -e "$(EXTRA_VARS)" $(LIMIT_FLAG)

deploy-docker: check-config ## Deploy Docker only
	@echo "$(CYAN)🐳 Deploying Docker...$(NC)"
	@$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags docker -e "$(EXTRA_VARS)" $(LIMIT_FLAG)

deploy-nodejs: check-config ## Deploy Node.js only
	@echo "$(CYAN)📦 Deploying Node.js...$(NC)"
	@$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags nodejs -e "$(EXTRA_VARS)" $(LIMIT_FLAG)

deploy-k8s: check-config ## Deploy Kubernetes tools only
	@echo "$(CYAN)☸️ Deploying Kubernetes tools...$(NC)"
	@$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/site.yml --tags kubernetes -e "$(EXTRA_VARS)" $(LIMIT_FLAG)

# =============================================================================
# Validation & Testing
# =============================================================================
validate: check-config ## Validate deployed components
	@echo "$(CYAN)✅ Validating deployment...$(NC)"
	@$(ANSIBLE_PLAYBOOK) $(PLAYBOOK_DIR)/validate.yml -e "$(EXTRA_VARS)" $(LIMIT_FLAG)

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
	@ansible $(DEPLOY_TARGET) -m ping -e "$(EXTRA_VARS)" $(LIMIT_FLAG) || { \
		echo "$(RED)❌ Cannot reach target $(DEPLOY_TARGET)$(NC)"; \
		echo "$(YELLOW)💡 Check VM_HOST, SSH keys, and network connectivity$(NC)"; \
		exit 1; \
	}

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