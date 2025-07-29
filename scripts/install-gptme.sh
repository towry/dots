#!/usr/bin/env bash

set -e

# Configuration variables
INSTALL_FROM_GIT=true  # Set to false to install from PyPI instead
GPTME_GIT_URL="git+https://github.com/gptme/gptme"
GPTME_COMMIT="4ac4a45fd1d751f75e458271ee988fd7cc94d1e7"
GPTME_PYPI_VERSION="gptme[browser]==0.27.0"
GPTME_RAG_VERSION="0.5.0"
PLAYWRIGHT_VERSION="1.49.1"
PYTHON_VERSION="3.12"

echo "Installing gptme tools..."

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "Error: uv is not available in PATH"
    exit 1
fi

# Install gptme with browser support, httpx[socks] dependency, and audio dependencies
if [ "$INSTALL_FROM_GIT" = true ]; then
    echo "Installing gptme from git (commit: $GPTME_COMMIT)..."
    # When installing from git, we need to explicitly add browser and audio dependencies
    uv tool install --python "$PYTHON_VERSION" --with 'httpx[socks]' --with 'playwright' --with 'numpy' --with 'scipy' --with 'sounddevice' "${GPTME_GIT_URL}@${GPTME_COMMIT}" && echo "--- Install gptme from git done"
else
    echo "Installing gptme from PyPI (version: $GPTME_PYPI_VERSION)..."
    uv tool install --python "$PYTHON_VERSION" --with 'httpx[socks]' --with 'numpy' --with 'scipy' --with 'sounddevice' "$GPTME_PYPI_VERSION" && echo "--- Install gptme from PyPI done"
fi

# NOTE: Using Python 3.12 due to _opcode module missing in Python 3.13.5 ARM64 builds
echo "Installing gptme-rag..."
uv tool install --python "$PYTHON_VERSION" "gptme-rag==$GPTME_RAG_VERSION" && echo "--- Install gptme-rag done"

# Setup playwright browser binaries
echo "Installing playwright..."
uv tool install --python "$PYTHON_VERSION" "playwright==$PLAYWRIGHT_VERSION" && echo "--- Install playwright done"

echo "Installing chromium-headless-shell..."
uv tool run playwright install chromium-headless-shell && echo "--- Install chromium-headless-shell done"

echo "--- All gptme tools installation completed"
