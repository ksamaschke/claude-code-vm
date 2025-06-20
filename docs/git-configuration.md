# Git Configuration Guide

This guide explains how to configure Git credentials for multiple Git hosting providers.

## Two-Tier Git Configuration System

The deployment system uses a two-tier approach for Git server configuration:

1. **Well-known Providers**: GitHub.com and GitLab.com have automatic URLs
2. **Custom Servers**: All other Git servers use configurable URLs with the `GIT_{NAME}_*` pattern

This design provides convenience for common providers while supporting unlimited custom Git servers.

## Basic Configuration Examples

### Single Provider (Most Common)
For users with just one Git provider:

```bash
# Just GitHub (URL is automatic)
GITHUB_USERNAME="myusername"
GITHUB_PAT="ghp_xxxxxxxxxxxxxxxxxxxx"
```

### Multiple Providers
For users with multiple Git accounts:

```bash
# Personal GitHub (URL is automatic)
GITHUB_USERNAME="personal-user"
GITHUB_PAT="ghp_xxxxxxxxxxxxxxxxxxxx"

# Company GitLab (custom server)
GIT_WORK_URL="https://gitlab.company.com"
GIT_WORK_USERNAME="work-user"
GIT_WORK_PAT="glpat-xxxxxxxxxxxxxxxxxxxx"

# Azure DevOps (custom server)
GIT_AZURE_URL="https://dev.azure.com/mycompany"
GIT_AZURE_USERNAME="work-email@company.com"
GIT_AZURE_PAT="xxxxxxxxxxxxxxxxxxxxxxx"
```

## Advanced Configuration Examples

### Multiple GitLab Instances
This is particularly useful for consultants or developers working with multiple organizations:

```bash
# GitLab.com (personal projects - URL is automatic)
GITLAB_USERNAME="personal-user"
GITLAB_PAT="glpat-personal-token"

# Client A's GitLab (custom server)
GIT_CLIENTA_URL="https://gitlab.clienta.com"
GIT_CLIENTA_USERNAME="consultant-user"
GIT_CLIENTA_PAT="glpat-clienta-token"

# Client B's GitLab (custom server)
GIT_CLIENTB_URL="https://git.clientb.org"
GIT_CLIENTB_USERNAME="contractor-user"
GIT_CLIENTB_PAT="glpat-clientb-token"
```

### Mixed Enterprise Environment
Common in large organizations:

```bash
# External GitHub for open source (URL is automatic)
GITHUB_USERNAME="public-user"
GITHUB_PAT="ghp_public-token"

# Internal GitHub Enterprise (custom server)
GIT_INTERNAL_URL="https://github.enterprise.com"
GIT_INTERNAL_USERNAME="employee-id"
GIT_INTERNAL_PAT="ghp_internal-token"

# Legacy Git server (custom server)
GIT_LEGACY_URL="https://git.legacy-system.com"
GIT_LEGACY_USERNAME="legacy-user"
GIT_LEGACY_PAT="legacy-token"
```

## How It Works

The deployment system:

1. **Detects** well-known providers: `GITHUB_*` and `GITLAB_*` with automatic URLs
2. **Scans** your `.env` file for `GIT_{NAME}_*` patterns for custom servers
3. **Groups** the URL, USERNAME, and PAT for each unique server
4. **Configures** Git Credential Manager with server-specific credential helpers
5. **Enables** automatic authentication for `git clone`, `git push`, etc.

## Naming Convention

**Well-known providers** (automatic URLs):
- `GITHUB_USERNAME` / `GITHUB_PAT` - Always uses https://github.com
- `GITLAB_USERNAME` / `GITLAB_PAT` - Always uses https://gitlab.com

**Custom servers** - The `{NAME}` in `GIT_{NAME}_{FIELD}` can be anything descriptive:
- `GIT_COMPANY_*` - for organization-specific servers
- `GIT_CLIENT1_*`, `GIT_CLIENT2_*` - for multiple client environments
- `GIT_STAGING_*`, `GIT_PROD_*` - for environment-specific servers

## Verification

After deployment, you can verify the configuration:

```bash
# Check configured Git servers
git config --global --list | grep credential

# Test authentication (should not prompt for password)
git clone https://github.com/yourusername/your-repo.git
git clone https://gitlab.company.com/team/project.git
```

## Security Best Practices

1. **Use Personal Access Tokens** instead of passwords
2. **Set minimal permissions** on PATs (usually just repository access)
3. **Use different PATs** for different servers/purposes
4. **Rotate PATs regularly** according to your organization's security policy
5. **Never commit** the `.env` file to version control

## Troubleshooting

### Common Issues

1. **"Permission denied"** - Check if PAT has correct permissions
2. **"Authentication failed"** - Verify username matches the Git server account
3. **"Repository not found"** - Ensure URL and repository path are correct

### Testing Individual Servers

```bash
# Test specific server authentication
git ls-remote https://github.com/yourusername/test-repo.git
git ls-remote https://gitlab.company.com/team/project.git
```

If authentication works, you should see repository information without being prompted for credentials.