# Mermaid Syntax Checker using Docker Container
# Similar to PlantUML checker - keeps container running for better performance

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FilePath
)

# Check if file exists
if (-not (Test-Path $FilePath)) {
    Write-Host "Error: File not found: $FilePath" -ForegroundColor Red
    exit 1
}

# Get absolute path
$absolutePath = (Resolve-Path $FilePath).Path
$fileName = Split-Path $absolutePath -Leaf

Write-Host "`nChecking Mermaid syntax for: $fileName" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Gray

# Check if mermaid container is running
$containerRunning = docker ps --filter "name=mermaid-cli" --format "{{.Names}}" 2>$null

if (-not $containerRunning) {
    Write-Host "Error: Mermaid CLI container is not running." -ForegroundColor Red
    Write-Host "Please follow the setup instructions in the Mermaid guide to start the container." -ForegroundColor Yellow
    Write-Host "`nQuick setup commands:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "# 1. Start container with root privileges (port 48080)" -ForegroundColor Green
    Write-Host "docker run -d --rm --name mermaid-cli -u root -p 48080:8080 --entrypoint sh minlag/mermaid-cli:latest -c `"while true;do sleep 3600; done`"" -ForegroundColor White
    Write-Host ""
    Write-Host "# 2. Install Chromium and dependencies" -ForegroundColor Green
    Write-Host "docker exec mermaid-cli sh -c `"apk add --no-cache chromium chromium-chromedriver nss freetype harfbuzz ca-certificates ttf-freefont`"" -ForegroundColor White
    Write-Host ""
    Write-Host "# 3. Create Puppeteer configuration" -ForegroundColor Green
    Write-Host "docker exec mermaid-cli sh -c `"echo '{```"executablePath```": ```"/usr/bin/chromium-browser```", ```"args```": [```"--no-sandbox```", ```"--disable-setuid-sandbox```", ```"--disable-dev-shm-usage```"]}' > /tmp/puppeteer-config.json`"" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Set Puppeteer configuration file path
$puppeteerConfigFile = "/tmp/puppeteer-config.json"

# Generate unique temp filename
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$processId = $PID
$tempFile = "/tmp/mermaid_${timestamp}_${processId}.mmd"
$outputFile = "/tmp/mermaid_${timestamp}_${processId}.svg"

try {
    # Copy file to container
    Write-Host "Copying file to container..." -ForegroundColor Gray
    docker cp "$absolutePath" "mermaid-cli:$tempFile" 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to copy file to container" -ForegroundColor Red
        exit 1
    }
    
    # Run syntax check with Puppeteer configuration
    Write-Host "Running syntax check..." -ForegroundColor Gray
    $output = docker exec mermaid-cli sh -c "cd /home/mermaidcli && node_modules/.bin/mmdc -i '$tempFile' -o '$outputFile' -p '$puppeteerConfigFile' -q" 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "`nSuccess: Mermaid syntax is valid!" -ForegroundColor Green
    } else {
        Write-Host "`nError: Mermaid syntax validation failed!" -ForegroundColor Red
        Write-Host "`nError details:" -ForegroundColor Red
        
        # Parse and display error messages
        $errorLines = $output -split "`n"
        foreach ($line in $errorLines) {
            if ($line -match "Error:|Parse error|Expecting|Syntax error") {
                Write-Host "  $line" -ForegroundColor Red
            } elseif ($line -match "line \d+|at line") {
                Write-Host "  $line" -ForegroundColor Yellow
            } elseif ($line.Trim() -ne "") {
                Write-Host "  $line" -ForegroundColor DarkRed
            }
        }
        
        exit 1
    }
    
} finally {
    # Clean up temp files
    Write-Host "`nCleaning up..." -ForegroundColor Gray
    docker exec mermaid-cli rm -f "$tempFile" "$outputFile" 2>&1 | Out-Null
}

Write-Host "`nValidation complete!" -ForegroundColor Cyan

# Note: Container is kept running for subsequent checks
# To stop: docker stop mermaid-cli && docker rm mermaid-cli