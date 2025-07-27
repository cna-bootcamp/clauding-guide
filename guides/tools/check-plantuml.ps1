param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath = "C:\home\workspace\tripgen\design\backend\system\azure-physical-architecture.txt"
)

Write-Host "=== PlantUML Syntax Checker ===" -ForegroundColor Cyan
Write-Host "Target file: $FilePath" -ForegroundColor Yellow

# Check if file exists
if (-not (Test-Path $FilePath)) {
    Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
    exit 1
}

# Execute directly in PowerShell
$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$tempFile = "/tmp/puml_$timestamp.puml"

# Copy file
Write-Host "`n1. Copying file..." -ForegroundColor Gray
Write-Host "   Temporary file: $tempFile"
docker cp $FilePath "plantuml:$tempFile"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ File copy failed" -ForegroundColor Red
    exit 1
}
Write-Host "   ✅ Copy completed" -ForegroundColor Green

# Find JAR file path
Write-Host "`n2. Looking for PlantUML JAR file..." -ForegroundColor Gray
$JAR_PATH = docker exec plantuml sh -c "find / -name 'plantuml*.jar' 2>/dev/null | head -1"
Write-Host "   JAR path: $JAR_PATH"
Write-Host "   ✅ JAR file confirmed" -ForegroundColor Green

# Syntax check
Write-Host "`n3. Running syntax check..." -ForegroundColor Gray
$syntaxOutput = docker exec plantuml sh -c "java -jar $JAR_PATH -checkonly $tempFile 2>&1"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Syntax check passed!" -ForegroundColor Green
    Write-Host "   No syntax errors found in the diagram." -ForegroundColor Green
} else {
    Write-Host "`n❌ Syntax errors detected!" -ForegroundColor Red
    Write-Host "Error details:" -ForegroundColor Red
    Write-Host $syntaxOutput -ForegroundColor Yellow
    
    # Detailed error check
    Write-Host "`nAnalyzing detailed errors..." -ForegroundColor Yellow
    $detailError = docker exec plantuml sh -c "java -jar $JAR_PATH -failfast -v $tempFile 2>&1"
    $errorLines = $detailError | Select-String "Error line"
    
    if ($errorLines) {
        Write-Host "`n📍 Error locations:" -ForegroundColor Magenta
        $errorLines | ForEach-Object { 
            Write-Host "   $($_.Line)" -ForegroundColor Red 
        }
    }
}

# Clean up temporary file
Write-Host "`n4. Cleaning up temporary files..." -ForegroundColor Gray
docker exec plantuml sh -c "rm -f $tempFile" 2>$null
Write-Host "   ✅ Cleanup completed" -ForegroundColor Green

Write-Host "`n=== Check completed ===" -ForegroundColor Cyan