# Screen Session Management

This document covers the screen session management system implemented in the Common role for persistent terminal sessions.

## Overview

The deployment system automatically configures persistent screen sessions that survive SSH disconnections, providing a robust development environment for remote work.

## Features

### Automatic Screen Installation

The system installs and configures GNU Screen:

```yaml
# From common role
- name: Install screen for persistent sessions
  apt:
    name: screen
    state: present
```

### Session Configuration

**Default Session Name**: `DEV` (configurable via `SESSION_NAME` variable)

**Log Directory**: `~/.claude-code-vm/logs/screen/` (in hidden deployment directory)

**Configuration Variables**:
- `screen_session_name` - Session name (default: from `custom_session_name` or `DEV`)
- `screen_logs_dir` - Log directory path (default: `{{ deployment_base_dir }}/logs/screen`)

### Automatic Session Management

The system creates a `connect-session.sh` script that:

1. **Checks Screen Availability** - Verifies screen is installed
2. **Creates Screen Configuration** - Sets up `~/.screenrc` if not present
3. **Sets Unicode Support** - Configures UTF-8 locale for proper character display
4. **Session Logic**:
   - Reattaches to existing session if available
   - Creates new session if none exists
   - Handles session detachment/reattachment automatically

### Screen Configuration

The system creates a `~/.screenrc` file with:

```bash
# Screen configuration for persistent sessions
startup_message off           # No startup message
defscrollback 10000          # 10,000 line scrollback buffer
hardstatus on                # Enable status line
hardstatus alwayslastline    # Status at bottom
hardstatus string "%-w%n %t%+w %= %H %m/%d %C%a"  # Status format
termcapinfo xterm* ti@:te@   # Terminal compatibility
defutf8 on                   # UTF-8 support
defflow off                  # No flow control
vbell off                    # No visual bell
autodetach on                # Auto-detach on hangup
```

### Automatic Attachment

The system adds automatic screen attachment to `~/.bashrc`:

```bash
# Auto-attach to screen session for SSH connections
if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$STY" ]] && [[ $- =~ i ]]; then
    if command -v screen >/dev/null 2>&1; then
        exec ~/.local/bin/connect-session.sh
    fi
fi
```

This ensures that SSH connections automatically attach to the persistent session.

## Usage

### Automatic Connection

When connecting via SSH, the system automatically:

1. Checks if screen is available
2. Creates or reattaches to the named session
3. Provides feedback about session status

### Manual Connection

Use the deployed script manually:

```bash
~/.local/bin/connect-session.sh
```

### Session Management

**List sessions**:
```bash
screen -list
```

**Detach from session**:
```bash
# Press Ctrl+A, then D
```

**Reattach to session**:
```bash
screen -r DEV
```

**Kill session**:
```bash
screen -S DEV -X quit
```

## Directory Structure

The screen session system creates:

```
~/.claude-code-vm/
├── logs/
│   └── screen/          # Screen session logs
└── scripts/
    └── connect-session.sh   # Session management script
```

## Configuration Variables

### Makefile Variables

- `SESSION_NAME` - Screen session name (default: `DEV`)
- `DEPLOYMENT_DIR` - Base deployment directory (default: `~/.claude-code-vm`)

### Ansible Variables

- `screen_session_name` - Session name from `custom_session_name` or default
- `screen_logs_dir` - Log directory path
- `deployment_base_dir` - Base directory for deployment files
- `scripts_dir` - Directory for utility scripts

## Session Behavior

### SSH Connection Flow

1. **SSH connects** to the VM
2. **Bashrc executes** and detects SSH connection
3. **Screen check** verifies screen is available
4. **Session logic**:
   - If session exists: detach others and reattach
   - If no session: create new persistent session
5. **Unicode support** is automatically configured

### Session Persistence

- Sessions survive SSH disconnections
- Sessions persist through network interruptions
- Multiple SSH connections can attach to the same session
- Session state is maintained between connections

### Unicode Support

The system configures proper UTF-8 support:

```bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
```

## Customization

### Custom Session Name

Set custom session name via Makefile:

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer SESSION_NAME=MyProject
```

### Custom Deployment Directory

Override the base directory:

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer DEPLOYMENT_DIR=/custom/path
```

### Disable Auto-attachment

Modify `~/.bashrc` to comment out the auto-attachment block if needed.

## Troubleshooting

### Screen Not Available

If screen is not installed, the connect script falls back to regular shell:

```bash
Error: screen is not installed. Please install it with: sudo apt install screen
Falling back to regular shell...
```

### Session Issues

**List all sessions**:
```bash
screen -list
```

**Force detach and reattach**:
```bash
screen -d DEV
screen -r DEV
```

**Remove dead sessions**:
```bash
screen -wipe
```

### Unicode Issues

The system automatically sets UTF-8 locale. If characters display incorrectly:

```bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
```

## Integration with Development Workflow

The screen session system integrates with:

- **Docker containers** - Run containers within persistent sessions
- **Kubernetes tools** - kubectl commands persist across disconnections  
- **Node.js development** - npm processes continue after SSH disconnection
- **Git operations** - Long-running git operations survive network issues
- **Claude Code CLI** - AI interactions persist in the session

This screen session management provides a robust foundation for remote development work with automatic session handling and UTF-8 support.