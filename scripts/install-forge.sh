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
        *)
            log_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
}

# Get release info for specific version or latest
get_release_info() {
    local version="$1"
    local endpoint="latest"
    
    if [[ "$version" != "latest" ]]; then
        endpoint="tags/$version"
        log_info "Fetching release information for version $version..." >&2
    else
        log_info "Fetching latest release information..." >&2
    fi

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
        curl -s -H "$auth_header" "https://api.github.com/repos/antinomyhq/forge/releases/$endpoint"
    else
        # Fallback to unauthenticated request (rate limited but works)
        curl -s "https://api.github.com/repos/antinomyhq/forge/releases/$endpoint"
    fi
}

# Find download URL for the correct architecture
find_download_url() {
    local release_info="$1"
    local arch="$2"
    local os="$3"

    # Construct the expected asset name pattern
    local asset_pattern="forge-${arch}-${os}"

    log_info "Looking for asset matching pattern: $asset_pattern" >&2

    local download_url
    download_url=$(echo "$release_info" | jq -r --arg pattern "$asset_pattern" '
        .assets[] |
        select(.name | contains($pattern)) |
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

# Download and install forge
install_forge() {
    local download_url="$1"
    local version="$2"

    # Create installation directory
    local install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"

    # Create temporary directory for download
    local temp_dir="/tmp/forge-install-$$"
    mkdir -p "$temp_dir"

    local temp_file="$temp_dir/forge"

    log_info "Downloading Forge CLI version $version to $temp_dir..."
    log_info "Download URL: $download_url"

    # Download the binary to /tmp
    if ! curl -L -o "$temp_file" "$download_url"; then
        log_error "Failed to download Forge CLI"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Make it executable and move to installation directory
    chmod +x "$temp_file"
    mv "$temp_file" "$install_dir/forge"

    # Clean up temporary directory
    rm -rf "$temp_dir"

    log_info "Forge CLI installed successfully to $install_dir/forge"

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

    if [[ -x "$install_dir/forge" ]]; then
        log_info "Installation verified successfully"
        log_info "Forge CLI version:"
        "$install_dir/forge" --version 2>/dev/null || echo "  (version command may not be available)"
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [VERSION]"
    echo "  VERSION: Optional version tag (e.g., v1.1.0, v1.0.0). If not specified, installs the latest version."
    echo ""
    echo "Examples:"
    echo "  $0          # Install latest version"
    echo "  $0 v1.1.0   # Install specific version v1.1.0"
}

# Main function
main() {
    local version="${1:-latest}"
    
    # Handle help flag
    if [[ "$version" == "-h" || "$version" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    log_info "Starting Forge CLI installation..."

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

    # Get release info and process it
    log_info "Getting release information..."
    local release_info download_url
    release_info=$(get_release_info "$version")

    if [[ $? -ne 0 ]] || [[ -z "$release_info" ]]; then
        log_error "Failed to get release information for version: $version"
        exit 1
    fi

    # Check if release exists
    local release_message
    release_message=$(echo "$release_info" | jq -r '.message // empty')
    if [[ -n "$release_message" && "$release_message" == "Not Found" ]]; then
        log_error "Version $version not found"
        log_error "Please check available releases at: https://github.com/antinomyhq/forge/releases"
        exit 1
    fi

    log_info "Parsing version..."
    local parsed_version
    parsed_version=$(echo "$release_info" | jq -r '.tag_name')
    if [[ $? -ne 0 || "$parsed_version" == "null" ]]; then
        log_error "Failed to parse version from release info"
        exit 1
    fi
    
    if [[ "$version" == "latest" ]]; then
        log_info "Latest version: $parsed_version"
    else
        log_info "Installing version: $parsed_version"
    fi
    
    # Find download URL
    download_url=$(find_download_url "$release_info" "$arch" "$os")

    # Install forge
    install_forge "$download_url" "$parsed_version"

    # Verify installation
    verify_installation

    log_info "Forge CLI installation completed successfully!"
}

# Run main function
main "$@"
