# =============================================================================
# Ansible Debian Stack Makefile
# =============================================================================
# 
# Simplified commands for deploying and managing the development stack
# 
# Usage: make <target>
# Example: make deploy-git
#          make validate
#          make help
#
# =============================================================================

.PHONY: help setup check deploy validate clean debug

# Default target
.DEFAULT_GOAL := help

# Variables
PLAYBOOK_DIR := playbooks
INVENTORY := inventories/production
ENV_FILE := .env
ENV_EXAMPLE := .env.example

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[1;37m
NC := \033[0m # No Color

# =============================================================================
# Help & Information
# =============================================================================

help: ## Show this help message
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                      Ansible Debian Stack Makefile                        ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)📋 Available Commands:$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { \
		printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 \
	}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(WHITE)🚀 Quick Start:$(NC)"
	@echo "  $(YELLOW)make setup$(NC)          # First-time setup"
	@echo "  $(YELLOW)make deploy$(NC)         # Deploy complete stack"
	@echo "  $(YELLOW)make validate$(NC)       # Validate deployment"
	@echo ""
	@echo "$(WHITE)🎯 Component Deployment:$(NC)"
	@echo "  $(YELLOW)make deploy-git$(NC)     # Deploy Git configuration only"
	@echo "  $(YELLOW)make deploy-docker$(NC)  # Deploy Docker only"
	@echo "  $(YELLOW)make deploy-k8s$(NC)     # Deploy Kubernetes tools only"
	@echo "  $(YELLOW)make deploy-mcp$(NC)     # Deploy MCP servers for Claude Code"
	@echo ""
	@echo "$(WHITE)🔧 Maintenance:$(NC)"
	@echo "  $(YELLOW)make update-pats$(NC)    # Update Git Personal Access Tokens"
	@echo "  $(YELLOW)make debug$(NC)          # Debug deployment issues"

info: ## Show system information
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                           System Information                              ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)📁 Project Structure:$(NC)"
	@echo "  Current Directory: $(YELLOW)$$(pwd)$(NC)"
	@echo "  Playbook Directory: $(YELLOW)$(PLAYBOOK_DIR)$(NC)"
	@echo "  Inventory: $(YELLOW)$(INVENTORY)$(NC)"
	@echo ""
	@echo "$(WHITE)📄 Configuration Files:$(NC)"
	@echo "  Environment File: $(if $(shell test -f $(ENV_FILE) && echo "exists"),$(GREEN)✅ $(ENV_FILE)$(NC),$(RED)❌ $(ENV_FILE) (missing)$(NC))"
	@echo "  Example File: $(if $(shell test -f $(ENV_EXAMPLE) && echo "exists"),$(GREEN)✅ $(ENV_EXAMPLE)$(NC),$(RED)❌ $(ENV_EXAMPLE) (missing)$(NC))"
	@echo "  Ansible Config: $(if $(shell test -f ansible.cfg && echo "exists"),$(GREEN)✅ ansible.cfg$(NC),$(RED)❌ ansible.cfg (missing)$(NC))"
	@echo ""
	@echo "$(WHITE)🔧 Dependencies:$(NC)"
	@echo "  Ansible: $(if $(shell command -v ansible-playbook 2>/dev/null),$(GREEN)✅ $$(ansible-playbook --version | head -1)$(NC),$(RED)❌ Not installed$(NC))"
	@echo "  SSH: $(if $(shell command -v ssh 2>/dev/null),$(GREEN)✅ Available$(NC),$(RED)❌ Not available$(NC))"

status: ## Show deployment status
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                          Deployment Status                                ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)🔗 Target Connection:$(NC)"
	@ansible debian-vm -m ping 2>/dev/null && echo "  $(GREEN)✅ VM is reachable$(NC)" || echo "  $(RED)❌ VM is not reachable$(NC)"
	@echo ""
	@echo "$(WHITE)📊 Git Servers in .env:$(NC)"
	@if [ -f $(ENV_FILE) ]; then \
		git_servers=$$(grep "^GIT_SERVER_.*_URL=" $(ENV_FILE) | wc -l); \
		if [ $$git_servers -gt 0 ]; then \
			echo "  $(GREEN)✅ $$git_servers Git servers configured$(NC)"; \
			grep "^GIT_SERVER_.*_URL=" $(ENV_FILE) | sed 's/GIT_SERVER_//g' | sed 's/_URL=.*//g' | sed 's/^/    - /' | sed "s/^/$(YELLOW)/g" | sed "s/$$/$(NC)/g"; \
		else \
			echo "  $(YELLOW)⚠️ No Git servers configured$(NC)"; \
		fi; \
	else \
		echo "  $(RED)❌ .env file not found$(NC)"; \
	fi

# =============================================================================
# Setup & Prerequisites
# =============================================================================

setup: ## First-time setup (copy .env template, check dependencies)
	@echo "$(CYAN)🚀 Setting up Ansible Debian Stack...$(NC)"
	@echo ""
	@echo "$(WHITE)📋 Checking prerequisites...$(NC)"
	@command -v ansible-playbook >/dev/null 2>&1 || { echo "$(RED)❌ Ansible not found. Please install Ansible first.$(NC)"; exit 1; }
	@echo "  $(GREEN)✅ Ansible found$(NC)"
	@echo ""
	@echo "$(WHITE)📄 Setting up configuration files...$(NC)"
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "  $(YELLOW)📝 Creating .env from template...$(NC)"; \
		cp $(ENV_EXAMPLE) $(ENV_FILE); \
		echo "  $(GREEN)✅ Created $(ENV_FILE)$(NC)"; \
		echo "  $(YELLOW)⚠️ Please edit $(ENV_FILE) with your Git credentials$(NC)"; \
	else \
		echo "  $(GREEN)✅ $(ENV_FILE) already exists$(NC)"; \
	fi
	@echo ""
	@echo "$(WHITE)🔗 Testing target connection...$(NC)"
	@ansible debian-vm -m ping 2>/dev/null && echo "  $(GREEN)✅ Target VM is reachable$(NC)" || echo "  $(YELLOW)⚠️ Target VM is not reachable (check hosts.yml)$(NC)"
	@echo ""
	@echo "$(GREEN)✅ Setup complete!$(NC)"
	@echo ""
	@echo "$(WHITE)📝 Next steps:$(NC)"
	@echo "  1. Edit $(YELLOW)$(ENV_FILE)$(NC) with your Git credentials"
	@echo "  2. Run $(YELLOW)make check$(NC) to validate configuration"
	@echo "  3. Run $(YELLOW)make deploy$(NC) to start deployment"

check-env: ## Check if .env file exists and has required variables
	@echo "$(WHITE)🔍 Checking .env file...$(NC)"
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(RED)❌ .env file not found. Run 'make setup' first.$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✅ .env file found$(NC)"
	@if ! grep -q "GIT_USER_NAME=" $(ENV_FILE) || ! grep -q "GIT_USER_EMAIL=" $(ENV_FILE); then \
		echo "$(YELLOW)⚠️ Git identity not configured in .env$(NC)"; \
	else \
		echo "$(GREEN)✅ Git identity configured$(NC)"; \
	fi
	@git_servers=$$(grep "^GIT_SERVER_.*_URL=" $(ENV_FILE) | wc -l); \
	if [ $$git_servers -gt 0 ]; then \
		echo "$(GREEN)✅ $$git_servers Git servers configured$(NC)"; \
	else \
		echo "$(YELLOW)⚠️ No Git servers configured$(NC)"; \
	fi

# =============================================================================
# Validation & Testing
# =============================================================================

check: check-env ## Validate Ansible syntax and configuration
	@echo "$(CYAN)🔍 Running configuration checks...$(NC)"
	@echo ""
	@echo "$(WHITE)📝 Ansible syntax check...$(NC)"
	@ansible-playbook --syntax-check $(PLAYBOOK_DIR)/site.yml && echo "$(GREEN)✅ Syntax is valid$(NC)" || { echo "$(RED)❌ Syntax errors found$(NC)"; exit 1; }
	@echo ""
	@echo "$(WHITE)🔗 Connection test...$(NC)"
	@ansible debian-vm -m ping && echo "$(GREEN)✅ Target VM is reachable$(NC)" || { echo "$(RED)❌ Cannot reach target VM$(NC)"; exit 1; }
	@echo ""
	@echo "$(GREEN)✅ All checks passed!$(NC)"

dry-run: check ## Perform dry run (show what would change without applying)
	@echo "$(CYAN)🧪 Performing dry run...$(NC)"
	@ansible-playbook --check --diff $(PLAYBOOK_DIR)/site.yml

dry-run-git: check ## Dry run for Git configuration only
	@echo "$(CYAN)🧪 Performing Git dry run...$(NC)"
	@ansible-playbook --check --diff $(PLAYBOOK_DIR)/site.yml --tags git

validate: ## Validate deployed components
	@echo "$(CYAN)✅ Validating deployment...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/validate.yml

validate-git: ## Validate Git configuration only
	@echo "$(CYAN)✅ Validating Git configuration...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/validate.yml --tags git

validate-docker: ## Validate Docker installation only
	@echo "$(CYAN)✅ Validating Docker installation...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/validate.yml --tags docker

validate-k8s: ## Validate Kubernetes tools only
	@echo "$(CYAN)✅ Validating Kubernetes tools...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/validate.yml --tags kubernetes

validate-mcp: ## Validate MCP server configuration
	@echo "$(CYAN)✅ Validating MCP configuration...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/validate.yml --tags mcp

# =============================================================================
# Deployment Commands
# =============================================================================

deploy: check ## Deploy complete development stack
	@echo "$(CYAN)🚀 Deploying complete development stack...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml
	@echo ""
	@echo "$(GREEN)✅ Deployment complete!$(NC)"
	@echo "$(WHITE)Run $(YELLOW)make validate$(NC) to verify the deployment"

deploy-git: check ## Deploy Git configuration and credential management only
	@echo "$(CYAN)🔐 Deploying Git configuration...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags git
	@echo ""
	@echo "$(GREEN)✅ Git deployment complete!$(NC)"
	@echo "$(WHITE)Run $(YELLOW)make validate-git$(NC) to verify Git configuration"

deploy-docker: check ## Deploy Docker and Docker Compose only
	@echo "$(CYAN)🐳 Deploying Docker...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags docker
	@echo ""
	@echo "$(GREEN)✅ Docker deployment complete!$(NC)"
	@echo "$(WHITE)Run $(YELLOW)make validate-docker$(NC) to verify Docker installation"

deploy-nodejs: check ## Deploy Node.js and npm only
	@echo "$(CYAN)📦 Deploying Node.js...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags nodejs
	@echo ""
	@echo "$(GREEN)✅ Node.js deployment complete!$(NC)"

deploy-claude: check ## Deploy Claude Code CLI only
	@echo "$(CYAN)🤖 Deploying Claude Code...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags claude-code
	@echo ""
	@echo "$(GREEN)✅ Claude Code deployment complete!$(NC)"

deploy-k8s: check ## Deploy Kubernetes tools (kubectl, kind, kompose) only
	@echo "$(CYAN)☸️ Deploying Kubernetes tools...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags kubernetes
	@echo ""
	@echo "$(GREEN)✅ Kubernetes tools deployment complete!$(NC)"
	@echo "$(WHITE)Run $(YELLOW)make validate-k8s$(NC) to verify Kubernetes tools"

deploy-mcp: check-env ## Deploy MCP servers for Claude Code
	@echo "$(CYAN)🔌 Deploying MCP servers...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags mcp
	@echo ""
	@echo "$(GREEN)✅ MCP servers deployment complete!$(NC)"
	@echo "$(WHITE)Run $(YELLOW)make validate-mcp$(NC) to verify MCP configuration"

# =============================================================================
# Maintenance & Updates
# =============================================================================

update-pats: check-env ## Update Git Personal Access Tokens from .env file
	@echo "$(CYAN)🔄 Updating Git Personal Access Tokens...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags credentials,pats
	@echo ""
	@echo "$(GREEN)✅ PATs updated!$(NC)"

update-git: ## Update Git configuration completely
	@echo "$(CYAN)🔄 Updating Git configuration...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags git
	@echo ""
	@echo "$(GREEN)✅ Git configuration updated!$(NC)"

update-mcp: check-env ## Update MCP server configuration and API keys
	@echo "$(CYAN)🔄 Updating MCP configuration...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags mcp
	@echo ""
	@echo "$(GREEN)✅ MCP configuration updated!$(NC)"

update-versions: ## Update package versions (edit group_vars/all.yml first)
	@echo "$(CYAN)🔄 Updating package versions...$(NC)"
	@echo "$(YELLOW)⚠️ Make sure you've updated versions in inventories/production/group_vars/all.yml$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml
	@echo ""
	@echo "$(GREEN)✅ Versions updated!$(NC)"

# =============================================================================
# Debugging & Troubleshooting
# =============================================================================

debug: ## Debug deployment issues with verbose output
	@echo "$(CYAN)🔍 Running debug mode...$(NC)"
	@echo ""
	@echo "$(WHITE)📋 System Information:$(NC)"
	@make info
	@echo ""
	@echo "$(WHITE)📊 Status Check:$(NC)"
	@make status
	@echo ""
	@echo "$(WHITE)🔗 Testing connection with verbose output:$(NC)"
	@ansible debian-vm -m ping -vvv

debug-git: check ## Debug Git configuration with verbose output
	@echo "$(CYAN)🔍 Debugging Git configuration...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags git -vvv

debug-env: ## Debug .env file parsing
	@echo "$(CYAN)🔍 Debugging .env file parsing...$(NC)"
	@ansible-playbook $(PLAYBOOK_DIR)/site.yml --tags env-file -v

test-connection: ## Test SSH connection to target VM
	@echo "$(CYAN)🔗 Testing connection to target VM...$(NC)"
	@ansible debian-vm -m ping

test-git-config: ## Show current Git configuration on target VM
	@echo "$(CYAN)🔍 Checking Git configuration on target VM...$(NC)"
	@ansible debian-vm -m shell -a "git config --global --list" --become-user ksamaschke

test-git-servers: check-env ## Test Git server connectivity
	@echo "$(CYAN)🔗 Testing Git server connectivity...$(NC)"
	@if [ -f $(ENV_FILE) ]; then \
		echo "$(WHITE)📊 Configured Git servers:$(NC)"; \
		grep "^GIT_SERVER_.*_URL=" $(ENV_FILE) | while read line; do \
			server_id=$$(echo $$line | sed 's/GIT_SERVER_//g' | sed 's/_URL=.*//g'); \
			url=$$(echo $$line | sed 's/.*=//g' | tr -d '"'); \
			echo "  Testing $$server_id: $$url"; \
			ansible debian-vm -m shell -a "git ls-remote $$url" --become-user ksamaschke 2>/dev/null && echo "    $(GREEN)✅ Accessible$(NC)" || echo "    $(RED)❌ Not accessible$(NC)"; \
		done; \
	else \
		echo "$(RED)❌ .env file not found$(NC)"; \
	fi

# =============================================================================
# Cleanup & Reset
# =============================================================================

clean: ## Clean up temporary files and logs
	@echo "$(CYAN)🧹 Cleaning up...$(NC)"
	@rm -f ansible.log
	@rm -f *.retry
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✅ Cleanup complete!$(NC)"

reset-env: ## Reset .env file to template (WARNING: overwrites existing .env)
	@echo "$(RED)⚠️ This will overwrite your existing .env file!$(NC)"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "$(YELLOW)Cancelled.$(NC)"; exit 1; }
	@cp $(ENV_EXAMPLE) $(ENV_FILE)
	@echo "$(GREEN)✅ .env file reset to template$(NC)"
	@echo "$(YELLOW)⚠️ Please edit $(ENV_FILE) with your credentials$(NC)"

# =============================================================================
# Documentation & Examples
# =============================================================================

examples: ## Show usage examples
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                              Usage Examples                                ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)🚀 First-time setup:$(NC)"
	@echo "  $(YELLOW)make setup$(NC)                    # Initial setup and .env creation"
	@echo "  $(YELLOW)nano .env$(NC)                     # Edit with your Git credentials"
	@echo "  $(YELLOW)make check$(NC)                    # Validate configuration"
	@echo "  $(YELLOW)make deploy$(NC)                   # Deploy complete stack"
	@echo ""
	@echo "$(WHITE)🎯 Component-specific deployment:$(NC)"
	@echo "  $(YELLOW)make deploy-git$(NC)               # Deploy Git + credential management"
	@echo "  $(YELLOW)make deploy-docker$(NC)            # Deploy Docker + Docker Compose"
	@echo "  $(YELLOW)make deploy-k8s$(NC)               # Deploy kubectl + kind + kompose"
	@echo ""
	@echo "$(WHITE)🔧 Maintenance:$(NC)"
	@echo "  $(YELLOW)make update-pats$(NC)              # Update Git Personal Access Tokens"
	@echo "  $(YELLOW)make validate$(NC)                 # Verify deployment"
	@echo "  $(YELLOW)make test-git-config$(NC)          # Check Git configuration"
	@echo ""
	@echo "$(WHITE)🔍 Troubleshooting:$(NC)"
	@echo "  $(YELLOW)make debug$(NC)                    # Debug deployment issues"
	@echo "  $(YELLOW)make test-connection$(NC)          # Test VM connectivity"
	@echo "  $(YELLOW)make dry-run$(NC)                  # See what would change"

env-template: ## Show .env file template structure
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                            .env File Template                             ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)📄 Basic .env file structure:$(NC)"
	@echo ""
	@echo "$(YELLOW)# Git Identity$(NC)"
	@echo "GIT_USER_NAME=\"Your Full Name\""
	@echo "GIT_USER_EMAIL=\"your.email@example.com\""
	@echo ""
	@echo "$(YELLOW)# GitHub$(NC)"
	@echo "GIT_SERVER_GITHUB_URL=\"https://github.com\""
	@echo "GIT_SERVER_GITHUB_USERNAME=\"your-username\""
	@echo "GIT_SERVER_GITHUB_PAT=\"ghp_your_token_here\""
	@echo ""
	@echo "$(YELLOW)# Company GitLab$(NC)"
	@echo "GIT_SERVER_COMPANY_GITLAB_URL=\"https://gitlab.company.com\""
	@echo "GIT_SERVER_COMPANY_GITLAB_USERNAME=\"your-company-user\""
	@echo "GIT_SERVER_COMPANY_GITLAB_PAT=\"glpat-company_token\""
	@echo ""
	@echo "$(WHITE)💡 To add more Git servers, just follow the pattern:$(NC)"
	@echo "$(GREEN)GIT_SERVER_{UNIQUE_ID}_URL=\"https://git.server.com\"$(NC)"
	@echo "$(GREEN)GIT_SERVER_{UNIQUE_ID}_USERNAME=\"username\"$(NC)"
	@echo "$(GREEN)GIT_SERVER_{UNIQUE_ID}_PAT=\"token\"$(NC)"

# =============================================================================
# Development & Advanced
# =============================================================================

list-tags: ## List all available Ansible tags
	@echo "$(CYAN)🏷️ Available Ansible tags:$(NC)"
	@grep -r "tags:" roles/ | grep -o "\- [a-zA-Z0-9_-]*" | sort -u | sed 's/^- /  /' | sed "s/^/$(YELLOW)/g" | sed "s/$$/$(NC)/g"

ansible-shell: ## Open Ansible shell for ad-hoc commands
	@echo "$(CYAN)💻 Ansible Shell Mode$(NC)"
	@echo "$(WHITE)Examples:$(NC)"
	@echo "  ansible debian-vm -m shell -a 'docker --version'"
	@echo "  ansible debian-vm -m shell -a 'git config --global --list' --become-user ksamaschke"
	@echo ""
	@echo "$(YELLOW)Type your ansible command (or 'exit' to quit):$(NC)"
	@while true; do \
		read -p "ansible> " cmd; \
		if [ "$$cmd" = "exit" ]; then break; fi; \
		if [ -n "$$cmd" ]; then eval "ansible $$cmd"; fi; \
	done

version: ## Show project and tool versions
	@echo "$(CYAN)📋 Version Information$(NC)"
	@echo ""
	@echo "$(WHITE)Project:$(NC)"
	@echo "  Ansible Debian Stack: $(YELLOW)v2.0.0$(NC)"
	@echo ""
	@echo "$(WHITE)Tools:$(NC)"
	@ansible --version | head -1 | sed "s/^/  /" | sed "s/ansible/$(YELLOW)Ansible:$(NC)/g"
	@python3 --version 2>/dev/null | sed "s/^/  /" | sed "s/Python/$(YELLOW)Python:$(NC)/g" || echo "  $(RED)Python: Not found$(NC)"
	@echo ""
	@echo "$(WHITE)Target Versions (configured):$(NC)"
	@grep -E "(nodejs_version|gcm_version|kubernetes_version)" inventories/production/group_vars/all.yml | sed "s/^/  /" | sed "s/:/: $(YELLOW)/g" | sed "s/$$/$(NC)/g"

# =============================================================================
# Special Targets
# =============================================================================

.env: $(ENV_EXAMPLE) ## Create .env from template if it doesn't exist
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(YELLOW)📝 Creating .env from template...$(NC)"; \
		cp $(ENV_EXAMPLE) $(ENV_FILE); \
		echo "$(GREEN)✅ Created $(ENV_FILE)$(NC)"; \
		echo "$(YELLOW)⚠️ Please edit $(ENV_FILE) with your Git credentials$(NC)"; \
	fi

# Prevent make from treating files as targets
%: 
	@: