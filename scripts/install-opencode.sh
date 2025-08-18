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

# Check if gh command is available
check_gh_command() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed or not in PATH"
        log_error "Please install GitHub CLI first: https://cli.github.com/"
        exit 1
    fi
}

# Detect architecture
detect_arch() {
    local arch
    arch=$(uname -m)

    case "$arch" in
        x86_64)
            echo "x64"
            ;;
        arm64|aarch64)
            echo "arm64"
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
            echo "darwin"
            ;;
        Linux)
            echo "linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "windows"
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

    # Use curl instead of gh to avoid bash variable assignment issues
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
        curl -s -H "$auth_header" "https://api.github.com/repos/sst/opencode/releases/latest"
    else
        # Fallback to unauthenticated request (rate limited but works)
        curl -s "https://api.github.com/repos/sst/opencode/releases/latest"
    fi
}

# Find download URL for the correct architecture
find_download_url() {
    local release_info="$1"
    local arch="$2"
    local os="$3"

    # Construct the expected asset name pattern
    local asset_pattern="opencode-${os}-${arch}"

    # For macOS x64, try both baseline and regular versions, prefer regular
    if [[ "$os" == "darwin" && "$arch" == "x64" ]]; then
        log_info "Looking for asset matching pattern: $asset_pattern (with fallback to baseline)" >&2

        # Try regular x64 first
        local download_url
        download_url=$(echo "$release_info" | jq -r --arg pattern "${asset_pattern}.zip" '
            .assets[] |
            select(.name == $pattern) |
            .browser_download_url
        ')

        # If not found, try baseline
        if [[ -z "$download_url" || "$download_url" == "null" ]]; then
            asset_pattern="opencode-${os}-${arch}-baseline"
            log_info "Falling back to baseline version: $asset_pattern" >&2
            download_url=$(echo "$release_info" | jq -r --arg pattern "${asset_pattern}.zip" '
                .assets[] |
                select(.name == $pattern) |
                .browser_download_url
            ')
        fi
    else
        log_info "Looking for asset matching pattern: $asset_pattern" >&2
        local download_url
        download_url=$(echo "$release_info" | jq -r --arg pattern "${asset_pattern}.zip" '
            .assets[] |
            select(.name == $pattern) |
            .browser_download_url
        ')
    fi

    if [[ -z "$download_url" || "$download_url" == "null" ]]; then
        log_error "No matching asset found for $asset_pattern"
        log_info "Available assets:"
        echo "$release_info" | jq -r '.assets[].name' | sed 's/^/  - /'
        exit 1
    fi

    echo "$download_url"
}

# Download and install opencode
install_opencode() {
    local download_url="$1"
    local version="$2"

    # Create installation directory
    local install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"

    # Create temporary directory for download
    local temp_dir="/tmp/opencode-install-$$"
    mkdir -p "$temp_dir"

    local temp_file="$temp_dir/opencode.zip"

    log_info "Downloading OpenCode CLI version $version to $temp_dir..."
    log_info "Download URL: $download_url"

    # Download the zip file to /tmp
    if ! curl -L -o "$temp_file" "$download_url"; then
        log_error "Failed to download OpenCode CLI"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Check if unzip is available
    if ! command -v unzip &> /dev/null; then
        log_error "unzip is not installed or not in PATH"
        log_error "Please install unzip to extract the downloaded file"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Extract the zip file
    log_info "Extracting OpenCode CLI..."
    if ! unzip -q "$temp_file" -d "$temp_dir"; then
        log_error "Failed to extract OpenCode CLI"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Find the opencode binary (it might be in a subdirectory)
    local binary_path
    binary_path=$(find "$temp_dir" -name "opencode" -type f -perm +111 | head -1)

    if [[ -z "$binary_path" ]]; then
        log_error "Could not find opencode binary in extracted files"
        log_info "Contents of extracted directory:"
        find "$temp_dir" -type f | sed 's/^/  /'
        rm -rf "$temp_dir"
        exit 1
    fi

    # Move to installation directory
    mv "$binary_path" "$install_dir/opencode"

    # Clean up temporary directory
    rm -rf "$temp_dir"

    log_info "OpenCode CLI installed successfully to $install_dir/opencode"

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

    if [[ -x "$install_dir/opencode" ]]; then
        log_info "Installation verified successfully"
        log_info "OpenCode CLI version:"
        "$install_dir/opencode" --version 2>/dev/null || echo "  (version command may not be available)"
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Main function
main() {
    log_info "Starting OpenCode CLI installation..."

    # Check prerequisites
    check_gh_command

    # Check if jq is available for JSON parsing
    if ! command -v jq &> /dev/null; then
        log_error "jq is not installed or not in PATH"
        log_error "Please install jq for JSON parsing"
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

    log_info "Parsing version..."
    version=$(echo "$release_info" | jq -r '.tag_name')
    if [[ $? -ne 0 ]]; then
        log_error "Failed to parse version from release info"
        exit 1
    fi
    log_info "Latest version: $version"

    # Find download URL
    download_url=$(find_download_url "$release_info" "$arch" "$os")

    # Install opencode
    install_opencode "$download_url" "$version"

    # Verify installation
    verify_installation

    log_info "OpenCode CLI installation completed successfully!"
}

# Run main function
main "$@"
