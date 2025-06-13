#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect current shell and return appropriate config file
detect_shell_config() {
    local shell_name
    local config_file

    # Get the current shell from $SHELL or $0
    if [[ -n "${SHELL:-}" ]]; then
        shell_name=$(basename "$SHELL")
    else
        shell_name=$(basename "$0" | sed 's/^-//')
    fi

    case "$shell_name" in
        bash)
            config_file="$HOME/.bashrc"
            # On macOS, also check for .bash_profile if .bashrc doesn't exist
            if [[ ! -f "$config_file" && -f "$HOME/.bash_profile" ]]; then
                config_file="$HOME/.bash_profile"
            fi
            ;;
        zsh)
            config_file="$HOME/.zshrc"
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            ;;
        *)
            # Default to bashrc for unknown shells
            config_file="$HOME/.bashrc"
            print_warning "Unknown shell '$shell_name', defaulting to .bashrc"
            ;;
    esac

    echo "$config_file"
}

# Function to get aichat config directory with better error handling
get_aichat_config_dir() {
    local config_dir

    # First check if aichat is available
    if ! command_exists aichat; then
        print_error "aichat is not installed or not in PATH"
        exit 1
    fi

    # Try to get config directory from aichat --info
    # Handle the case where config doesn't exist yet
    local aichat_info_output
    if aichat_info_output=$(aichat --info 2>/dev/null); then
        config_dir=$(echo "$aichat_info_output" | grep "roles_dir" | sed 's/^roles_dir[[:space:]]*//' | sed 's|/roles$||')
    else
        # If aichat --info fails (e.g., no config), use default location
        print_warning "aichat --info failed, using default config location"
        case "$(uname -s)" in
            Darwin)
                config_dir="$HOME/Library/Application Support/aichat"
                ;;
            Linux)
                config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/aichat"
                ;;
            *)
                config_dir="$HOME/.aichat"
                ;;
        esac
    fi

    if [[ -z "$config_dir" ]]; then
        print_error "Failed to determine aichat config directory"
        exit 1
    fi

    # Create config directory if it doesn't exist
    if [[ ! -d "$config_dir" ]]; then
        print_info "Creating aichat config directory: $config_dir"
        mkdir -p "$config_dir"
    fi

    echo "$config_dir"
}

# Function to check if aichat config exists and download if needed
ensure_aichat_config() {
    local config_dir="$1"
    local config_file="$config_dir/config.yaml"

    print_info "Checking aichat configuration..."

    if [[ -f "$config_file" ]]; then
        print_success "aichat config file already exists: $config_file"
        return 0
    fi

    print_info "aichat config file not found. Downloading default configuration..."
    download_file \
        "https://gitlab.com/-/snippets/4862518/raw/main/config.yaml" \
        "$config_file" \
        "aichat configuration file"

    print_warning "IMPORTANT: You must edit $config_file and replace YOUR_API_KEY with your actual DeepSeek API key"
    print_info "Get your API key from: https://platform.deepseek.com/usage"
}

# Function to install aichat using brew
install_aichat() {
    print_info "Checking if aichat is installed..."

    if command_exists aichat; then
        print_success "aichat is already installed"
        return 0
    fi

    print_info "aichat not found. Installing via Homebrew..."

    if ! command_exists brew; then
        print_error "Homebrew is not installed. Please install Homebrew first."
        print_info "Visit: https://brew.sh/"
        exit 1
    fi

    print_info "Installing aichat..."
    if brew install aichat; then
        print_success "aichat installed successfully"
    else
        print_error "Failed to install aichat"
        exit 1
    fi
}

# Function to download file with error handling
download_file() {
    local url="$1"
    local destination="$2"
    local description="$3"

    # Check if file already exists
    if [[ -f "$destination" ]]; then
        print_success "$description already exists at: $destination"
        print_info "Skipping download"
        return 0
    fi

    print_info "Downloading $description..."
    print_info "URL: $url"
    print_info "Destination: $destination"

    # Ensure the parent directory exists
    local parent_dir
    parent_dir=$(dirname "$destination")
    if [[ ! -d "$parent_dir" ]]; then
        print_info "Creating parent directory: $parent_dir"
        mkdir -p "$parent_dir"
    fi

    if command_exists curl; then
        if curl -fsSL "$url" -o "$destination"; then
            print_success "Downloaded $description successfully"
            # Only chmod +x for shell scripts, not markdown files
            if [[ "$destination" == *.sh ]]; then
                chmod +x "$destination"
            fi
        else
            local curl_exit_code=$?
            print_error "Failed to download $description from $url"
            print_error "curl exit code: $curl_exit_code"
            print_error "This might be due to:"
            print_error "  - Network connectivity issues"
            print_error "  - File permissions in destination directory"
            print_error "  - Path with spaces not handled properly"
            exit 1
        fi
    elif command_exists wget; then
        if wget -q "$url" -O "$destination"; then
            print_success "Downloaded $description successfully"
            if [[ "$destination" == *.sh ]]; then
                chmod +x "$destination"
            fi
        else
            local wget_exit_code=$?
            print_error "Failed to download $description from $url"
            print_error "wget exit code: $wget_exit_code"
            exit 1
        fi
    else
        print_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
}

# Function to setup scripts directory
setup_scripts_directory() {
    local scripts_dir="$HOME/.config/ai-commit"

    print_info "Setting up AI commit scripts directory: $scripts_dir"

    # Create directory if it doesn't exist
    if [[ ! -d "$scripts_dir" ]]; then
        mkdir -p "$scripts_dir"
        print_success "Created directory: $scripts_dir"
    else
        print_info "Directory already exists: $scripts_dir"
    fi

    # Download git-commit-chunk-text.sh
    download_file \
        "https://gitlab.com/-/snippets/4862518/raw/main/git-commit-chunk-text.sh" \
        "$scripts_dir/git-commit-chunk-text.sh" \
        "git-commit-chunk-text.sh script"

    # Download git-commit-context.sh
    download_file \
        "https://gitlab.com/-/snippets/4862518/raw/main/git-commit-context.sh" \
        "$scripts_dir/git-commit-context.sh" \
        "git-commit-context.sh script"

    # Update shebang in scripts if modern bash was installed
    update_script_shebangs "$scripts_dir"

    print_success "All scripts downloaded to $scripts_dir"
}

# Function to update script shebangs to use modern bash if available
update_script_shebangs() {
    local scripts_dir="$1"
    # No longer updating shebangs for modern bash, keep original shebangs
    print_info "No modern bash detection needed, keeping original shebangs"
}

# Function to setup aichat role
setup_aichat_role() {
    local config_dir="$1"
    local roles_dir="$config_dir/roles"

    print_info "Setting up aichat role for git commits..."

    # Create roles directory if it doesn't exist
    if [[ ! -d "$roles_dir" ]]; then
        mkdir -p "$roles_dir"
        print_success "Created roles directory: $roles_dir"
    else
        print_info "Roles directory already exists: $roles_dir"
    fi

    # Download git-commit role
    download_file \
        "https://gitlab.com/-/snippets/4862518/raw/main/git-commit.md" \
        "$roles_dir/git-commit.md" \
        "git-commit role configuration"

    print_success "aichat git-commit role configured"
}

# Function to setup shell alias
setup_shell_alias() {
    local scripts_dir="$1"
    local config_file
    local shell_name
    local alias_name="ai-commit"
    local alias_command="\$HOME/.config/ai-commit/git-commit-context.sh | aichat --role git-commit -S | \$HOME/.config/ai-commit/git-commit-chunk-text.sh"

    # Detect current shell and get config file
    config_file=$(detect_shell_config)
    shell_name=$(basename "$(dirname "$config_file")" | sed 's/.*\.//')
    if [[ "$config_file" == *".bashrc"* ]] || [[ "$config_file" == *".bash_profile"* ]]; then
        shell_name="bash"
    elif [[ "$config_file" == *".zshrc"* ]]; then
        shell_name="zsh"
    elif [[ "$config_file" == *"fish"* ]]; then
        shell_name="fish"
    fi

    print_info "Setting up $shell_name alias '$alias_name' in $config_file..."

    # Check if config file exists, create if needed
    if [[ ! -f "$config_file" ]]; then
        print_warning "Config file not found. Creating it..."
        mkdir -p "$(dirname "$config_file")"
        touch "$config_file"
    fi

    # Check if alias already exists
    if grep -q "alias $alias_name=" "$config_file" 2>/dev/null; then
        print_warning "Alias '$alias_name' already exists in $config_file"
        echo "Current alias definition:"
        grep "alias $alias_name=" "$config_file"

        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping alias update"
            return 0
        fi

        # Remove existing alias
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/alias $alias_name=/d" "$config_file"
        else
            sed -i "/alias $alias_name=/d" "$config_file"
        fi
        print_info "Removed existing alias"
    fi

    # Add new alias (without color codes)
    {
        echo ""
        echo "# AI-powered git commit workflow"
        echo "alias $alias_name='$alias_command'"
    } >> "$config_file"

    print_success "Added '$alias_name' alias to $config_file"
    echo "Alias command: $alias_command"
    print_warning "Please run 'source $config_file' or restart your terminal to use the alias"
}

# Function to display usage instructions
display_usage_instructions() {
    local scripts_dir="$1"
    local config_dir="$2"
    local config_file="$3"

    echo
    print_success "=== AI Commit Workflow Setup Complete ==="
    echo
    print_info "📁 Scripts installed in: $scripts_dir"
    print_info "⚙️  aichat config directory: $config_dir"
    print_info "🎭 aichat role configured: git-commit"
    print_info "🔗 Shell alias created: ai-commit"
    print_info "📝 Shell config file: $config_file"
    echo
    print_info "📋 Usage Instructions:"
    echo "  1. Navigate to your git repository"
    echo "  2. Stage your changes: git add ."
    echo "  3. Run the AI commit workflow: ai-commit"
    echo
    print_info "🔧 Manual Usage (without alias):"
    echo "  $scripts_dir/git-commit-context.sh | aichat --role git-commit -S | $scripts_dir/git-commit-chunk-text.sh"
    echo
    print_info "⚡ Next Steps:"
    echo "  • Run 'source $config_file' to load the new alias"
    echo "  • Configure your API key in the aichat config file (see below)"
    echo "  • Test the workflow in a git repository with staged changes"
    echo
    print_info "🔧 aichat Configuration:"
    echo "  1. Edit the config file and replace YOUR_API_KEY with your actual API key:"
    echo "     # For nano editor:"
    echo "     nano $config_dir/config.yaml"
    echo "     # For vim editor:"
    echo "     vim $config_dir/config.yaml"
    echo "  2. Get your DeepSeek API key from: https://platform.deepseek.com/usage"
    echo
    print_warning "📝 Important Notes:"
    echo "  • Make sure you have staged changes before running ai-commit"
    echo "  • You MUST configure your API key in the config file for aichat to work"
    echo "  • If bash was updated, restart your terminal or source your shell config"
    echo "  • Modern bash (4.0+) is required for readarray support"
}

# Main function
main() {
    echo
    print_info "🚀 Setting up AI-powered Git Commit Workflow"
    print_info "This script will:"
    echo "   • Install aichat via Homebrew (if not already installed)"
    echo "   • Download required scripts to ~/.config/ai-commit/"
    echo "   • Setup aichat role for git commits"
    echo "   • Create shell alias 'ai-commit' in your shell config"
    echo

    # Install aichat
    install_aichat

    # Get aichat config directory (with better error handling)
    local config_dir
    config_dir=$(get_aichat_config_dir)
    print_info "aichat config directory: $config_dir"

    # Ensure aichat config file exists
    ensure_aichat_config "$config_dir"

    # Now we can safely test aichat
    if command_exists aichat; then
        print_info "Verifying aichat installation..."
        if aichat --version >/dev/null 2>&1; then
            print_success "aichat is working properly"
            aichat --version
        else
            print_warning "aichat version check failed - this might be due to missing API key configuration"
            print_info "aichat is installed but may need API key configuration to work fully"
        fi
    fi

    # Setup scripts directory and download scripts
    local scripts_dir="$HOME/.config/ai-commit"
    setup_scripts_directory > /dev/null

    # Setup aichat role
    setup_aichat_role "$config_dir"

    # Setup shell alias (now supports bash and zsh)
    local shell_config_file
    shell_config_file=$(detect_shell_config)
    setup_shell_alias "$scripts_dir"

    # Display usage instructions
    display_usage_instructions "$scripts_dir" "$config_dir" "$shell_config_file"
}

# Run main function
main "$@"

# curl -fsSL https://gitlab.com/-/snippets/4862518/raw/main/setup-ai-commit-workflow.sh | bash
