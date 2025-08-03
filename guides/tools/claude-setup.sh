#!/bin/bash
# ============================================================================
# Claude YOLO Mode Setup for Windows Git Bash, Linux & macOS
# Automatically configures Claude Code YOLO mode (assumes Claude is installed)
# ============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Windows Git Bash detection
IS_WINDOWS_GIT_BASH=false
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$MSYSTEM" ]]; then
    IS_WINDOWS_GIT_BASH=true
fi

# Emoji support check - Windows Git Bash generally supports emojis
if [ "$IS_WINDOWS_GIT_BASH" = true ]; then
    EMOJI_SUPPORT=true
elif locale charmap 2>/dev/null | grep -qi utf; then
    EMOJI_SUPPORT=true
else
    EMOJI_SUPPORT=false
fi

# Emoji functions
emoji() {
    if [ "$EMOJI_SUPPORT" = true ]; then
        echo "$1"
    else
        echo "$2"
    fi
}

# Print functions
print_header() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$(emoji "✅" "[OK]") $1${NC}"
}

print_error() {
    echo -e "${RED}$(emoji "❌" "[ERROR]") $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$(emoji "⚠️" "[WARNING]") $1${NC}"
}

print_info() {
    echo -e "${BLUE}$(emoji "💡" "[INFO]") $1${NC}"
}

print_step() {
    echo -e "${CYAN}$(emoji "🔧" "[STEP]") $1${NC}"
}

print_header "$(emoji "🚀" "") Claude YOLO Mode Setup for Windows Git Bash/Unix Systems"
echo

# Detect operating system and shell
detect_os() {
    if [ "$IS_WINDOWS_GIT_BASH" = true ]; then
        OS="windows"
        print_info "Detected operating system: Windows (Git Bash)"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_info "Detected operating system: macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        print_info "Detected operating system: Linux"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

detect_shell() {
    CURRENT_SHELL=$(basename "$SHELL")
    print_info "Detected shell: $CURRENT_SHELL"

    case "$CURRENT_SHELL" in
        "bash")
            if [ "$OS" = "windows" ]; then
                # Windows Git Bash typically uses .bashrc
                PROFILE_FILE="$HOME/.bashrc"
            elif [ "$OS" = "macos" ]; then
                PROFILE_FILE="$HOME/.bash_profile"
            else
                PROFILE_FILE="$HOME/.bashrc"
            fi
            SHELL_TYPE="bash"
            ;;
        "zsh")
            PROFILE_FILE="$HOME/.zshrc"
            SHELL_TYPE="zsh"
            ;;
        "fish")
            PROFILE_FILE="$HOME/.config/fish/config.fish"
            SHELL_TYPE="fish"
            ;;
        *)
            print_warning "Unsupported shell: $CURRENT_SHELL, defaulting to bash"
            if [ "$OS" = "windows" ]; then
                PROFILE_FILE="$HOME/.bashrc"
            elif [ "$OS" = "macos" ]; then
                PROFILE_FILE="$HOME/.bash_profile"
            else
                PROFILE_FILE="$HOME/.bashrc"
            fi
            SHELL_TYPE="bash"
            ;;
    esac

    print_info "Profile file: $PROFILE_FILE"
}

# Check if directory exists, create if not
ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        print_step "Creating directory: $dir"
        mkdir -p "$dir"
        print_success "Directory created successfully"
    else
        print_success "Directory already exists"
    fi
}

# Backup existing profile
backup_profile() {
    if [ -f "$PROFILE_FILE" ]; then
        local backup_file="${PROFILE_FILE}.backup.$(date +%Y%m%d-%H%M%S)"
        print_step "Creating backup: $backup_file"
        cp "$PROFILE_FILE" "$backup_file"
        print_success "Backup created successfully"
        BACKUP_CREATED="$backup_file"
    else
        print_info "No existing profile to backup"
        BACKUP_CREATED=""
        # Create the profile file
        touch "$PROFILE_FILE"
        print_info "Created new profile file: $PROFILE_FILE"
    fi
}

# Find Claude executable
find_claude_executable() {
    print_step "Searching for Claude executable..."

    # Windows-specific paths for Git Bash
    if [ "$IS_WINDOWS_GIT_BASH" = true ]; then
        # Check Windows specific locations first
        local windows_paths=(
            "$HOME/.npm-global/claude"
            "$HOME/AppData/Roaming/npm/claude"
            "$HOME/AppData/Roaming/npm/claude.cmd"
            "/c/Program Files/nodejs/claude"
            "/c/Program Files/nodejs/claude.cmd"
            "/c/Program Files (x86)/nodejs/claude"
            "/c/Program Files (x86)/nodejs/claude.cmd"
        )
        
        for path in "${windows_paths[@]}"; do
            if [ -f "$path" ]; then
                # Convert Windows path to Unix path if needed
                CLAUDE_PATH="$path"
                print_success "Found Claude at: $CLAUDE_PATH"
                return 0
            fi
        done
        
        # Check if claude.cmd exists in PATH (Windows npm global install)
        if command -v claude.cmd >/dev/null 2>&1; then
            CLAUDE_PATH="claude.cmd"
            print_success "Found Claude in PATH: $CLAUDE_PATH"
            return 0
        fi
    fi

    # First check if claude is in PATH
    if command -v claude >/dev/null 2>&1; then
        CLAUDE_PATH=$(which claude)
        print_success "Found Claude in PATH: $CLAUDE_PATH"
        return 0
    fi

    # Common installation paths
    local search_paths=(
        "$HOME/.local/bin/claude"
        "$HOME/bin/claude"
        "/usr/local/bin/claude"
        "/usr/bin/claude"
        "/opt/homebrew/bin/claude"  # macOS Homebrew (Apple Silicon)
        "/usr/local/lib/node_modules/@anthropic-ai/claude-code/bin/claude"
        "$HOME/.npm/bin/claude"
        "$HOME/.volta/bin/claude"
        "$HOME/.asdf/shims/claude"
    )

    # Search in common paths
    for path in "${search_paths[@]}"; do
        if [ -f "$path" ] && [ -x "$path" ]; then
            CLAUDE_PATH="$path"
            print_success "Found Claude at: $CLAUDE_PATH"
            return 0
        fi
    done

    print_error "Claude executable not found!"
    print_info "Please make sure Claude Code is installed: npm install -g @anthropic-ai/claude-code"
    return 1
}

# Generate Bash/Zsh configuration
generate_bash_zsh_config() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    cat << EOF
# ============================================================================
# Advanced Claude YOLO Configuration for Bash/Zsh
# Generated on $timestamp
# ============================================================================

CLAUDE_PATH="$CLAUDE_PATH"
CLAUDE_STATE_FILE="\$HOME/.claude-mode-state"

# Check if Claude executable exists
if [ ! -f "\$CLAUDE_PATH" ] || [ ! -x "\$CLAUDE_PATH" ]; then
    echo "$(emoji "❌" "[ERROR]") Claude executable not found at: \$CLAUDE_PATH" >&2
    echo "$(emoji "💡" "[INFO]") Please reinstall Claude Code with: npm install -g @anthropic-ai/claude-code" >&2
    return 2>/dev/null || true
fi

# State management functions
save_claude_state() {
    echo "\$1" > "\$CLAUDE_STATE_FILE" 2>/dev/null || true
}

load_claude_state() {
    if [ -f "\$CLAUDE_STATE_FILE" ]; then
        cat "\$CLAUDE_STATE_FILE" 2>/dev/null | tr -d '\\n' || echo "yolo"
    else
        echo "yolo"
    fi
}

set_claude_yolo_mode() {
    local silent="\$1"

    if [ "\$silent" != "silent" ]; then
        echo "$(emoji "🚀" "[YOLO]") Setting Claude to YOLO mode"
    fi

    claude() {
        "\$CLAUDE_PATH" --dangerously-skip-permissions "\$@"
    }

    save_claude_state "yolo"
}

set_claude_normal_mode() {
    local silent="\$1"

    if [ "\$silent" != "silent" ]; then
        echo "$(emoji "🛡️" "[SAFE]") Setting Claude to SAFE mode"
    fi

    claude() {
        "\$CLAUDE_PATH" "\$@"
    }

    save_claude_state "safe"
}

# User-friendly functions
claude-safe() {
    "\$CLAUDE_PATH" "\$@"
}

claude-yolo() {
    set_claude_yolo_mode
}

claude-normal() {
    set_claude_normal_mode
}

claude-status() {
    echo "$(emoji "📊" "[STATUS]") Claude Status Report:"
    echo "  ════════════════════════════════════════════════════════════════"

    # Check current mode by testing function
    if type claude >/dev/null 2>&1; then
        if declare -f claude 2>/dev/null | grep -q "dangerously-skip-permissions"; then
            echo "  $(emoji "🚀" "") Current mode: YOLO"
        else
            echo "  $(emoji "🛡️" "") Current mode: SAFE"
        fi
    else
        echo "  $(emoji "❓" "") Current mode: Not set"
    fi

    # Show saved state
    local saved_mode
    saved_mode=\$(load_claude_state)
    echo "  $(emoji "💾" "") Saved mode: \$(echo "\$saved_mode" | tr '[:lower:]' '[:upper:]')"

    # Show executable path and validation
    echo "  $(emoji "📁" "") Executable: \$CLAUDE_PATH"
    if [ -f "\$CLAUDE_PATH" ] && [ -x "\$CLAUDE_PATH" ]; then
        echo "  $(emoji "✅" "") Path status: Valid"

        # Version check
        local version
        if version=\$("\$CLAUDE_PATH" --version 2>/dev/null); then
            echo "  $(emoji "📦" "") Version: \$version"
        else
            echo "  $(emoji "📦" "") Version: Unable to determine"
        fi
    else
        echo "  $(emoji "❌" "") Path status: Invalid!"
    fi

    echo "  ════════════════════════════════════════════════════════════════"
}

claude-reset() {
    echo "$(emoji "🔄" "[RESET]") Resetting Claude configuration..."
    rm -f "\$CLAUDE_STATE_FILE"
    set_claude_yolo_mode silent
    echo "$(emoji "✅" "[OK]") Reset to default (YOLO mode)"
}

claude-path() {
    echo "$(emoji "📁" "[PATH]") Claude Executable Information:"
    echo "  Path: \$CLAUDE_PATH"

    if [ -f "\$CLAUDE_PATH" ] && [ -x "\$CLAUDE_PATH" ]; then
        echo "  Status: $(emoji "✅" "") Valid"
        if [ "$OS" = "macos" ]; then
            local file_size
            file_size=\$(stat -f%z "\$CLAUDE_PATH" 2>/dev/null || echo "Unknown")
            local mod_time
            mod_time=\$(stat -f%Sm "\$CLAUDE_PATH" 2>/dev/null || echo "Unknown")
        elif [ "$OS" = "windows" ]; then
            # Windows Git Bash stat command
            local file_size
            file_size=\$(stat --format=%s "\$CLAUDE_PATH" 2>/dev/null || echo "Unknown")
            local mod_time
            mod_time=\$(stat --format=%y "\$CLAUDE_PATH" 2>/dev/null || echo "Unknown")
        else
            local file_size
            file_size=\$(stat -c%s "\$CLAUDE_PATH" 2>/dev/null || echo "Unknown")
            local mod_time
            mod_time=\$(stat -c%y "\$CLAUDE_PATH" 2>/dev/null || echo "Unknown")
        fi
        echo "  Size: \$file_size bytes"
        echo "  Modified: \$mod_time"
    else
        echo "  Status: $(emoji "❌" "") Invalid!"
        echo "  $(emoji "💡" "") Try reinstalling: npm install -g @anthropic-ai/claude-code"
    fi
}

claude-help() {
    echo "$(emoji "🎯" "[HELP]") Claude PowerShell Commands:"
    echo "  ════════════════════════════════════════════════════════════════"
    echo "  $(emoji "🚀" "") claude          - Run Claude in current mode"
    echo "  $(emoji "🛡️" "") claude-safe     - Run Claude in safe mode (one-time)"
    echo "  $(emoji "🎚️" "") claude-yolo     - Switch to YOLO mode (persistent)"
    echo "  $(emoji "🎚️" "") claude-normal   - Switch to SAFE mode (persistent)"
    echo "  $(emoji "📊" "") claude-status   - Show detailed status report"
    echo "  $(emoji "🔄" "") claude-reset    - Reset to default configuration"
    echo "  $(emoji "📁" "") claude-path     - Show executable path info"
    echo "  $(emoji "❓" "") claude-help     - Show this help message"
    echo "  $(emoji "⚡" "") cy             - Alias for claude command"
    echo "  ════════════════════════════════════════════════════════════════"
    echo "  $(emoji "💡" "") Tip: Use 'claude-status' to check current configuration"
}

# Aliases
alias cy='claude'
alias c='claude'
alias help-claude='claude-help'

# Initialize mode based on saved state
initialize_claude_mode() {
    local initial_mode
    initial_mode=\$(load_claude_state)

    if [ "\$initial_mode" = "yolo" ]; then
        set_claude_yolo_mode silent
    else
        set_claude_normal_mode silent
    fi

    local current_mode_display
    if [ "\$initial_mode" = "yolo" ]; then
        current_mode_display="YOLO $(emoji "🚀" "")"
    else
        current_mode_display="SAFE $(emoji "🛡️" "")"
    fi

    echo "$(emoji "✅" "[OK]") Claude configuration loaded successfully!"
    echo "$(emoji "🎯" "[MODE]") Current mode: \$current_mode_display"
    echo "$(emoji "💡" "[TIP]") Type 'claude-help' for available commands"
}

# Initialize on profile load
initialize_claude_mode

# ============================================================================
# End of Claude Configuration
# ============================================================================
EOF
}

# Generate Fish shell configuration
generate_fish_config() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    cat << EOF
# ============================================================================
# Advanced Claude YOLO Configuration for Fish Shell
# Generated on $timestamp
# ============================================================================

set -g CLAUDE_PATH "$CLAUDE_PATH"
set -g CLAUDE_STATE_FILE "\$HOME/.claude-mode-state"

# Check if Claude executable exists
if not test -f "\$CLAUDE_PATH" -o -x "\$CLAUDE_PATH"
    echo "$(emoji "❌" "[ERROR]") Claude executable not found at: \$CLAUDE_PATH" >&2
    echo "$(emoji "💡" "[INFO]") Please reinstall Claude Code with: npm install -g @anthropic-ai/claude-code" >&2
    return
end

# State management functions
function save_claude_state
    echo \$argv[1] > \$CLAUDE_STATE_FILE 2>/dev/null; or true
end

function load_claude_state
    if test -f \$CLAUDE_STATE_FILE
        cat \$CLAUDE_STATE_FILE 2>/dev/null | tr -d '\\n'; or echo "yolo"
    else
        echo "yolo"
    end
end

function set_claude_yolo_mode
    set -l silent \$argv[1]

    if test "\$silent" != "silent"
        echo "$(emoji "🚀" "[YOLO]") Setting Claude to YOLO mode"
    end

    function claude
        \$CLAUDE_PATH --dangerously-skip-permissions \$argv
    end

    save_claude_state "yolo"
    funcsave claude
end

function set_claude_normal_mode
    set -l silent \$argv[1]

    if test "\$silent" != "silent"
        echo "$(emoji "🛡️" "[SAFE]") Setting Claude to SAFE mode"
    end

    function claude
        \$CLAUDE_PATH \$argv
    end

    save_claude_state "safe"
    funcsave claude
end

# User-friendly functions
function claude-safe
    \$CLAUDE_PATH \$argv
end

function claude-yolo
    set_claude_yolo_mode
end

function claude-normal
    set_claude_normal_mode
end

function claude-status
    echo "$(emoji "📊" "[STATUS]") Claude Status Report:"
    echo "  ════════════════════════════════════════════════════════════════"

    # Check current mode
    if functions -q claude
        if functions claude | grep -q "dangerously-skip-permissions"
            echo "  $(emoji "🚀" "") Current mode: YOLO"
        else
            echo "  $(emoji "🛡️" "") Current mode: SAFE"
        end
    else
        echo "  $(emoji "❓" "") Current mode: Not set"
    end

    # Show saved state
    set -l saved_mode (load_claude_state)
    echo "  $(emoji "💾" "") Saved mode: "(echo \$saved_mode | tr '[:lower:]' '[:upper:]')

    # Show executable path and validation
    echo "  $(emoji "📁" "") Executable: \$CLAUDE_PATH"
    if test -f "\$CLAUDE_PATH" -a -x "\$CLAUDE_PATH"
        echo "  $(emoji "✅" "") Path status: Valid"

        # Version check
        set -l version (\$CLAUDE_PATH --version 2>/dev/null)
        if test -n "\$version"
            echo "  $(emoji "📦" "") Version: \$version"
        else
            echo "  $(emoji "📦" "") Version: Unable to determine"
        end
    else
        echo "  $(emoji "❌" "") Path status: Invalid!"
    end

    echo "  ════════════════════════════════════════════════════════════════"
end

function claude-reset
    echo "$(emoji "🔄" "[RESET]") Resetting Claude configuration..."
    rm -f \$CLAUDE_STATE_FILE
    set_claude_yolo_mode silent
    echo "$(emoji "✅" "[OK]") Reset to default (YOLO mode)"
end

function claude-path
    echo "$(emoji "📁" "[PATH]") Claude Executable Information:"
    echo "  Path: \$CLAUDE_PATH"

    if test -f "\$CLAUDE_PATH" -a -x "\$CLAUDE_PATH"
        echo "  Status: $(emoji "✅" "") Valid"
        set -l file_size (stat -c%s "\$CLAUDE_PATH" 2>/dev/null; or echo "Unknown")
        set -l mod_time (stat -c%y "\$CLAUDE_PATH" 2>/dev/null; or echo "Unknown")
        echo "  Size: \$file_size bytes"
        echo "  Modified: \$mod_time"
    else
        echo "  Status: $(emoji "❌" "") Invalid!"
        echo "  $(emoji "💡" "") Try reinstalling: npm install -g @anthropic-ai/claude-code"
    end
end

function claude-help
    echo "$(emoji "🎯" "[HELP]") Claude Fish Shell Commands:"
    echo "  ════════════════════════════════════════════════════════════════"
    echo "  $(emoji "🚀" "") claude          - Run Claude in current mode"
    echo "  $(emoji "🛡️" "") claude-safe     - Run Claude in safe mode (one-time)"
    echo "  $(emoji "🎚️" "") claude-yolo     - Switch to YOLO mode (persistent)"
    echo "  $(emoji "🎚️" "") claude-normal   - Switch to SAFE mode (persistent)"
    echo "  $(emoji "📊" "") claude-status   - Show detailed status report"
    echo "  $(emoji "🔄" "") claude-reset    - Reset to default configuration"
    echo "  $(emoji "📁" "") claude-path     - Show executable path info"
    echo "  $(emoji "❓" "") claude-help     - Show this help message"
    echo "  $(emoji "⚡" "") cy             - Alias for claude command"
    echo "  ════════════════════════════════════════════════════════════════"
    echo "  $(emoji "💡" "") Tip: Use 'claude-status' to check current configuration"
end

# Aliases
alias cy='claude'
alias c='claude'
alias help-claude='claude-help'

# Initialize mode based on saved state
function initialize_claude_mode
    set -l initial_mode (load_claude_state)

    if test "\$initial_mode" = "yolo"
        set_claude_yolo_mode silent
    else
        set_claude_normal_mode silent
    end

    set -l current_mode_display
    if test "\$initial_mode" = "yolo"
        set current_mode_display "YOLO $(emoji "🚀" "")"
    else
        set current_mode_display "SAFE $(emoji "🛡️" "")"
    end

    echo "$(emoji "✅" "[OK]") Claude configuration loaded successfully!"
    echo "$(emoji "🎯" "[MODE]") Current mode: \$current_mode_display"
    echo "$(emoji "💡" "[TIP]") Type 'claude-help' for available commands"
end

# Initialize on profile load
initialize_claude_mode

# Save functions for persistence
funcsave save_claude_state
funcsave load_claude_state
funcsave set_claude_yolo_mode
funcsave set_claude_normal_mode
funcsave claude-safe
funcsave claude-yolo
funcsave claude-normal
funcsave claude-status
funcsave claude-reset
funcsave claude-path
funcsave claude-help
funcsave initialize_claude_mode

# ============================================================================
# End of Claude Configuration
# ============================================================================
EOF
}

# Main execution
main() {
    detect_os
    detect_shell

    # Ensure profile directory exists
    profile_dir=$(dirname "$PROFILE_FILE")
    ensure_directory "$profile_dir"

    # Backup existing profile
    backup_profile

    # Find Claude executable
    if ! find_claude_executable; then
        print_error "Cannot proceed without Claude executable"
        exit 1
    fi

    # Generate appropriate configuration
    print_step "Generating shell configuration..."

    case "$SHELL_TYPE" in
        "bash"|"zsh")
            generate_bash_zsh_config >> "$PROFILE_FILE"
            ;;
        "fish")
            generate_fish_config >> "$PROFILE_FILE"
            ;;
        *)
            print_error "Unsupported shell type: $SHELL_TYPE"
            exit 1
            ;;
    esac

    print_success "Configuration written to: $PROFILE_FILE"

    # Validate configuration
    print_step "Validating configuration..."
    case "$SHELL_TYPE" in
        "bash"|"zsh")
            if bash -n "$PROFILE_FILE"; then
                print_success "Configuration syntax is valid"
            else
                print_warning "Configuration syntax validation failed"
            fi
            ;;
        "fish")
            if fish -n "$PROFILE_FILE" 2>/dev/null; then
                print_success "Configuration syntax is valid"
            else
                print_warning "Configuration syntax validation failed"
            fi
            ;;
    esac

    # Final instructions
    print_header "$(emoji "🎉" "") Setup completed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Profile file: $PROFILE_FILE"
    if [ -n "$BACKUP_CREATED" ]; then
        print_info "Backup created: $BACKUP_CREATED"
    fi
    print_info "Claude path: $CLAUDE_PATH"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo
    print_step "Next steps:"
    echo "  1️⃣  Reload your shell profile: source $PROFILE_FILE"
    echo "  2️⃣  Or restart your terminal"
    echo "  3️⃣  Test with: claude-status"
    echo "  4️⃣  Get help with: claude-help"
    echo "  5️⃣  Try Claude: claude --help"

    echo
    print_step "If you encounter issues:"
    echo "  • Run 'claude-status' to check configuration"
    echo "  • Run 'claude-path' to verify executable path"
    echo "  • Run 'claude-reset' to restore defaults"

    print_info "Please restart your terminal or run: source $PROFILE_FILE"
}

# Run main function
main "$@"
