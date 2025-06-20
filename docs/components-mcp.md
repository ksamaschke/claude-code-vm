# MCP Servers Configuration

Complete guide to Model Context Protocol (MCP) server configuration for enhanced Claude Code functionality.

## What are MCP Servers?

Model Context Protocol (MCP) servers are external tools that extend Claude Code with specialized capabilities. They run as separate processes and communicate with Claude Code via a standardized protocol.

**MCP Deployment**: This system uses the [claude-code-mcp-management](https://github.com/ksamaschke/claude-code-mcp-management) external project to handle MCP server installation and configuration. This specialized tool provides:

- **Flexible configuration management** with custom file paths
- **Environment variable substitution** using `${VARIABLE_NAME}` syntax
- **User and project-scoped installations** for different use cases
- **VM deployment capabilities** for remote server management
- **JSON-based reliable installation** using Claude Code's `mcp add-json` command

### Key Benefits
- **Real-time Data Access** - Web search, APIs, databases
- **External Tool Integration** - File processing, browser automation
- **Persistent Memory** - Remember context across sessions
- **Specialized Functions** - Domain-specific tools and integrations

## Available MCP Servers

### 🔍 Search Providers
- **Brave Search** - Fast, privacy-focused web search
- **Tavily** - AI-optimized search with summarization
- **Kagi** - Premium search with enhanced results
- **Perplexity** - AI-powered search and answers
- **Jina AI** - Semantic search capabilities

### 🧠 Memory and Storage
- **Memory Server** - Persistent memory across Claude Code sessions
- **Context7** - Advanced context management with Upstash Redis

### 📄 Document Processing
- **Doc Forge** - Comprehensive document processing
  - PDF reading, merging, splitting
  - Word document conversion
  - Excel file processing
  - HTML cleaning and conversion
  - Text formatting and encoding

### 🌐 Browser Automation
- **Puppeteer** - Full browser automation capabilities
  - Web scraping and interaction
  - Screenshot generation
  - Form filling and navigation
  - Dynamic content extraction

### 🔧 Development Tools
- **Sequential Thinking** - Enhanced reasoning and problem-solving
- **GitHub Integration** - Repository management and code analysis
- **GitLab Integration** - Project management and CI/CD

## Configuration Methods

### 1. Automatic Configuration (Recommended)

The system automatically configures MCP servers based on API keys in your `.env` file:

```bash
# Add to .env file
BRAVE_API_KEY="your_brave_api_key"
TAVILY_API_KEY="your_tavily_api_key"
UPSTASH_REDIS_REST_URL="https://your-redis-url.upstash.io"
UPSTASH_REDIS_REST_TOKEN="your_redis_token"
```

**How it works**:
1. System downloads/uses the latest [claude-code-mcp-management](https://github.com/ksamaschke/claude-code-mcp-management) tool
2. Copies your local `.env` and `mcp-servers.json` files to the target VM
3. External tool performs environment variable substitution using `${VARIABLE_NAME}` syntax
4. Installs MCP servers using Claude Code's reliable `mcp add-json` command
5. Supports both user-scope (global) and project-scope installations

### 2. Manual Configuration

Create `mcp-servers.json` in project root:

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "your_api_key"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "puppeteer": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "--init",
        "mcp/puppeteer"
      ]
    }
  }
}
```

## API Key Setup

### Brave Search
1. Visit [Brave Search API](https://api.search.brave.com/)
2. Sign up and get API key
3. Add to `.env`: `BRAVE_API_KEY="your_key"`

### Tavily
1. Visit [Tavily](https://tavily.com/)
2. Create account and get API key
3. Add to `.env`: `TAVILY_API_KEY="your_key"`

### Context7 (Upstash Redis)
1. Create [Upstash](https://upstash.com/) account
2. Create Redis database
3. Get REST URL and token
4. Add to `.env`:
   ```bash
   UPSTASH_REDIS_REST_URL="https://your-db.upstash.io"
   UPSTASH_REDIS_REST_TOKEN="your_token"
   ```

### Kagi Search
1. Subscribe to [Kagi](https://kagi.com/)
2. Get API key from settings
3. Add to `.env`: `KAGI_API_KEY="your_key"`

### Perplexity
1. Get [Perplexity API](https://www.perplexity.ai/settings/api) access
2. Generate API key
3. Add to `.env`: `PERPLEXITY_API_KEY="your_key"`

## Deployment Options

### Deploy All MCP Servers
```bash
# Deploy to target VM with default configuration
make deploy-mcp VM_HOST=your.ip TARGET_USER=user
```

### Deploy with Custom Configuration
```bash
# Use external configuration files
make deploy-mcp VM_HOST=your.ip TARGET_USER=user \
    ENV_FILE=/secure/configs/production.env \
    MCP_FILE=/secure/configs/production-mcp.json
```

### Advanced Deployment Options

The deployed claude-code-mcp-management tool supports advanced operations on the target VM:

```bash
# After deployment, you can SSH to the VM and use:
ssh user@your.ip
cd ~/.claude-code-vm/claude-code-mcp-management

# List current MCP servers
make list

# Add specific servers
make add SERVERS=memory,brave-search

# Sync all servers from configuration
make sync

# Preview changes without applying
make dry-run

# Use external configuration files on the VM
make sync CONFIG_FILE=/path/to/custom.json ENV_FILE=/path/to/custom.env
```

### Component-Only Deployment
```bash
# Deploy everything except MCP
make deploy VM_HOST=your.ip TARGET_USER=user
# Then add MCP later
make deploy-mcp VM_HOST=your.ip TARGET_USER=user
```

## Security Considerations

### API Key Protection
- **Never commit** `.env` files to version control
- **Use separate API keys** for each environment (dev/staging/prod)
- **Rotate keys regularly** and update deployment
- **Limit API key permissions** to minimum required

### Network Security
- MCP servers run locally on target VM
- **No external API calls** from your development machine
- All communication encrypted via Claude Code protocol
- **API keys stored encrypted** on target VM only

### Access Control
- MCP servers only accessible to target user
- **No cross-user access** to MCP configurations
- Separate configurations per VM/environment

## Troubleshooting

### MCP Server Not Available
```bash
# Check if MCP servers are running
ssh user@vm '~/.npm-global/bin/claude --mcp-status'

# Restart Claude Code to reload MCP configuration
ssh user@vm '~/.npm-global/bin/claude --restart'
```

### API Key Issues
```bash
# Verify API keys are configured
ssh user@vm 'cat ~/.config/claude-code/mcp-servers.json'

# Test specific MCP server
ssh user@vm '~/.npm-global/bin/claude --test-mcp brave-search'
```

### Docker-based MCP Servers
```bash
# Check if Docker images are available
ssh user@vm 'docker images | grep mcp'

# Pull MCP Docker images manually
ssh user@vm 'docker pull mcp/puppeteer'
```

### Configuration Validation
```bash
# Validate MCP configuration syntax
make validate-mcp VM_HOST=your.ip TARGET_USER=user

# Check deployment logs
ssh user@vm 'tail -f ~/.claude-code-vm/logs/mcp-deployment.log'
```

## Advanced Configuration

### Custom MCP Servers
Add your own MCP server to the configuration:

```json
{
  "mcpServers": {
    "my-custom-server": {
      "command": "node",
      "args": ["/path/to/my-mcp-server.js"],
      "env": {
        "MY_API_KEY": "secret_key",
        "DEBUG": "true"
      }
    }
  }
}
```

### Environment-Specific Configuration
```bash
# Production environment
ENV_FILE=.env.production make deploy-mcp VM_HOST=prod.ip TARGET_USER=webapp

# Development environment  
ENV_FILE=.env.dev make deploy-mcp VM_HOST=dev.ip TARGET_USER=developer
```

### Selective MCP Server Deployment
Edit `mcp-servers.json` to include only desired servers:

```json
{
  "mcpServers": {
    "brave-search": { "..." },
    "memory": { "..." }
    // Remove servers you don't want
  }
}
```

### Using External Configuration Files

The deployment system supports custom paths for environment and MCP configuration files, enabling separation of configurations across different environments and better security practices.

#### Configuration Variables

- **ENV_FILE**: Path to environment file (default: `.env`)
- **MCP_FILE**: Path to MCP servers configuration (default: `mcp-servers.json`)

#### Common Use Cases

**Production Environment with Separate Configs:**
```bash
# Use production-specific environment and MCP configuration
make deploy-mcp VM_HOST=prod.example.com TARGET_USER=webapp \
    ENV_FILE=/secure/configs/production.env \
    MCP_FILE=/secure/configs/production-mcp.json
```

**Development with Shared Team Configuration:**
```bash
# Use shared team environment file with custom MCP setup
make deploy-mcp VM_HOST=dev.local TARGET_USER=developer \
    ENV_FILE=/team/shared/dev-team.env \
    MCP_FILE=~/.config/my-custom-mcp.json
```

**Security-Focused Deployment:**
```bash
# Keep sensitive files outside project directory
make deploy-mcp VM_HOST=secure.internal TARGET_USER=service \
    ENV_FILE=/etc/claude-code/secrets.env \
    MCP_FILE=/etc/claude-code/mcp-servers.json
```

#### Configuration File Structure

**External Environment File Example:**
```bash
# /secure/configs/production.env
GIT_SERVER_GITHUB_URL="https://github.com"
GIT_SERVER_GITHUB_USERNAME="prod-bot"
GIT_SERVER_GITHUB_PAT="prod_token_here"

BRAVE_API_KEY="production_brave_key"
TAVILY_API_KEY="production_tavily_key"
UPSTASH_REDIS_REST_URL="https://prod-redis.upstash.io"
UPSTASH_REDIS_REST_TOKEN="prod_redis_token"
```

**External MCP Configuration Example:**
```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    },
    "memory": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

**Note**: The claude-code-mcp-management tool uses `${VARIABLE_NAME}` syntax (not `{{ }}`) for environment variable substitution.

#### Benefits of External Configuration

- **Environment Separation**: Different configs for dev/staging/production
- **Security**: Keep sensitive files outside version control
- **Team Collaboration**: Share environment files without exposing personal tokens
- **Compliance**: Meet security requirements for credential storage
- **Flexibility**: Override defaults without modifying project files

#### File Path Resolution

- **Relative paths** are relative to the project root
- **Absolute paths** can reference any accessible location
- **Tilde expansion** (`~`) is supported for user home directory
- **Environment variables** in paths are expanded (e.g., `$HOME/configs/.env`)

#### Integration with claude-code-mcp-management

The external [claude-code-mcp-management](https://github.com/ksamaschke/claude-code-mcp-management) tool provides advanced capabilities:

**Configuration Management**:
- **Custom file paths**: Supports CONFIG_FILE and ENV_FILE variables
- **Environment variable substitution**: Uses `${VARIABLE_NAME}` syntax in MCP configurations
- **Flexible deployment**: Can deploy to local machine or remote VMs
- **Dual-scope support**: User-scope (global) and project-scope installations

**Advanced Features**:
- **Dry-run mode**: Preview changes before applying them
- **Batch operations**: Add/remove multiple servers simultaneously 
- **JSON validation**: Ensures configuration syntax is correct
- **Cleanup functionality**: Removes orphaned servers automatically
- **VM deployment**: Deploy MCP configurations to remote VMs via SSH/Ansible

**Deployment Capabilities**:
- **Single VM deployment**: Direct SSH with `VM=user@host` syntax
- **Group deployment**: Deploy to multiple VMs using Ansible inventory
- **SSH configuration hierarchy**: Command line → .env → Ansible inventory
- **Flexible deployment directories**: Configurable target paths

## Performance Optimization

### Resource Management
- **Limit concurrent MCP servers** for resource-constrained VMs
- **Use Docker limits** for containerized MCP servers
- **Monitor memory usage** of MCP processes

### Caching
- **Enable MCP response caching** where supported
- **Use Redis-based MCP servers** for shared caching
- **Configure TTL** for cached responses

### Network Optimization
- **Use local MCP servers** when possible
- **Batch API requests** through MCP servers
- **Configure API rate limits** appropriately

## Next Steps

- **[Authentication Guide](authentication.md)** - Secure API key management
- **[Configuration Guide](configuration.md)** - Advanced configuration options
- **[Troubleshooting](troubleshooting.md)** - Common issues and solutions