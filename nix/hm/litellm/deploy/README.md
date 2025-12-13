# LiteLLM Remote Deployment

Deploy LiteLLM proxy to a remote server using direct Python installation and systemd (no containers required).

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Actions CI                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ 1. Build config.yaml via Nix (with nix-priv secrets)    │    │
│  │ 2. Package: config.yaml + service file + deploy script  │    │
│  │ 3. SCP to remote server                                 │    │
│  │ 4. SSH: run deploy.sh                                   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Remote Server (agent)                         │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ /etc/litellm/config.yaml (deployed, secrets embedded)   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ systemd: litellm.service (system-level, survives SSH)   │    │
│  │   └── uvx litellm (auto-manages Python env)             │    │
│  │         └── exposes :4000                               │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## Files

| File | Description |
|------|-------------|
| `litellm.service` | Systemd system service unit |
| `deploy.sh` | Deployment script run on remote server |
| `deploy-config.nix` | Nix derivation for building config (optional) |

## GitHub Actions Workflow

The workflow (`.github/workflows/deploy-litellm.yml`) triggers on:
- Push to `main` branch when files in `nix/hm/litellm/**` change
- Manual dispatch (workflow_dispatch)

### Required Secrets

Configure these in your GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `SSH_PRIVATE_KEY` | SSH key with access to `towry/nix-priv` repo (already configured) |
| `DEPLOY_HOST` | Remote server hostname/IP (e.g., `agent`) |
| `DEPLOY_USERNAME` | SSH username on remote server |
| `DEPLOY_SSH_KEY` | SSH private key for remote server access |
| `DEPLOY_PORT` | (Optional) SSH port, defaults to 22 |

## Manual Deployment

If you need to deploy manually:

```bash
# 1. Build config locally (uses standalone config builder)
nix build .#litellm-config --out-link litellm-config

# 2. Copy files to remote
scp litellm-config/config.yaml nix/hm/litellm/deploy/*.{service,sh} user@agent:/tmp/litellm-deploy/

# 3. Run deploy script on remote
ssh user@agent 'sudo /tmp/litellm-deploy/deploy.sh /tmp/litellm-deploy/config.yaml'
```

## Remote Server Setup (First Time)

The deployment script automatically handles dependencies, but you can prepare the server:

```bash
# On remote server (as root):

# The deploy script will automatically:
# - Install uv (Python package manager from Gitee mirror) if not present
# - Create litellm system user
# - Create /etc/litellm and /opt/litellm directories
# - Deploy config and service file
# - Start the service

# Optionally, pre-install uv (using Gitee mirror for faster download):
curl -LsSf https://gitee.com/wangnov/uv-custom/releases/download/0.9.17/uv-installer-custom.sh | sh
```

## Service Management

```bash
# Start service
sudo systemctl start litellm

# Stop service
sudo systemctl stop litellm

# Restart service
sudo systemctl restart litellm

# View status
sudo systemctl status litellm

# View logs
sudo journalctl -u litellm -f

# View recent logs
sudo journalctl -u litellm -n 100
```

## Testing

```bash
# Health check
curl http://localhost:4000/health

# List models (requires master key from config)
curl http://localhost:4000/v1/models \
  -H "Authorization: Bearer sk-your-master-key"

# Test chat completion
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-your-master-key" \
  -H "Content-Type: application/json" \
  -d '{"model": "frontier-muffin", "messages": [{"role": "user", "content": "Hello!"}]}'
```

## How It Works

1. **No Containers**: Runs litellm directly via `uvx` (Python package runner)
2. **Auto Dependencies**: `uvx` automatically manages Python 3.11 and litellm 1.80.9
3. **System Service**: Runs as system service (not user) to survive SSH disconnections
4. **Dedicated User**: Runs as `litellm` user for security isolation
5. **Secrets**: Embedded in `config.yaml` from nix-priv during build

## Advantages Over Containers

- **No Registry Access Needed**: No need to pull from ghcr.io or other registries
- **Simpler Setup**: No container runtime (podman/docker) required
- **Automatic Updates**: `uvx` handles Python dependencies automatically
- **Native Performance**: Direct execution, no container overhead

## Important Notes

1. **System Service**: The service runs as a system service (not user service) to survive SSH disconnections
2. **Secrets in Config**: The `config.yaml` built via nix contains embedded secrets from `nix-priv`
3. **Port**: LiteLLM listens on port 4000 by default
4. **User Isolation**: Runs as dedicated `litellm` system user for security
