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

# Check if gh command is available (optional)
check_gh_command() {
    if ! command -v gh &> /dev/null; then
        log_warn "GitHub CLI (gh) is not installed or not in PATH"
        log_warn "Installation will continue without authenticated requests (rate limited)"
        return 0
    fi
}

# Detect architecture
detect_arch() {
    local arch
    arch=$(uname -m)

    case "$arch" in
        x86_64)
            echo "x86_64"
            ;;
        arm64|aarch64)
            echo "aarch64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Detect OS
detect_os() {
    local os
    os=$(uname -s)

    case "$os" in
        Darwin)
            echo "apple-darwin"
            ;;
        Linux)
            echo "unknown-linux-gnu"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "pc-windows-msvc"
            ;;
        *)
            log_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
}

# Get latest release info
get_latest_release() {
    log_info "Fetching latest release information..." >&2

    # Use curl with optional GitHub token for higher rate limits
    local auth_header=""
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
        # Use gh token if available
        local token
        token=$(gh auth token 2>/dev/null)
        if [[ -n "$token" ]]; then
            auth_header="Authorization: token $token"
        fi
    fi

    if [[ -n "$auth_header" ]]; then
        curl -s -H "$auth_header" "https://api.github.com/repos/openai/codex/releases/latest"
    else
        # Fallback to unauthenticated request (rate limited but works)
        curl -s "https://api.github.com/repos/openai/codex/releases/latest"
    fi
}

# Find download URL for the correct architecture
find_download_url() {
    local release_info="$1"
    local arch="$2"
    local os="$3"

    # Construct the expected asset name pattern
    local asset_pattern="codex-${arch}-${os}.tar.gz"

    log_info "Looking for asset matching pattern: $asset_pattern" >&2

    # Check if .assets exists and is an array
    local assets_type
    assets_type=$(echo "$release_info" | jq -r 'if .assets then (if (.assets | type) == "array" then "array" else "not_array" end) else "missing" end')
    if [[ "$assets_type" != "array" ]]; then
        log_error ".assets field is missing or not an array in the GitHub release JSON."
        log_info "Raw release_info:"
        echo "$release_info" | jq '.'
        exit 1
    fi

    local download_url
    download_url=$(echo "$release_info" | jq -r --arg pattern "$asset_pattern" '
        .assets[] |
        select(.name == $pattern) |
        .browser_download_url
    ')

    if [[ -z "$download_url" || "$download_url" == "null" ]]; then
        log_error "No matching asset found for $asset_pattern"
        log_info "Available assets:"
        echo "$release_info" | jq -r '.assets[].name' | sed 's/^/  - /'
        exit 1
    fi

    echo "$download_url"
}

# Download and install codex
install_codex() {
    local download_url="$1"
    local version="$2"

    # Create installation directory
    local install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"

    # Create temporary directory for download
    local temp_dir="/tmp/codex-install-$$"
    mkdir -p "$temp_dir"

    local temp_file="$temp_dir/codex.tar.gz"

    log_info "Downloading Codex CLI version $version to $temp_dir..."
    log_info "Download URL: $download_url"

    # Download the tar.gz file
    if ! curl -L -o "$temp_file" "$download_url"; then
        log_error "Failed to download Codex CLI"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Check if tar is available
    if ! command -v tar &> /dev/null; then
        log_error "tar is not installed or not in PATH"
        log_error "Please install tar to extract the downloaded file"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Extract the tar.gz file
    log_info "Extracting Codex CLI..."
    if ! tar -xzf "$temp_file" -C "$temp_dir"; then
        log_error "Failed to extract Codex CLI"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Remove the tar.gz file after extraction to avoid confusion
    rm -f "$temp_file"

    # Find the codex binary using the known pattern
    local binary_path
    binary_path=$(find "$temp_dir" -name "codex-${arch}-${os}" -type f | head -1)

    # Fallback: try simple "codex" name
    if [[ -z "$binary_path" ]]; then
        binary_path=$(find "$temp_dir" -name "codex" -type f | head -1)
    fi

    if [[ -z "$binary_path" ]]; then
        log_error "Could not find codex binary in extracted files"
        log_info "Expected: codex-${arch}-${os} or codex"
        log_info "Contents of extracted directory:"
        find "$temp_dir" -type f | sed 's/^/  /'
        rm -rf "$temp_dir"
        exit 1
    fi

    # Make executable and move to installation directory
    chmod +x "$binary_path"
    mv "$binary_path" "$install_dir/codex"

    # Clean up temporary directory
    rm -rf "$temp_dir"

    log_info "Codex CLI installed successfully to $install_dir/codex"

    # Check if the installation directory is in PATH
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        log_warn "Warning: $install_dir is not in your PATH"
        log_warn "Add this line to your shell profile (.bashrc, .zshrc, etc.):"
        log_warn "export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# Verify installation
verify_installation() {
    local install_dir="$HOME/.local/bin"

    if [[ -x "$install_dir/codex" ]]; then
        log_info "Installation verified successfully"
        log_info "Codex CLI version:"
        "$install_dir/codex" --version 2>/dev/null || echo "  (version command may not be available)"
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Main function
main() {
    log_info "Starting Codex CLI installation..."

    # Check prerequisites
    check_gh_command

    # Check if jq is available for JSON parsing
    if ! command -v jq &> /dev/null; then
        log_error "jq is not installed or not in PATH"
        log_error "Please install jq for JSON parsing"
        exit 1
    fi

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed or not in PATH"
        log_error "Please install curl for downloading files"
        exit 1
    fi

    # Detect system information
    local arch os
    arch=$(detect_arch)
    os=$(detect_os)

    log_info "Detected architecture: $arch"
    log_info "Detected OS: $os"

    # Get latest release and process it
    log_info "Getting release information..."
    local release_info version download_url
    release_info=$(get_latest_release)

    if [[ $? -ne 0 ]] || [[ -z "$release_info" ]]; then
        log_error "Failed to get release information"
        exit 1
    fi

    # Validate that release_info is valid JSON
    if ! jq empty <<< "$release_info" 2>/dev/null; then
        log_error "Release info is not valid JSON"
        echo "Raw release_info: $release_info" >&2
        exit 1
    fi

    log_info "Parsing version..."
    version=$(jq -r '.tag_name' <<< "$release_info")
    if [[ $? -ne 0 ]]; then
        log_error "Failed to parse version from release info"
        exit 1
    fi
    log_info "Latest version: $version"

    # Find download URL
    download_url=$(find_download_url "$release_info" "$arch" "$os")

    # Install codex
    install_codex "$download_url" "$version"

    # Verify installation
    verify_installation

    log_info "Codex CLI installation completed successfully!"
}

# Run main function
main "$@"