# LiteLLM Config Architecture

## Overview

The LiteLLM configuration now uses a **shared config generator** to maintain consistency between local (home-manager) and remote (CI/CD) deployments.

## File Structure

```
nix/hm/litellm/
├── config-generator.nix       # ⭐ Single source of truth for all model configs
├── standalone-config.nix       # CI/CD wrapper (3 lines)
├── model-tokens.nix            # Token limits database
├── bender-muffin.nix           # Model group
├── free-muffin.nix             # Model group
├── frontier-muffin.nix         # Model group
└── deploy/                     # Deployment files
    ├── litellm.service
    ├── deploy.sh
    └── README.md

nix/hm/litellm.nix              # Home-manager module (uses config-generator)
```

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│          config-generator.nix (Shared)                       │
│  ┌────────────────────────────────────────────────────┐      │
│  │ • Model definitions (deepseek, mistral, google...) │      │
│  │ • GitHub Copilot headers                           │      │
│  │ • LiteLLM settings (cache, fallbacks, routing)     │      │
│  │                                                     │      │
│  │ Exports: { modelList, copilotHeaders, config }     │      │
│  └────────────────────────────────────────────────────┘      │
└──────────────────────────────────────────────────────────────┘
                     ↓                    ↓
        ┌────────────────────┐  ┌────────────────────┐
        │   litellm.nix      │  │standalone-config.nix│
        │  (home-manager)    │  │    (CI/CD)          │
        ├────────────────────┤  ├─────────────────────┤
        │ + launchd service  │  │ Just imports        │
        │ + Fish functions   │  │ config-generator    │
        │ + Helper scripts   │  │ and generates YAML  │
        │ + Uses shared cfg  │  │                     │
        └────────────────────┘  └─────────────────────┘
                ↓                         ↓
     ~/.config/litellm/          nix build output
       config.yaml                 config.yaml
```

## Benefits

### 1. **Single Source of Truth**
- All model configurations defined once in `config-generator.nix`
- No duplication between home-manager and CI/CD configs
- Changes propagate to both local and remote automatically

### 2. **Easy Maintenance**
```nix
# To add a new model, edit ONE file:
# nix/hm/litellm/config-generator.nix

# Add to appropriate model list:
deepseekModels = builtins.map (...) [
  "deepseek-chat"
  "deepseek-reasoner"
  "deepseek-new-model"  # ← Just add here!
];
```

### 3. **Consistency Guaranteed**
- Local dev and production use identical configs
- No drift between environments
- Easier debugging and testing

## How to Update Configs

### Adding a New Model

Edit `nix/hm/litellm/config-generator.nix`:

```nix
# Find the appropriate model group and add your model
googleModels = builtins.map (model: ...) [
  "gemini-2.5-pro"
  "gemini-2.5-flash"
  "gemini-3.0-ultra"  # ← Add here
];
```

### Changing Settings

Edit `nix/hm/litellm/config-generator.nix`:

```nix
config = {
  model_list = modelList;
  litellm_settings = {
    request_timeout = 600;  # ← Change settings here
    num_retries = 2;
    ...
  };
};
```

### Testing Changes

```bash
# Test locally (home-manager)
home-manager switch

# Test CI build
nix build .#litellm-config
cat result/config.yaml

# Deploy to remote
git push origin next  # triggers GitHub Actions
```

## Migration Complete

### Before (Duplicated):
- `litellm.nix`: 450+ lines of model definitions
- `standalone-config.nix`: 450+ lines of duplicate model definitions
- **Total**: ~900 lines, 2× maintenance burden

### After (Shared):
- `config-generator.nix`: 450 lines (single source)
- `litellm.nix`: 280 lines (home-manager specific)
- `standalone-config.nix`: 3 lines (import wrapper)
- **Total**: ~730 lines, 1× maintenance burden

**Savings**: ~170 lines removed, maintenance effort cut in half!
