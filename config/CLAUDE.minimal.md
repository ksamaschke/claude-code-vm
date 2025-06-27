<!-- INCLUDE: config/CLAUDE.common.md -->

## Deployment Tier: Minimal

This is a **minimal deployment** focused on essential development tools without containerization or orchestration.

### Installed Components
- **Git**: Version control with credential management  
- **Node.js**: {{ nodejs_version }} LTS with npm
- **Claude Code**: Latest version from npm
- **Basic Shell Tools**: curl, wget, jq, etc.

### Available Components
- **Docker**: Not installed in minimal tier
- **Kubernetes**: Not available in minimal tier
- **MCP Servers**: {{ 'Configured' if mcp_servers_deployed | default(false) else 'Not configured' }}

### Development Workflow
1. **Git Operations**: Clone, commit, push with stored credentials
2. **Node.js Development**: npm install, run scripts, manage packages  
3. **Claude Code**: AI-assisted development and automation
4. **File Management**: Basic editing and manipulation

### Deployment Characteristics
- Lightweight installation
- Essential tools only (Git, Node.js, Claude Code)
- No container runtime overhead
- Suitable for basic development tasks

### Use Cases
- Simple Node.js development
- Git repository management
- Basic Claude Code operations
- Lightweight environments with limited resources

This minimal environment provides the core tools needed for Claude Code operation without additional complexity.