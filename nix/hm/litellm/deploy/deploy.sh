#!/usr/bin/env bash
# LiteLLM Remote Deployment Script
# Usage: ./deploy.sh <config_path>
#
# This script is run on the remote server via SSH to deploy the litellm config
# and restart the service.

set -euo pipefail

CONFIG_PATH="${1:-/tmp/litellm-config.yaml}"
LITELLM_DIR="/etc/litellm"
LITELLM_HOME="/opt/litellm"
SERVICE_FILE="/etc/systemd/system/litellm.service"

echo "=== LiteLLM Deployment ==="
echo "Config source: $CONFIG_PATH"
echo ""

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Install dependencies if needed
echo "Checking dependencies..."

# Add common uv installation paths to PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

if ! command -v uvx &> /dev/null; then
    echo "Installing uv (Python package manager from Gitee mirror)..."
    curl -LsSf https://gitee.com/wangnov/uv-custom/releases/download/0.9.17/uv-installer-custom.sh | sh

    # Update PATH again after installation
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

    # Verify installation
    if ! command -v uvx &> /dev/null; then
        echo "Error: Failed to install uvx"
        echo "PATH=$PATH"
        echo "Checking common locations..."
        ls -la "$HOME/.local/bin/" 2>/dev/null || echo "$HOME/.local/bin/ not found"
        ls -la "$HOME/.cargo/bin/" 2>/dev/null || echo "$HOME/.cargo/bin/ not found"
        exit 1
    fi
fi

echo "✓ uvx is available at: $(which uvx)"

# Copy binaries to /usr/local/bin for system-wide access
# (Symlinks won't work because /root/.local/bin is not accessible to litellm user)
echo "Installing uv/uvx to /usr/local/bin..."

# Remove old symlinks if they exist
rm -f /usr/local/bin/uvx /usr/local/bin/uv

UVX_PATH=$(which uvx)
UV_PATH=$(which uv)

if [[ -n "$UVX_PATH" ]]; then
    cp -f "$UVX_PATH" /usr/local/bin/uvx
    chmod 755 /usr/local/bin/uvx
    echo "✓ Copied uvx to /usr/local/bin/uvx"
fi

if [[ -n "$UV_PATH" ]]; then
    cp -f "$UV_PATH" /usr/local/bin/uv
    chmod 755 /usr/local/bin/uv
    echo "✓ Copied uv to /usr/local/bin/uv"
fi

# Verify the binaries work
if ! /usr/local/bin/uvx --version &> /dev/null; then
    echo "Error: /usr/local/bin/uvx is not working"
    exit 1
fi
echo "✓ /usr/local/bin/uvx is ready"

# Create system-wide uv config with mirrors
# Commented out for Korea server - no need for China mirrors
# echo "Creating system-wide uv config..."
# mkdir -p /etc/uv
# cat > /etc/uv/uv.toml << 'EOF'
# python-install-mirror = "https://gh-proxy.com/github.com/astral-sh/python-build-standalone/releases/download"
#
# [[index]]
# url = "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple/"
# default = true
# EOF
# echo "✓ Created /etc/uv/uv.toml with mirror settings"
echo "✓ Skipped uv mirror config (not needed for Korea server)"

# Create litellm user if it doesn't exist
if ! id -u litellm &> /dev/null; then
    echo "Creating litellm user..."
    useradd --system --home-dir "$LITELLM_HOME" --create-home \
            --shell /usr/sbin/nologin litellm
fi

# Create directories
echo "Setting up directories..."
mkdir -p "$LITELLM_DIR"
mkdir -p "$LITELLM_HOME"
chown litellm:litellm "$LITELLM_HOME"

# Deploy config
echo "Deploying config to $LITELLM_DIR/config.yaml..."
cp "$CONFIG_PATH" "$LITELLM_DIR/config.yaml"
chmod 600 "$LITELLM_DIR/config.yaml"
chown litellm:litellm "$LITELLM_DIR/config.yaml"

# Check if service file needs updating
if [[ -f "/tmp/litellm-deploy/litellm.service" ]]; then
    echo "Updating systemd service file..."
    cp /tmp/litellm-deploy/litellm.service "$SERVICE_FILE"
    systemctl daemon-reload
fi

# Enable and restart service
echo "Restarting litellm service..."
systemctl enable litellm 2>/dev/null || true
systemctl restart litellm

# Wait for service to start
echo "Waiting for service to start..."
sleep 5

# Check service status
if systemctl is-active --quiet litellm; then
    echo ""
    echo "=== Deployment successful ==="
    echo "Service status: active"
    echo ""
    echo "View logs: sudo journalctl -u litellm -f"
    echo "Check health: curl http://localhost:4000/health"
else
    echo ""
    echo "=== Deployment WARNING ==="
    echo "Service may not have started correctly"
    echo "Check logs: sudo journalctl -u litellm -n 50"
    exit 1
fi
