# ============================================================================
# PowerShell Profile Auto-Setup and Claude Configuration
# Encoding Issue Resolution Included
# ============================================================================

# Fix encoding issues first
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $PSDefaultParameterValues['*:Encoding'] = 'utf8'
}

Write-Host "Setting up PowerShell profile for Claude..." -ForegroundColor Cyan

# 1. Check and display profile path
Write-Host "Profile path: $PROFILE" -ForegroundColor Gray

# 2. Check and create profile directory
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    Write-Host "Creating profile directory: $profileDir" -ForegroundColor Yellow
    try {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-Host "Profile directory created successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create profile directory: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Profile directory already exists" -ForegroundColor Green
}

# 3. Check and create profile file
if (-not (Test-Path $PROFILE)) {
    Write-Host "Creating profile file: $PROFILE" -ForegroundColor Yellow
    try {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        Write-Host "Profile file created successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create profile file: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Profile file already exists" -ForegroundColor Green
    
    # Backup existing profile
    $backupPath = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "Creating backup: $backupPath" -ForegroundColor Yellow
    Copy-Item $PROFILE $backupPath -ErrorAction SilentlyContinue
}

# 4. Find Claude executable path
Write-Host "`nSearching for Claude executable..." -ForegroundColor Cyan

# Function to find Claude executable
function Find-ClaudeExecutable {
    $searchPaths = @(
        "$env:USERPROFILE\.npm-global",
        "$env:APPDATA\npm",
        "$env:PROGRAMFILES\nodejs",
        "$env:PROGRAMFILES\nodejs\node_modules\.bin",
        "$env:USERPROFILE\AppData\Roaming\npm",
        "$env:LOCALAPPDATA\npm",
        "$env:ProgramFiles(x86)\nodejs"
    )
    
    Write-Host "Searching in the following locations:" -ForegroundColor Gray
    foreach ($searchPath in $searchPaths) {
        Write-Host "   - $searchPath" -ForegroundColor Gray
    }
    
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            $claudeFiles = Get-ChildItem -Path $searchPath -Filter "claude*" -Recurse -ErrorAction SilentlyContinue
            if ($claudeFiles) {
                Write-Host "Found Claude files in $searchPath :" -ForegroundColor Green
                $claudeFiles | ForEach-Object { Write-Host "     $($_.FullName)" -ForegroundColor White }
                
                # Prefer .cmd files
                $claudeCmd = $claudeFiles | Where-Object { $_.Extension -eq ".cmd" } | Select-Object -First 1
                if ($claudeCmd) {
                    return $claudeCmd.FullName
                }
                # If no .cmd, return first file
                return $claudeFiles[0].FullName
            }
        }
    }
    
    # Try to find in PATH
    Write-Host "Searching in system PATH..." -ForegroundColor Gray
    $pathClaude = Get-Command claude -ErrorAction SilentlyContinue
    if ($pathClaude) {
        Write-Host "Found Claude in PATH: $($pathClaude.Source)" -ForegroundColor Green
        return $pathClaude.Source
    }
    
    return $null
}

$claudePath = Find-ClaudeExecutable

if (-not $claudePath) {
    Write-Host "Claude not found in any location!" -ForegroundColor Red
    Write-Host "Please install Claude Code with: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    Write-Host "Or check if Node.js is properly installed" -ForegroundColor Yellow
    
    # Check Node.js installation status
    try {
        $nodeVersion = node --version
        $npmVersion = npm --version
        Write-Host "Node.js version: $nodeVersion" -ForegroundColor Green
        Write-Host "npm version: $npmVersion" -ForegroundColor Green
        Write-Host "Try running: npm install -g @anthropic-ai/claude-code" -ForegroundColor Cyan
    } catch {
        Write-Host "Node.js not found. Please install Node.js first from https://nodejs.org" -ForegroundColor Red
    }
    
    exit 1
}

Write-Host "Using Claude path: $claudePath" -ForegroundColor Green

# 5. Write advanced Claude configuration to profile
Write-Host "`nWriting advanced Claude configuration to profile..." -ForegroundColor Cyan

# Create profile content with proper encoding
$profileContent = @"
# ============================================================================
# Advanced Claude YOLO Configuration
# Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# ============================================================================

# Fix encoding issues
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
`$OutputEncoding = [System.Text.Encoding]::UTF8
if (`$PSVersionTable.PSVersion.Major -ge 6) {
    `$PSDefaultParameterValues['*:Encoding'] = 'utf8'
}

`$claudePath = '$claudePath'
`$ClaudeStateFile = "`$env:USERPROFILE\.claude-mode-state"

# Profile initialization check
if (-not `$claudePath -or -not (Test-Path `$claudePath)) {
    Write-Host "Claude executable not found at: `$claudePath" -ForegroundColor Red
    Write-Host "Please reinstall Claude Code with: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    return
}

# State management functions
function Save-ClaudeState {
    param([string]`$Mode)
    try {
        `$Mode | Out-File -FilePath `$ClaudeStateFile -Encoding UTF8 -ErrorAction Stop
    } catch {
        Write-Host "Warning: Could not save Claude state" -ForegroundColor Yellow
    }
}

function Load-ClaudeState {
    if (Test-Path `$ClaudeStateFile) {
        try {
            `$savedMode = Get-Content `$ClaudeStateFile -Raw -ErrorAction Stop
            return `$savedMode.Trim()
        } catch {
            Write-Host "Warning: Could not load Claude state, using default" -ForegroundColor Yellow
        }
    }
    return "yolo"  # Default mode
}

function Set-ClaudeYoloMode {
    param([switch]`$Silent)
    
    if (-not `$Silent) {
        Write-Host "Setting Claude to YOLO mode" -ForegroundColor Green
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
        Write-Host "Setting Claude to SAFE mode" -ForegroundColor Yellow
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
    Write-Host "Claude Status Report:" -ForegroundColor Cyan
    Write-Host "  =======================================" -ForegroundColor Gray
    
    # Current mode
    `$claudeFunction = Get-Command claude -ErrorAction SilentlyContinue
    if (`$claudeFunction -and `$claudeFunction.Definition -like "*dangerously-skip-permissions*") {
        Write-Host "  Current mode: YOLO" -ForegroundColor Green
    } else {
        Write-Host "  Current mode: SAFE" -ForegroundColor Yellow
    }
    
    # Saved state
    if (Test-Path `$ClaudeStateFile) {
        `$savedMode = (Get-Content `$ClaudeStateFile -Raw -ErrorAction SilentlyContinue).Trim()
        Write-Host "  Saved mode: `$(`$savedMode.ToUpper())" -ForegroundColor Gray
    } else {
        Write-Host "  Saved mode: Not set" -ForegroundColor Gray
    }
    
    # Executable path and validation
    Write-Host "  Executable: `$claudePath" -ForegroundColor Gray
    if (Test-Path `$claudePath) {
        Write-Host "  Path status: Valid" -ForegroundColor Green
        
        # Version check
        try {
            `$version = & `$claudePath --version 2>`$null
            if (`$version) {
                Write-Host "  Version: `$version" -ForegroundColor Gray
            } else {
                Write-Host "  Version: Unable to determine" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  Version: Error checking version" -ForegroundColor Gray
        }
    } else {
        Write-Host "  Path status: Invalid!" -ForegroundColor Red
    }
    
    Write-Host "  =======================================" -ForegroundColor Gray
}

function claude-reset {
    Write-Host "Resetting Claude configuration..." -ForegroundColor Yellow
    Remove-Item `$ClaudeStateFile -ErrorAction SilentlyContinue
    Set-ClaudeYoloMode -Silent
    Write-Host "Reset to default (YOLO mode)" -ForegroundColor Green
}

function claude-path {
    Write-Host "Claude Executable Information:" -ForegroundColor Cyan
    Write-Host "  Path: `$claudePath" -ForegroundColor White
    
    if (Test-Path `$claudePath) {
        Write-Host "  Status: Valid" -ForegroundColor Green
        `$fileInfo = Get-Item `$claudePath
        Write-Host "  Size: `$([math]::Round(`$fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray
        Write-Host "  Modified: `$(`$fileInfo.LastWriteTime)" -ForegroundColor Gray
    } else {
        Write-Host "  Status: Invalid!" -ForegroundColor Red
        Write-Host "  Try reinstalling: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    }
}

function claude-help {
    Write-Host "Claude PowerShell Commands:" -ForegroundColor Cyan
    Write-Host "  ===============================================" -ForegroundColor Gray
    Write-Host "  claude          - Run Claude in current mode" -ForegroundColor White
    Write-Host "  claude-safe     - Run Claude in safe mode (one-time)" -ForegroundColor White
    Write-Host "  claude-yolo     - Switch to YOLO mode (persistent)" -ForegroundColor White
    Write-Host "  claude-normal   - Switch to SAFE mode (persistent)" -ForegroundColor White
    Write-Host "  claude-status   - Show detailed status report" -ForegroundColor White
    Write-Host "  claude-reset    - Reset to default configuration" -ForegroundColor White
    Write-Host "  claude-path     - Show executable path info" -ForegroundColor White
    Write-Host "  claude-help     - Show this help message" -ForegroundColor White
    Write-Host "  cy             - Alias for claude command" -ForegroundColor White
    Write-Host "  ===============================================" -ForegroundColor Gray
    Write-Host "  Tip: Use 'claude-status' to check current configuration" -ForegroundColor Yellow
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
    
    `$currentMode = if (`$initialMode -eq "yolo") { "YOLO" } else { "SAFE" }
    
    Write-Host "Claude PowerShell profile loaded successfully!" -ForegroundColor Green
    Write-Host "Current mode: `$currentMode" -ForegroundColor Cyan
    Write-Host "Type 'claude-help' for available commands" -ForegroundColor Yellow
    
} catch {
    Write-Host "Warning: Error during profile initialization: `$(`$_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "You may need to reinstall Claude Code" -ForegroundColor Yellow
}

# ============================================================================
# End of Claude Configuration
# ============================================================================
"@

# Write profile with UTF8 encoding without BOM
[System.IO.File]::WriteAllText($PROFILE, $profileContent, [System.Text.UTF8Encoding]::new($false))

Write-Host "Profile configuration written successfully!" -ForegroundColor Green

# 6. Validate profile syntax
Write-Host "`nValidating profile syntax..." -ForegroundColor Cyan
try {
    # Test profile loading with syntax check
    $tempResult = powershell.exe -NoProfile -Command "& { . '$PROFILE'; Write-Host 'Profile syntax is valid' }" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Profile syntax validation passed!" -ForegroundColor Green
    } else {
        Write-Host "Profile syntax validation warning:" -ForegroundColor Yellow
        Write-Host $tempResult -ForegroundColor Gray
    }
} catch {
    Write-Host "Could not validate profile syntax: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 7. Final instructions
Write-Host "`nSetup completed successfully!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Gray
Write-Host "Profile location: $PROFILE" -ForegroundColor Cyan
Write-Host "Backup created: $backupPath" -ForegroundColor Gray
Write-Host "Claude path: $claudePath" -ForegroundColor Gray
Write-Host "================================================================" -ForegroundColor Gray

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor White
Write-Host "  2. Test with: claude-status" -ForegroundColor White
Write-Host "  3. Get help with: claude-help" -ForegroundColor White
Write-Host "  4. Try Claude: claude --help" -ForegroundColor White

Write-Host "`nIf you encounter issues:" -ForegroundColor Yellow
Write-Host "  * Run 'claude-status' to check configuration" -ForegroundColor White
Write-Host "  * Run 'claude-path' to verify executable path" -ForegroundColor White
Write-Host "  * Run 'claude-reset' to restore defaults" -ForegroundColor White

# 8. Create encoding fix script
$encodingFixScript = @"
# UTF-8 Encoding Force Setup
chcp 65001 > `$null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
`$OutputEncoding = [System.Text.Encoding]::UTF8
if (`$PSVersionTable.PSVersion.Major -ge 6) {
    `$PSDefaultParameterValues['*:Encoding'] = 'utf8'
}
Write-Host "Encoding set to UTF-8" -ForegroundColor Green
"@

$encodingScriptPath = "$env:USERPROFILE\claude-encoding-fix.ps1"
[System.IO.File]::WriteAllText($encodingScriptPath, $encodingFixScript, [System.Text.UTF8Encoding]::new($false))

Write-Host "`nEncoding fix script created: $encodingScriptPath" -ForegroundColor Cyan
Write-Host "Run if needed: . '$encodingScriptPath'" -ForegroundColor Gray
Write-Host "Please restart PowerShell to use the new configuration" -ForegroundColor Yellow