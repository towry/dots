#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
VERSION="0.7.0"
BINARY_NAME="ck"
INSTALL_DIR="$HOME/.local/bin"
DOWNLOAD_URL="https://github.com/BeaconBay/ck/releases/download/${VERSION}/ck-${VERSION}-aarch64-apple-darwin.tar.gz"
TEMP_DIR=""

# Detect architecture and OS for validation
check_system() {
    local arch=$(uname -m)
    local os=$(uname -s)

    if [[ "$os" != "Darwin" ]]; then
        log_error "This script is specifically for macOS (Darwin). Detected: $os"
        exit 1
    fi

    if [[ "$arch" != "arm64" && "$arch" != "aarch64" ]]; then
        log_warn "This script installs an aarch64 binary, but your system architecture is $arch."
        log_warn "It might work via Rosetta 2 if applicable, but is not native."
    fi
}

# Cleanup function
cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Install ck
install_ck() {
    mkdir -p "$INSTALL_DIR"

    # Create temporary directory
    TEMP_DIR=$(mktemp -d -t ck-install-XXXXXXXX)
    trap cleanup EXIT

    local tarball="$TEMP_DIR/ck.tar.gz"

    log_info "Downloading ck version $VERSION..."
    if ! curl -L -o "$tarball" "$DOWNLOAD_URL"; then
        log_error "Failed to download ck"
        exit 1
    fi

    log_info "Extracting ck..."
    if ! tar -xzf "$tarball" -C "$TEMP_DIR"; then
        log_error "Failed to extract ck"
        exit 1
    fi

    # Find the binary
    local binary_path=$(find "$TEMP_DIR" -name "$BINARY_NAME" -type f | head -1)

    if [[ -z "$binary_path" ]]; then
        log_error "Could not find $BINARY_NAME binary in extracted files"
        exit 1
    fi

    log_info "Installing $BINARY_NAME to $INSTALL_DIR..."
    mv "$binary_path" "$INSTALL_DIR/$BINARY_NAME"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"

    log_info "ck installed successfully to $INSTALL_DIR/$BINARY_NAME"
}

# Verify installation
verify_installation() {
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        log_warn "Warning: $INSTALL_DIR is not in your PATH"
        log_warn "Add this line to your shell profile (.bashrc, .zshrc, etc.):"
        log_warn "export PATH=\"\$INSTALL_DIR:\$PATH\""
    fi

    if [[ -x "$INSTALL_DIR/$BINARY_NAME" ]]; then
        log_info "Installation verified."
        log_info "ck version info:"
        "$INSTALL_DIR/$BINARY_NAME" --version || log_warn "Could not run 'ck --version'"
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Main function
main() {
    log_info "Starting ck installation..."
    check_system
    install_ck
    verify_installation
    log_info "Done!"
}

main "$@"
