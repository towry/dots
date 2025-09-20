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

# Get latest release info
get_latest_release() {
    local auth_header=""
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
        local token
        token=$(gh auth token 2>/dev/null)
        if [[ -n "$token" ]]; then
            auth_header="Authorization: token $token"
        fi
    fi

    local latest_url="https://api.github.com/repos/elixir-lang/expert/releases/latest"
    local releases_url="https://api.github.com/repos/elixir-lang/expert/releases"
    local response

    # Try latest release first
    if [[ -n "$auth_header" ]]; then
        response=$(curl -s -H "$auth_header" "$latest_url" 2>/dev/null)
    else
        response=$(curl -s "$latest_url" 2>/dev/null)
    fi

    # Check if we got valid JSON with assets
    if echo "$response" | jq -e '.assets and (.assets | type == "array") and (.assets | length > 0)' >/dev/null 2>&1; then
        echo "$response"
        return
    fi

    # Fallback to releases list
    if [[ -n "$auth_header" ]]; then
        response=$(curl -s -H "$auth_header" "$releases_url" 2>/dev/null)
    else
        response=$(curl -s "$releases_url" 2>/dev/null)
    fi

    # Pick first release with assets (prefer non-prerelease, but allow prerelease)
    local selected_release
    selected_release=$(echo "$response" | jq 'map(select(.draft==false and (.assets|type=="array") and (.assets|length>0))) | sort_by(.prerelease) | .[0]' 2>/dev/null)

    if [[ -z "$selected_release" || "$selected_release" == "null" ]]; then
        echo '{"error": "No suitable release found"}' >&2
        return 1
    fi

    echo "$selected_release"
}

# Find download URL for the correct architecture
find_download_url() {

	local release_info="$1"
	local arch="$2"
	local os="$3"

	# Map to actual asset name pattern
	local asset_pattern=""
	if [[ "$os" == "apple-darwin" ]]; then
		if [[ "$arch" == "aarch64" ]]; then
			asset_pattern="expert_darwin_arm64"
		else
			asset_pattern="expert_darwin_amd64"
		fi
	elif [[ "$os" == "unknown-linux-gnu" ]]; then
		if [[ "$arch" == "aarch64" ]]; then
			asset_pattern="expert_linux_arm64"
		else
			asset_pattern="expert_linux_amd64"
		fi
	else
		log_error "Unsupported OS/arch combination: $os/$arch"
		exit 1
	fi

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

# Download and install expertls
install_expertls() {
	local download_url="$1"
	local version="$2"

	local install_dir="$HOME/.local/bin"
	mkdir -p "$install_dir"

	local temp_dir="/tmp/expertls-install-$$"
	mkdir -p "$temp_dir"

	local temp_file="$temp_dir/expertls"

	log_info "Downloading expertls version $version to $temp_dir..."
	log_info "Download URL: $download_url"

	if ! curl -L -o "$temp_file" "$download_url"; then
		log_error "Failed to download expertls"
		rm -rf "$temp_dir"
		exit 1
	fi

	chmod +x "$temp_file"
	mv "$temp_file" "$install_dir/expertls"

	rm -rf "$temp_dir"

	log_info "expertls installed successfully to $install_dir/expertls"

	if [[ ":$PATH:" != *":$install_dir:"* ]]; then
		log_warn "Warning: $install_dir is not in your PATH"
		log_warn "Add this line to your shell profile (.bashrc, .zshrc, etc.):"
		log_warn "export PATH=\"$HOME/.local/bin:$PATH\""
	fi
}

# Verify installation
verify_installation() {
	local install_dir="$HOME/.local/bin"

	if [[ -x "$install_dir/expertls" ]]; then
		log_info "Installation verified successfully"
		log_info "expertls binary is ready to use (no version command available yet)"
	else
		log_error "Installation verification failed"
		exit 1
	fi
}

# Main function
main() {
	log_info "Starting expertls installation..."

	check_gh_command

	if ! command -v jq &> /dev/null; then
		log_error "jq is not installed or not in PATH"
		log_error "Please install jq for JSON parsing"
		exit 1
	fi

	local arch os
	arch=$(detect_arch)
	os=$(detect_os)

	log_info "Detected architecture: $arch"
	log_info "Detected OS: $os"

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

	download_url=$(find_download_url "$release_info" "$arch" "$os")

	install_expertls "$download_url" "$version"

	verify_installation

	log_info "expertls installation completed successfully!"
}

main "$@"
