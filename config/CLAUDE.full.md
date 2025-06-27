<!-- INCLUDE: config/CLAUDE.containerized.md -->

## Deployment Tier: Full (with Kubernetes)

This is a **full deployment** that adds Kubernetes orchestration capabilities.

{% set has_k3s = install_k3s | default(false) %}
{% set has_kind = install_kind | default(false) %}
{% set has_kubernetes = has_k3s or has_kind %}

### Full Deployment Components
{% if has_k3s %}
- **Kubernetes Runtime**: k3s (lightweight Kubernetes)
- **k3s Version**: Latest stable
- **Ingress Controller**: {{ 'NGINX Ingress Controller' if install_nginx_ingress else 'Traefik' if k3s_ingress_controller == 'traefik' else 'None' }}
- **Kubeconfig**: `{{ k3s_user_kubeconfig_path }}`
- **Container Runtime**: containerd (via k3s) + Docker (for development)
{% elif has_kind %}
- **Kubernetes Runtime**: KIND (Kubernetes in Docker)
- **KIND**: Kubernetes in Docker for local development
- **Kubeconfig**: `~/.kube/config`
- **Container Runtime**: Docker (for both development and Kubernetes)
{% else %}
- **Kubernetes Runtime**: Available for installation
- **Options**: k3s or KIND
- **Container Runtime**: Docker available
{% endif %}

### Available Components Status Override
- **Docker**: {{ 'Installed with Kubernetes support' if has_kubernetes else 'Installed (basic)' }}
- **Kubernetes**: {{ 'Installed (' + ('k3s' if has_k3s else 'KIND' if has_kind else 'None') + ')' }}
- **MCP Servers**: {{ 'Configured' if mcp_servers_deployed | default(false) else 'Not configured' }}

### Container & Orchestration
{% if install_k3s %}
- **k3s/containerd**: Used by Kubernetes for container orchestration  
- **Docker**: Available for development, Docker Compose, image building
- **Coexistence**: Docker for dev workflows, k3s for Kubernetes workloads
{% elif install_kind %}
- **KIND/Docker**: Uses Docker for both development and Kubernetes
{% endif %}

### Kubernetes Commands
{% if install_k3s %}
- `k3s kubectl get nodes`, `k3s kubectl get pods -A`
- `k3s kubectl logs`, `k3s kubectl describe`, `k3s kubectl port-forward`
- `k3s kubectl apply`, `k3s kubectl delete` (for development resources)
{% elif install_kind %}
- `kubectl get nodes`, `kubectl get pods -A`
- `kubectl logs`, `kubectl describe`, `kubectl port-forward`
- `kind get clusters`, `kind load docker-image`
{% endif %}

### Kubernetes Aliases
```bash
{% if install_k3s %}
alias k='k3s kubectl'
alias kubectl='k3s kubectl'
{% else %}
alias k=kubectl
{% endif %}
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
```

### Build and Deployment Processes

**Container Image Builds:**
{% if install_k3s %}
```bash
# Build and deploy to k3s cluster
docker build -t myapp:latest .
k3s ctr images import myapp-latest.tar
kubectl apply -f k8s-manifests/
```
{% elif install_kind %}
```bash
# Build and load into KIND cluster
docker build -t myapp:latest .
kind load docker-image myapp:latest
kubectl apply -f k8s-manifests/
```
{% endif %}

**Port Forwarding for Development:**
```bash
# Forward service ports for local access
kubectl port-forward service/myapp 8080:80
kubectl port-forward pod/myapp-pod 8080:8080

# Access services via Ingress (if configured)
curl http://localhost/myapp
```

### Use Cases
- Kubernetes application development
- Microservices with service mesh
- Cloud-native application testing
- CI/CD pipeline development
- Production-like development environments

This full environment provides complete container orchestration capabilities for enterprise-grade development.