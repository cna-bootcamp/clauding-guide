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
    Write-Host "Starting Mermaid CLI container..." -ForegroundColor Yellow
    
    # Start container with tail -f to keep it running
    docker run -d --name mermaid-cli --entrypoint tail minlag/mermaid-cli:latest -f /dev/null 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to start Mermaid container" -ForegroundColor Red
        exit 1
    }
    
    Start-Sleep -Seconds 2
    Write-Host "Mermaid CLI container started" -ForegroundColor Green
}

# Generate unique temp filename
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$pid = $PID
$tempFile = "/tmp/mermaid_${timestamp}_${pid}.mmd"
$outputFile = "/tmp/mermaid_${timestamp}_${pid}.svg"

try {
    # Copy file to container
    Write-Host "Copying file to container..." -ForegroundColor Gray
    docker cp "$absolutePath" "mermaid-cli:$tempFile" 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to copy file to container" -ForegroundColor Red
        exit 1
    }
    
    # Run syntax check
    Write-Host "Running syntax check..." -ForegroundColor Gray
    $output = docker exec mermaid-cli mmdc -i "$tempFile" -o "$outputFile" -e svg -q 2>&1
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