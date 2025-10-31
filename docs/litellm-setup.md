# LiteLLM Setup Guide

## Overview

This setup configures LiteLLM to proxy GitHub Copilot models, making them available for Claude Code and other OpenAI-compatible clients.

## Architecture

```
Claude Code → LiteLLM Proxy (localhost:4000) → GitHub Copilot → Claude/GPT Models
```

## Installation

The `litellm.nix` module has been added to your home-manager configuration. After rebuilding:

```bash
make build
```

You'll have access to:
- `litellm-start` - Start the proxy server
- `litellm-test` - Test the proxy
- `litellm-status` - Check proxy status
- `litellm-models` - List available models
- `litellm-setup` - Configure master key (Fish function)

## Quick Start

### 1. Generate a Master Key

The master key is your local authentication token for the LiteLLM proxy (not from an external service):

```fish
litellm-setup sk-$(openssl rand -hex 16)
```

This will:
- Generate a secure random key
- Set `LITELLM_MASTER_KEY` and `ANTHROPIC_AUTH_TOKEN` persistently
- Show configured model tiers

### 2. Reload Your Shell

After `make build`, reload environment variables:

```fish
exec fish
```

Or close and reopen your terminal.

### 3. Start LiteLLM Proxy

```bash
litellm-start
```

This will:
- Start the proxy on `http://0.0.0.0:4000`
- Prompt you to authenticate with GitHub Copilot on first run
- Store authentication tokens in `~/.config/litellm/github_copilot/`

### 4. Authenticate with GitHub Copilot

On first start, you'll see:
```
Please visit: https://github.com/login/device
Enter code: XXXX-XXXX
```

Follow the instructions to authenticate your GitHub Copilot access.

### 5. Test the Setup

```bash
# Test with default model (claude-sonnet-4.5)
litellm-test

# Test with specific model and prompt
litellm-test claude-opus-41 "Explain async/await in Python"
```

### 6. Configure Claude Code

The environment variables are already set in your shell:
- `ANTHROPIC_BASE_URL=http://0.0.0.0:4000`
- `ANTHROPIC_AUTH_TOKEN=$LITELLM_MASTER_KEY` (set via litellm-setup)

#### Claude Code Model Tier Configuration

Claude Code automatically uses different models for different tasks based on these environment variables:

| Environment Variable | Default Model | Usage |
|---------------------|---------------|-------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `claude-opus-41` | Opus tier, opusplan with Plan Mode active |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `claude-sonnet-4.5` | Sonnet tier, opusplan without Plan Mode |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `claude-haiku-4.5` | Haiku tier, background tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `claude-sonnet-4.5` | Subagent operations |

These are pre-configured in `nix/hm/litellm.nix`. You can customize them by editing the file and rebuilding.

Just start Claude Code and it will use the LiteLLM proxy automatically!

## Available Models

### Claude Models (via GitHub Copilot)
- `claude-opus-41` - Latest Opus model
- `claude-opus-4` - Opus 4
- `claude-sonnet-4.5` - Latest Sonnet (recommended)
- `claude-sonnet-4` - Sonnet 4
- `claude-3.7-sonnet` - Claude 3.7 Sonnet (deprecated)
- `claude-3.5-sonnet` - Claude 3.5 Sonnet (deprecated)
- `claude-haiku-4.5` - Fast Haiku model

### GPT Models (via GitHub Copilot)
- `gpt-4o` - GPT-4 Optimized
- `gpt-4.1` - GPT-4.1
- `gpt-5` - GPT-5
- `gpt-5-mini` - GPT-5 Mini
- `gpt-5-codex` - GPT-5 Codex (for coding)
- `o3` - O3 reasoning model
- `o3-mini` - O3 Mini
- `o4-mini` - O4 Mini

### Other Models
- `gemini-2.0-flash-001` - Google Gemini
- `gemini-2.5-pro` - Gemini 2.5 Pro
- `grok-code-fast-1` - Grok coding model

## Usage Examples

### Using with curl

```bash
curl -X POST http://0.0.0.0:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4.5",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Using with OpenAI Python SDK

```python
from openai import OpenAI
import os

client = OpenAI(
    base_url="http://0.0.0.0:4000",
    api_key=os.environ["LITELLM_MASTER_KEY"]
)

response = client.chat.completions.create(
    model="claude-sonnet-4.5",
    messages=[{"role": "user", "content": "Write a Python function"}]
)

print(response.choices[0].message.content)
```

### Using with Claude Code

Claude Code automatically uses the environment variables:

```bash
# Just start Claude Code
claude

# Or specify a model
claude --model claude-opus-41
```

## Configuration Files

- **Main config**: `~/.config/litellm/config.yaml`
- **Token storage**: `~/.config/litellm/github_copilot/`
- **README**: `~/.config/litellm/README.md`
- **Nix module**: `nix/hm/litellm.nix`

## Troubleshooting

### Proxy not starting

```bash
# Check if port 4000 is already in use
lsof -i :4000

# Kill process using port 4000
killport 4000
```

### Authentication issues

```bash
# Remove stored tokens and re-authenticate
rm -rf ~/.config/litellm/github_copilot/
litellm-start
```

### Check proxy health

```bash
litellm-status
# or
curl http://0.0.0.0:4000/health
```

### View available models

```bash
litellm-models
```

### Enable debug logging

```bash
litellm-start --debug
```

### Environment variables not set after rebuild

```fish
# Reload shell environment
exec fish

# Or verify manually
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_DEFAULT_SONNET_MODEL
```

## Running as a Service (Optional)

To run LiteLLM as a background service, uncomment the systemd service section in `nix/hm/litellm.nix` and rebuild:

```nix
systemd.user.services.litellm = {
  # ... (currently commented out)
};
```

Then:

```bash
make build
systemctl --user start litellm
systemctl --user enable litellm  # Start on boot
```

## Security Notes

1. **Master Key**: Keep your `LITELLM_MASTER_KEY` secure. It provides full access to the proxy.
2. **Local Only**: By default, the proxy binds to `0.0.0.0:4000`. Consider using `127.0.0.1:4000` for local-only access.
3. **GitHub Auth**: Tokens are stored in `~/.config/litellm/github_copilot/`. Keep this directory secure.

## Advanced Configuration

### Customizing Claude Code Model Tiers

Edit `nix/hm/litellm.nix` to change which models Claude Code uses for different tiers:

```nix
home.sessionVariables = {
  # Customize model assignments
  ANTHROPIC_DEFAULT_OPUS_MODEL = "claude-opus-41";      # Opus tier
  ANTHROPIC_DEFAULT_SONNET_MODEL = "claude-sonnet-4.5"; # Sonnet tier
  ANTHROPIC_DEFAULT_HAIKU_MODEL = "claude-haiku-4.5";   # Haiku tier
  CLAUDE_CODE_SUBAGENT_MODEL = "claude-sonnet-4.5";     # Subagents
};
```

Then rebuild:
```bash
make build
exec fish  # Reload environment
```

### Adding More Models

Edit `nix/hm/litellm.nix` to add more models to the config:

```yaml
model_list:
  - model_name: my-custom-model
    litellm_params:
      model: github_copilot/model-name
```

### Custom Port

```bash
litellm-start --port 8000
```

### Enable Verbose Logging

In `nix/hm/litellm.nix`, set:

```yaml
litellm_settings:
  set_verbose: true
```

## References

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [GitHub Copilot Provider](https://docs.litellm.ai/docs/providers/github_copilot)
- [Claude Code Integration](https://docs.litellm.ai/docs/tutorials/claude_responses_api)
- [Anthropic LiteLLM Config](https://docs.anthropic.com/en/docs/claude-code/llm-gateway#litellm-configuration)
