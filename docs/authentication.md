# Authentication Guide

This document covers the authentication methods and variables supported by the Claude Code VM deployment system as implemented in the Makefile.

## Authentication Variables

### Required Variables
- `VM_HOST` - Target VM IP address or hostname
- `TARGET_USER` - Username on target VM for deployment

### Connection Variables
- `VM_USER` - SSH connection user (default: `root`)
- `CONNECT_AS_TARGET` - Connect directly as target user (default: `false`)

### SSH Authentication Variables
- `TARGET_SSH_KEY` - Path to SSH private key (optional)
- `USE_SSH_PASSWORD` - Use password authentication (default: `false`)
- `SSH_PASSWORD` - SSH password (required when USE_SSH_PASSWORD=true)

### Privilege Escalation Variables
- `USE_BECOME_PASSWORD` - Require sudo password (default: `false`)
- `BECOME_PASSWORD` - Sudo password (required when USE_BECOME_PASSWORD=true)

## Authentication Methods

### Default: Root SSH Key Authentication

Connect as root using SSH key, then configure target user.

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer
```

This uses:
- `VM_USER=root` (default)
- SSH key authentication (system default key)
- Passwordless sudo

### Direct Target User Connection

Connect directly as the target user.

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer CONNECT_AS_TARGET=true
```

This connects directly as `developer` without privilege escalation.

### Custom SSH Key

Use a specific SSH key for authentication.

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer TARGET_SSH_KEY=~/.ssh/custom_key
```

### SSH Password Authentication

Use password instead of SSH key.

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer USE_SSH_PASSWORD=true SSH_PASSWORD=mypassword
```

### Sudo with Password

Require password for sudo operations.

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer USE_BECOME_PASSWORD=true BECOME_PASSWORD=sudopass
```

### Combined Authentication Methods

Use both SSH password and sudo password.

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer \
    USE_SSH_PASSWORD=true SSH_PASSWORD=sshpass \
    USE_BECOME_PASSWORD=true BECOME_PASSWORD=sudopass
```

Connect as non-root user with custom key and sudo password.

```bash
make deploy VM_HOST=192.168.1.100 VM_USER=admin TARGET_USER=developer \
    TARGET_SSH_KEY=~/.ssh/admin_key \
    USE_BECOME_PASSWORD=true BECOME_PASSWORD=adminpass
```

## Security Considerations

### Environment Variables

Keep passwords out of command history by using environment variables:

```bash
export SSH_PASSWORD="mypassword"
export BECOME_PASSWORD="sudopassword"

make deploy VM_HOST=192.168.1.100 TARGET_USER=developer \
    USE_SSH_PASSWORD=true USE_BECOME_PASSWORD=true
```

### SSH Key Permissions

Ensure SSH private keys have correct permissions:

```bash
chmod 600 ~/.ssh/your_private_key
```

## Troubleshooting

### Test SSH Connection

Test manual SSH connection:

```bash
ssh -i ~/.ssh/your_key user@host
```

### Test Connectivity

Use the built-in connectivity test:

```bash
make test-connection VM_HOST=192.168.1.100 TARGET_USER=developer
```

### Check Sudo Access

Test sudo access manually:

```bash
ssh user@host sudo whoami
```

### Debug with Verbose Output

Enable verbose Ansible output:

```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer -vvv
```

## Authentication Flow

1. **SSH Connection**: Connect to `VM_HOST` as `VM_USER` (or `TARGET_USER` if CONNECT_AS_TARGET=true)
2. **Authentication**: Use SSH key (default) or password (if USE_SSH_PASSWORD=true)
3. **Privilege Escalation**: Use sudo to execute tasks as `TARGET_USER` (unless CONNECT_AS_TARGET=true)
4. **Sudo Authentication**: Passwordless (default) or with password (if USE_BECOME_PASSWORD=true)

This covers all authentication methods and variables actually implemented in the deployment system.