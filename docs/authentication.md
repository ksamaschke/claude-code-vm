# Authentication Examples

This document shows different authentication scenarios and how to handle them with the deployment system.

## Default Authentication (Root + SSH Key)

**Scenario**: Connect as root using SSH key, then sudo to target user
```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer
```

**How it works**:
- Connects as `root` using `~/.ssh/id_rsa`
- Uses `sudo` to execute tasks as `developer`
- No passwords required (assumes passwordless sudo)

## Direct Target User Connection (More Secure)

**Scenario**: Connect directly as target user (no root access needed)
```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer CONNECT_AS_TARGET=true
```

**How it works**:
- Connects directly as `developer` using SSH key
- No privilege escalation needed
- More secure (no root access required)

## Target User with Custom SSH Key

**Scenario**: Target user has their own SSH key
```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer \
    CONNECT_AS_TARGET=true TARGET_SSH_KEY=~/.ssh/developer_key
```

**How it works**:
- Connects as `developer` using `~/.ssh/developer_key`
- Uses the specific key for that user

## Password Authentication (No SSH Keys)

**Scenario**: SSH keys not available, must use passwords
```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer \
    USE_SSH_PASSWORD=true SSH_PASSWORD=mypassword123
```

**How it works**:
- Connects using password instead of SSH key
- Still uses sudo to switch to target user

## Password Authentication + Direct Connection

**Scenario**: Connect directly as target user using password
```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer \
    CONNECT_AS_TARGET=true USE_SSH_PASSWORD=true SSH_PASSWORD=devpassword
```

**How it works**:
- Connects directly as `developer` using password
- No privilege escalation needed

## Sudo with Password Required

**Scenario**: Sudo requires password (security-hardened system)
```bash
make deploy VM_HOST=192.168.1.100 TARGET_USER=developer \
    USE_BECOME_PASSWORD=true BECOME_PASSWORD=sudopassword123
```

**How it works**:
- Connects as root with SSH key
- Uses password for sudo operations

## Complex Authentication

**Scenario**: Non-root user with custom key and sudo password
```bash
make deploy VM_HOST=192.168.1.100 VM_USER=admin TARGET_USER=developer \
    TARGET_SSH_KEY=~/.ssh/admin_key \
    USE_BECOME_PASSWORD=true BECOME_PASSWORD=adminpassword
```

**How it works**:
- Connects as `admin` using `~/.ssh/admin_key`
- Uses password for sudo to become `developer`

## Environment Variables (Secure)

**Scenario**: Keep passwords out of command line history
```bash
export SSH_PASSWORD="mypassword123"
export BECOME_PASSWORD="sudopassword"

make deploy VM_HOST=192.168.1.100 TARGET_USER=developer \
    USE_SSH_PASSWORD=true USE_BECOME_PASSWORD=true
```

## Group Inventory with Different Auth Methods

**inventory.yml example**:
```yaml
all:
  children:
    production:
      hosts:
        secure-server:
          ansible_host: 10.0.1.10
          ansible_user: admin
          ansible_ssh_private_key_file: ~/.ssh/prod_admin_key
          ansible_become_password: "{{ vault_sudo_password }}"
          target_user: webapp
        dev-server:
          ansible_host: 10.0.1.20
          ansible_user: developer
          ansible_ssh_private_key_file: ~/.ssh/dev_key
          target_user: developer
          ansible_become: false  # No privilege escalation needed
```

## Security Best Practices

1. **Use SSH Keys**: Always prefer SSH keys over passwords
2. **Direct Connection**: Use `CONNECT_AS_TARGET=true` when possible
3. **Vault Passwords**: Use Ansible Vault for passwords in inventory
4. **Environment Variables**: Keep sensitive data out of command history
5. **Limited Access**: Only grant minimum required privileges

## Troubleshooting Authentication

**SSH Key Issues**:
```bash
# Test SSH connection manually
ssh -i ~/.ssh/your_key user@host

# Check SSH agent
ssh-add -l
```

**Permission Issues**:
```bash
# Check if user can sudo
sudo -l

# Test become without password
sudo -n whoami
```

**Ansible Verbosity**:
```bash
# Debug authentication issues
make deploy VM_HOST=... TARGET_USER=... -vvv
```