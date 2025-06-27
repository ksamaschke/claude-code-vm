# CLAUDE.md - Development Environment Configuration

This file provides guidance for Claude Code when working in this development environment.

## Environment Overview

### Development Stack
- **Host OS**: {{ ansible_distribution }} {{ ansible_distribution_version }}
- **Target User**: {{ target_user }}
- **Deployment Directory**: {{ target_user_home }}

### Development Tools
- **Git**: Version control with multi-provider credential management
- **Node.js**: Latest LTS with npm global packages
- **Claude Code CLI**: Installed with MCP server integration
- **Screen**: Persistent terminal sessions

## Command Execution Policy

{% if allow_command_execution | default(true) | bool %}
### Remote Command Execution Enabled

This development environment **allows Claude Code to execute commands remotely**. The following commands can be run automatically when requested:

**System Commands:**
- `ls`, `cat`, `grep`, `find`, `tail`, `head`
- `ps`, `top`, `df`, `free`, `systemctl status`
- `git status`, `git log`, `git branch`, `git diff`
- `npm list`, `node --version`, `claude --version`

**Development Tools:**
- Node.js: `node --version`, `npm list`, `npm install`
- Claude Code: `claude --version`, `claude mcp list`
- Screen sessions: `screen -list`, `screen -r`

{% else %}
### Remote Command Execution Disabled

This development environment **does not allow Claude Code to execute commands remotely**. You will need to run commands manually and share outputs as needed.
{% endif %}

## Subagent Usage and Parallelization

### Subagent Support Configuration

This development environment **{{ 'enables' if subagent_usage | default('enabled') == 'enabled' else 'disables' }} subagent usage** for enhanced productivity and parallel task execution.

{% if subagent_usage | default('enabled') == 'enabled' %}
**Configuration:**
- Subagents are enabled for optimal performance
- Max parallel tasks: {{ max_parallel_tasks | default(4) }}
- Task coordination: {{ task_coordination | default('automatic') }}
- Can be disabled if needed for specific workflows

### When Subagents Are Most Beneficial

**Development Workflow Tasks:**
- Code analysis while preparing deployment manifests
- Documentation generation during build processes
- Test execution while performing system validation
- Git operations while updating configuration files
- Environment cleanup while preparing new deployments

**System Operations:**
- Log analysis across multiple services simultaneously
- Parallel health checks for different system components
- Concurrent file operations and system diagnostics
- Multi-service debugging and troubleshooting
{% endif %}

## Git Branch and Push Policy

### Development Workflow
- **Always create dedicated branches** for improvements and fixes
- **Never commit directly to main/master** without explicit authorization
- **Test thoroughly** before committing
- **Verify changes work** with end-to-end testing
- **Create proper commit messages** describing the change
- **Always generate proper .gitignore files** before first commit

### Required .gitignore Patterns
```gitignore
# IDE and Editor files
.vscode/
.idea/
*.swp
*.swo
*~

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Claude Code files (IMPORTANT)
CLAUDE.md
.claude/
.claude-directories

# Logs
logs
*.log

# Temporary files
tmp/
temp/
*.tmp
*.temp

# OS files
.DS_Store
Thumbs.db
```

### Branch Naming
- `feature/description` - for new features
- `fix/description` - for bug fixes
- `update/description` - for updates and improvements

### Commit Guidelines
- **Never mention Claude** in commit messages or as contributor
- **Ensure no sensitive information** is exposed in commits
- **Always include proper .gitignore** before first commit
- **Exclude Claude-related files** (CLAUDE.md, .claude directories) from commits
- **Use clear, descriptive commit messages** focusing on the "why"

### Push Policy
1. Create branch: `git checkout -b feature/my-feature`
2. Generate/update .gitignore file
3. Make changes and test thoroughly
4. Commit with clear message
5. Push branch: `git push -u origin feature/my-feature`
6. Create pull request for review
7. **Only merge to main after explicit authorization**

## Important Notes

- **Screen sessions**: Automatic screen attachment configured for persistent sessions
- **Global npm packages**: Installed to user directory, PATH configured
- **Claude Code CLI**: Available globally after installation
- **Command execution**: All commands run in the context of this development VM

## Quick Start Commands

```bash
# Check core tools
node --version
npm --version
claude --version
git --version

# List screen sessions
screen -list
```