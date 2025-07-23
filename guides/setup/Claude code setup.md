# Claude Code 설정 가이드

Claude Alias를 `cy`로 설정하고 YOLO 모드 제어 기능을 설정합니다. 각 OS에 맞게 수행하고 터미널을 다시 열면 됩니다.

## Windows PowerShell 설정

아래 스크립트를 PowerShell에서 실행하세요:

```powershell
# PowerShell 프로필 자동 생성 및 Claude 설정
Write-Host "🔧 Checking PowerShell profile setup..." -ForegroundColor Cyan

# 1. 프로필 경로 확인 및 표시
Write-Host "📁 Profile path: $PROFILE" -ForegroundColor Gray

# 2. 프로필 디렉토리 확인 및 생성
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    Write-Host "📂 Creating profile directory: $profileDir" -ForegroundColor Yellow
    try {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-Host "✅ Profile directory created successfully!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to create profile directory: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Profile directory already exists" -ForegroundColor Green
}

# 3. 프로필 파일 확인 및 생성
if (-not (Test-Path $PROFILE)) {
    Write-Host "📄 Creating profile file: $PROFILE" -ForegroundColor Yellow
    try {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        Write-Host "✅ Profile file created successfully!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to create profile file: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Profile file already exists" -ForegroundColor Green
    
    # 기존 프로필 백업
    $backupPath = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "💾 Creating backup: $backupPath" -ForegroundColor Yellow
    Copy-Item $PROFILE $backupPath -ErrorAction SilentlyContinue
}

# 4. Claude 실행 파일의 전체 경로 찾기
Write-Host "`n🔍 Searching for Claude executable..." -ForegroundColor Cyan

# 여러 위치에서 Claude 찾기
function Find-ClaudeExecutable {
    $searchPaths = @(
        "$env:APPDATA\npm",
        "$env:PROGRAMFILES\nodejs",
        "$env:PROGRAMFILES\nodejs\node_modules\.bin",
        "$env:USERPROFILE\AppData\Roaming\npm",
        "$env:LOCALAPPDATA\npm",
        "$env:ProgramFiles(x86)\nodejs"
    )
    
    Write-Host "🔍 Searching in the following locations:" -ForegroundColor Gray
    foreach ($searchPath in $searchPaths) {
        Write-Host "   - $searchPath" -ForegroundColor Gray
    }
    
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            $claudeFiles = Get-ChildItem -Path $searchPath -Filter "claude*" -Recurse -ErrorAction SilentlyContinue
            if ($claudeFiles) {
                Write-Host "📁 Found Claude files in $searchPath :" -ForegroundColor Green
                $claudeFiles | ForEach-Object { Write-Host "     $($_.FullName)" -ForegroundColor White }
                
                # .cmd 파일을 우선 선택
                $claudeCmd = $claudeFiles | Where-Object { $_.Extension -eq ".cmd" } | Select-Object -First 1
                if ($claudeCmd) {
                    return $claudeCmd.FullName
                }
                # .cmd가 없으면 첫 번째 파일
                return $claudeFiles[0].FullName
            }
        }
    }
    
    # PATH에서 찾기 시도
    Write-Host "🔍 Searching in system PATH..." -ForegroundColor Gray
    $pathClaude = Get-Command claude -ErrorAction SilentlyContinue
    if ($pathClaude) {
        Write-Host "✅ Found Claude in PATH: $($pathClaude.Source)" -ForegroundColor Green
        return $pathClaude.Source
    }
    
    return $null
}

$claudePath = Find-ClaudeExecutable

if (-not $claudePath) {
    Write-Host "❌ Claude not found in any location!" -ForegroundColor Red
    Write-Host "💡 Please install Claude Code with: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    Write-Host "🔧 Or check if Node.js is properly installed" -ForegroundColor Yellow
    
    # Node.js 설치 상태 확인
    try {
        $nodeVersion = node --version
        $npmVersion = npm --version
        Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
        Write-Host "✅ npm version: $npmVersion" -ForegroundColor Green
        Write-Host "💡 Try running: npm install -g @anthropic-ai/claude-code" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Node.js not found. Please install Node.js first from https://nodejs.org" -ForegroundColor Red
    }
    
    exit 1
}

Write-Host "✅ Using Claude path: $claudePath" -ForegroundColor Green

# 5. 프로필 파일에 고급 Claude 설정 작성
Write-Host "`n⚙️ Writing advanced Claude configuration to profile..." -ForegroundColor Cyan

@"
# ============================================================================
# Advanced Claude YOLO Configuration
# Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# ============================================================================

`$claudePath = '$claudePath'
`$ClaudeStateFile = "`$env:USERPROFILE\.claude-mode-state"

# Profile initialization check
if (-not `$claudePath -or -not (Test-Path `$claudePath)) {
    Write-Host "❌ Claude executable not found at: `$claudePath" -ForegroundColor Red
    Write-Host "💡 Please reinstall Claude Code with: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    return
}

# State management functions
function Save-ClaudeState {
    param([string]`$Mode)
    try {
        `$Mode | Out-File -FilePath `$ClaudeStateFile -Encoding UTF8 -ErrorAction Stop
    } catch {
        Write-Host "⚠️ Warning: Could not save Claude state" -ForegroundColor Yellow
    }
}

function Load-ClaudeState {
    if (Test-Path `$ClaudeStateFile) {
        try {
            `$savedMode = Get-Content `$ClaudeStateFile -Raw -ErrorAction Stop
            return `$savedMode.Trim()
        } catch {
            Write-Host "⚠️ Warning: Could not load Claude state, using default" -ForegroundColor Yellow
        }
    }
    return "yolo"  # Default mode
}

function Set-ClaudeYoloMode {
    param([switch]`$Silent)
    
    if (-not `$Silent) {
        Write-Host "🚀 Setting Claude to YOLO mode" -ForegroundColor Green
    }
    
    Remove-Item Function:\claude -ErrorAction SilentlyContinue
    function global:claude { 
        & `$claudePath --dangerously-skip-permissions `$args 
    }
    Save-ClaudeState "yolo"
}

function Set-ClaudeNormalMode {
    param([switch]`$Silent)
    
    if (-not `$Silent) {
        Write-Host "🛡️ Setting Claude to SAFE mode" -ForegroundColor Yellow
    }
    
    Remove-Item Function:\claude -ErrorAction SilentlyContinue
    function global:claude { 
        & `$claudePath `$args 
    }
    Save-ClaudeState "safe"
}

# User-friendly functions
function claude-safe { 
    & `$claudePath @args 
}

function claude-yolo { 
    Set-ClaudeYoloMode
}

function claude-normal { 
    Set-ClaudeNormalMode
}

function claude-status {
    Write-Host "📊 Claude Status Report:" -ForegroundColor Cyan
    Write-Host "  ═══════════════════════════════════════" -ForegroundColor Gray
    
    # Current mode
    `$claudeFunction = Get-Command claude -ErrorAction SilentlyContinue
    if (`$claudeFunction -and `$claudeFunction.Definition -like "*dangerously-skip-permissions*") {
        Write-Host "  🚀 Current mode: YOLO" -ForegroundColor Green
    } else {
        Write-Host "  🛡️ Current mode: SAFE" -ForegroundColor Yellow
    }
    
    # Saved state
    if (Test-Path `$ClaudeStateFile) {
        `$savedMode = (Get-Content `$ClaudeStateFile -Raw -ErrorAction SilentlyContinue).Trim()
        Write-Host "  💾 Saved mode: `$(`$savedMode.ToUpper())" -ForegroundColor Gray
    } else {
        Write-Host "  💾 Saved mode: Not set" -ForegroundColor Gray
    }
    
    # Executable path and validation
    Write-Host "  📁 Executable: `$claudePath" -ForegroundColor Gray
    if (Test-Path `$claudePath) {
        Write-Host "  ✅ Path status: Valid" -ForegroundColor Green
        
        # Version check
        try {
            `$version = & `$claudePath --version 2>`$null
            if (`$version) {
                Write-Host "  📦 Version: `$version" -ForegroundColor Gray
            } else {
                Write-Host "  📦 Version: Unable to determine" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  📦 Version: Error checking version" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ❌ Path status: Invalid!" -ForegroundColor Red
    }
    
    Write-Host "  ═══════════════════════════════════════" -ForegroundColor Gray
}

function claude-reset {
    Write-Host "🔄 Resetting Claude configuration..." -ForegroundColor Yellow
    Remove-Item `$ClaudeStateFile -ErrorAction SilentlyContinue
    Set-ClaudeYoloMode -Silent
    Write-Host "✅ Reset to default (YOLO mode)" -ForegroundColor Green
}

function claude-path {
    Write-Host "📁 Claude Executable Information:" -ForegroundColor Cyan
    Write-Host "  Path: `$claudePath" -ForegroundColor White
    
    if (Test-Path `$claudePath) {
        Write-Host "  Status: ✅ Valid" -ForegroundColor Green
        `$fileInfo = Get-Item `$claudePath
        Write-Host "  Size: `$([math]::Round(`$fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray
        Write-Host "  Modified: `$(`$fileInfo.LastWriteTime)" -ForegroundColor Gray
    } else {
        Write-Host "  Status: ❌ Invalid!" -ForegroundColor Red
        Write-Host "  💡 Try reinstalling: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    }
}

function claude-help {
    Write-Host "🎯 Claude PowerShell Commands:" -ForegroundColor Cyan
    Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "  🚀 claude          - Run Claude in current mode" -ForegroundColor White
    Write-Host "  🛡️ claude-safe     - Run Claude in safe mode (one-time)" -ForegroundColor White
    Write-Host "  🎚️ claude-yolo     - Switch to YOLO mode (persistent)" -ForegroundColor White
    Write-Host "  🎚️ claude-normal   - Switch to SAFE mode (persistent)" -ForegroundColor White
    Write-Host "  📊 claude-status   - Show detailed status report" -ForegroundColor White
    Write-Host "  🔄 claude-reset    - Reset to default configuration" -ForegroundColor White
    Write-Host "  📁 claude-path     - Show executable path info" -ForegroundColor White
    Write-Host "  ❓ claude-help     - Show this help message" -ForegroundColor White
    Write-Host "  ⚡ cy             - Alias for claude command" -ForegroundColor White
    Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "  💡 Tip: Use 'claude-status' to check current configuration" -ForegroundColor Yellow
}

# Aliases
Set-Alias -Name cy -Value claude
Set-Alias -Name c -Value claude
Set-Alias -Name help-claude -Value claude-help

# Profile initialization
try {
    `$initialMode = Load-ClaudeState
    if (`$initialMode -eq "yolo") {
        Set-ClaudeYoloMode -Silent
    } else {
        Set-ClaudeNormalMode -Silent
    }
    
    `$currentMode = if (`$initialMode -eq "yolo") { "YOLO 🚀" } else { "SAFE 🛡️" }
    
    Write-Host "✅ Claude PowerShell profile loaded successfully!" -ForegroundColor Green
    Write-Host "🎯 Current mode: `$currentMode" -ForegroundColor Cyan
    Write-Host "💡 Type 'claude-help' for available commands" -ForegroundColor Yellow
    
} catch {
    Write-Host "⚠️ Warning: Error during profile initialization: `$(`$_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "💡 You may need to reinstall Claude Code" -ForegroundColor Yellow
}

# ============================================================================
# End of Claude Configuration
# ============================================================================
"@ | Out-File -FilePath $PROFILE -Encoding UTF8

Write-Host "✅ Profile configuration written successfully!" -ForegroundColor Green

# 6. 프로필 구문 검증
Write-Host "`n🔍 Validating profile syntax..." -ForegroundColor Cyan
try {
    # 임시로 프로필 로드해서 구문 오류 확인
    $tempResult = powershell.exe -NoProfile -Command "& { . '$PROFILE'; Write-Host 'Profile syntax is valid' }" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Profile syntax validation passed!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Profile syntax validation warning:" -ForegroundColor Yellow
        Write-Host $tempResult -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️ Could not validate profile syntax: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 7. 최종 안내
Write-Host "`n🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "📁 Profile location: $PROFILE" -ForegroundColor Cyan
Write-Host "💾 Backup created: $backupPath" -ForegroundColor Gray
Write-Host "🚀 Claude path: $claudePath" -ForegroundColor Gray
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

Write-Host "`n📋 Next steps:" -ForegroundColor Yellow
Write-Host "  1️⃣ Restart PowerShell or run: . `$PROFILE" -ForegroundColor White
Write-Host "  2️⃣ Test with: claude-status" -ForegroundColor White
Write-Host "  3️⃣ Get help with: claude-help" -ForegroundColor White
Write-Host "  4️⃣ Try Claude: claude --help" -ForegroundColor White

Write-Host "`n🔧 If you encounter issues:" -ForegroundColor Yellow
Write-Host "  • Run 'claude-status' to check configuration" -ForegroundColor White
Write-Host "  • Run 'claude-path' to verify executable path" -ForegroundColor White
Write-Host "  • Run 'claude-reset' to restore defaults" -ForegroundColor White

# 8. 재시작 안내 
Write-Host "💡 Please restart PowerShell to use the new configuration" -ForegroundColor Yellow
```

## Linux/Mac 설정

### 설정 스크립트 생성

아래 내용으로 `claude-setup.sh` 파일을 생성하세요:

```bash
#!/bin/bash
# ============================================================================
# Claude YOLO Mode Setup for Linux & macOS
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

# Emoji support check
if locale charmap 2>/dev/null | grep -qi utf; then
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

print_header "$(emoji "🚀" "") Claude YOLO Mode Setup for Unix Systems"
echo

# Detect operating system and shell
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
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
            if [ "$OS" = "macos" ]; then
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
            if [ "$OS" = "macos" ]; then
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
```