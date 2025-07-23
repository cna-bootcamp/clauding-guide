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
        local backup_file="${PROFILE_FILE}.backup.$(date +%Y%m%