# MCP Servers Configuration

Complete guide to Model Context Protocol (MCP) server configuration for enhanced Claude Code functionality.

## What are MCP Servers?

Model Context Protocol (MCP) servers are external tools that extend Claude Code with specialized capabilities. They run as separate processes and communicate with Claude Code via a standardized protocol.

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
1. System scans `.env` for known API key patterns
2. Only configures MCP servers with valid API keys
3. Automatically generates `mcp-servers.json` configuration
4. Deploys encrypted credentials to target VM

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
make deploy-mcp VM_HOST=your.ip TARGET_USER=user
```

### Deploy with Custom Configuration
```bash
make deploy-mcp VM_HOST=your.ip TARGET_USER=user \
    ENV_FILE=/path/to/production.env \
    MCP_FILE=/path/to/custom-mcp.json
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