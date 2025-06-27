<!-- INCLUDE: config/CLAUDE.enhanced.md -->

## Deployment Tier: Containerized

This is a **containerized deployment** that adds Docker Compose and advanced shell configurations.

{% set has_docker_compose = docker_compose_installed | default(false) %}
{% set has_advanced_shell = install_docker_with_k3s | default(false) %}

### Containerized Components
{% if has_docker_compose and has_advanced_shell %}
- **Docker Compose**: Multi-container application management
- **Shell Enhancements**: Advanced bash configurations and aliases
- **Container Orchestration**: Full Docker Compose workflows
{% elif has_docker_compose %}
- **Docker Compose**: Multi-container application management
- **Container Orchestration**: Docker Compose workflows
- **Shell Enhancements**: Basic configurations
{% else %}
- **Docker Compose**: Available for installation
- **Shell Enhancements**: Standard configurations
{% endif %}

### Available Components Status Override  
- **Docker**: {{ 'Installed with Compose support' if has_docker_compose else 'Installed (basic)' }}
- **Kubernetes**: Not available in containerized tier
- **MCP Servers**: {{ 'Configured' if mcp_servers_deployed | default(false) else 'Not configured' }}

{% if has_docker_compose %}
### Docker Compose Workflows
```bash
# Multi-container application management
docker compose up -d          # Start all services
docker compose down           # Stop all services  
docker compose logs -f        # View logs
docker compose ps             # List services
docker compose exec <service> # Execute in service
docker compose build         # Build all services
docker compose pull          # Pull latest images
```

### Advanced Docker Commands
```bash
# Multi-container development
docker compose up --build    # Rebuild and start
docker compose restart       # Restart services
docker compose stop          # Stop without removing
docker compose rm            # Remove stopped containers
```
{% endif %}

{% if has_advanced_shell %}
### Enhanced Shell Aliases
```bash
# Extended Docker aliases
alias dcu='docker compose up -d'
alias dcd='docker compose down'  
alias dcl='docker compose logs -f'
alias dcb='docker compose build'
alias dce='docker compose exec'
alias dcp='docker compose ps'

# System monitoring
alias htop='htop -C'
alias df='df -h'
alias du='du -h'
```
{% endif %}

### Container Development Workflow
1. **Multi-Container Setup**: Define services in `docker-compose.yml`
2. **Service Orchestration**: `docker compose up -d` for all services
3. **Development Iteration**: 
   - Modify code (auto-reload if configured)
   - `docker compose build` for changes
   - `docker compose restart service-name` for specific services
4. **Debugging**: `docker compose logs service-name` and `docker compose exec`
5. **Cleanup**: `docker compose down` and `docker system prune`

### Advanced Features
{% if has_docker_compose %}
- Container health checks and readiness probes
- Multi-stage builds for optimized images
- Docker network isolation and service discovery
- Volume-based development with hot reloading
- Service scaling: `docker compose up --scale web=3`
- Environment-specific configurations
{% else %}
- Basic container management
- Single-container workflows
- Manual service coordination
{% endif %}

### Use Cases
{% if has_docker_compose %}
- Full-stack application development
- Microservices architecture with service mesh
- Database-backed applications with persistence
- Complex multi-container setups
- Development environment standardization
- CI/CD pipeline testing
{% else %}
- Basic containerized development
- Single-service applications
- Container workflow learning
{% endif %}

This containerized environment is ideal for {{ 'complex application development with multiple interdependent services' if has_docker_compose else 'container-based development workflows' }}.