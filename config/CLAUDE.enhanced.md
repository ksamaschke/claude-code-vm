<!-- INCLUDE: config/CLAUDE.minimal.md -->

## Deployment Tier: Enhanced

This is an **enhanced deployment** that builds upon the minimal tier with MCP servers and Docker support.

{% set is_docker_available = install_docker_with_k3s | default(false) or install_docker | default(false) %}
{% set is_mcp_available = mcp_servers_deployed | default(false) %}

### Enhanced Components
{% if is_docker_available and is_mcp_available %}
- **Docker**: Installed with full container support
- **MCP Servers**: 11 pre-configured AI-enhanced servers
- **Container Runtime**: Docker CE for development workflows
{% elif is_docker_available %}
- **Docker**: Installed with full container support  
- **Container Runtime**: Docker CE for development workflows
- **MCP Servers**: Not configured in this deployment
{% elif is_mcp_available %}
- **MCP Servers**: 11 pre-configured AI-enhanced servers
- **Docker**: Not installed in this deployment
{% else %}
- **Docker**: Available but not installed
- **MCP Servers**: Available but not configured
{% endif %}

### Available Components Status Override
{% if is_docker_available or is_mcp_available %}
- **Docker**: {{ 'Installed' if is_docker_available else 'Not installed' }}
- **Kubernetes**: Not available in enhanced tier
- **MCP Servers**: {{ 'Configured' if is_mcp_available else 'Not configured' }}
{% endif %}

{% if is_mcp_available %}
### MCP Servers Included
- **Search/Web**: brave-search, github, gitlab-public
- **AI Tools**: memory, sequential-thinking, Context7  
- **Documents**: doc-forge, pdf-reader, document-operations
- **Automation**: puppeteer, puppeteer-docker

### AI-Enhanced Development
- Context-aware code assistance
- Automated web interactions
- Document processing workflows
- Memory-based development sessions
- Sequential task planning
{% endif %}

{% if is_docker_available %}
### Docker Commands Available
- `docker ps`, `docker images`, `docker logs`
- `docker build`, `docker run`, `docker exec`
- `docker compose up`, `docker compose down`, `docker compose logs`

**Docker Aliases:**
```bash
alias d=docker  
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'
```

### Container Development Workflow
1. **Image Building**: `docker build -t myapp .`
2. **Container Running**: `docker run -d -p 8080:80 myapp`
3. **Development**: `docker exec -it container_name bash`
4. **Compose Orchestration**: `docker compose up -d`
{% endif %}

### Use Cases
{% if is_docker_available and is_mcp_available %}
- AI-enhanced container development
- Microservices with intelligent automation
- Document processing in containerized workflows
- Web scraping and automation pipelines
{% elif is_docker_available %}
- Container-based development
- Microservices development
- Containerized application deployment
{% elif is_mcp_available %}
- AI-enhanced development workflows
- Intelligent code assistance
- Document processing and automation
- Context-aware development sessions
{% else %}
- Enhanced development environment setup
- Preparation for container and AI workflows
{% endif %}

This enhanced environment provides {{ 'Docker and MCP' if is_docker_available and is_mcp_available else 'Docker' if is_docker_available else 'MCP' if is_mcp_available else 'enhanced' }} capabilities for advanced development workflows.