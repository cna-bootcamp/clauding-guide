param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath = "C:\home\workspace\tripgen\design\backend\system\azure-physical-architecture.txt"
)

Write-Host "=== PlantUML 문법 검사 도구 ===" -ForegroundColor Cyan
Write-Host "대상 파일: $FilePath" -ForegroundColor Yellow

# 파일 존재 확인
if (-not (Test-Path $FilePath)) {
    Write-Host "❌ 파일을 찾을 수 없습니다: $FilePath" -ForegroundColor Red
    exit 1
}

# PowerShell에서 직접 실행
$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$tempFile = "/tmp/puml_$timestamp.puml"

# 파일 복사
Write-Host "`n1. 파일 복사 중..." -ForegroundColor Gray
Write-Host "   임시 파일: $tempFile"
docker cp $FilePath "plantuml:$tempFile"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 파일 복사 실패" -ForegroundColor Red
    exit 1
}
Write-Host "   ✅ 복사 완료" -ForegroundColor Green

# JAR 파일 경로 찾기
Write-Host "`n2. PlantUML JAR 파일 찾는 중..." -ForegroundColor Gray
$JAR_PATH = docker exec plantuml sh -c "find / -name 'plantuml*.jar' 2>/dev/null | head -1"
Write-Host "   JAR 경로: $JAR_PATH"
Write-Host "   ✅ JAR 파일 확인" -ForegroundColor Green

# 문법 검사
Write-Host "`n3. 문법 검사 실행 중..." -ForegroundColor Gray
$syntaxOutput = docker exec plantuml sh -c "java -jar $JAR_PATH -checkonly $tempFile 2>&1"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ 문법 검사 통과!" -ForegroundColor Green
    Write-Host "   다이어그램에 문법 오류가 없습니다." -ForegroundColor Green
} else {
    Write-Host "`n❌ 문법 오류 발견!" -ForegroundColor Red
    Write-Host "오류 내용:" -ForegroundColor Red
    Write-Host $syntaxOutput -ForegroundColor Yellow
    
    # 에러 상세 확인
    Write-Host "`n상세 에러 분석 중..." -ForegroundColor Yellow
    $detailError = docker exec plantuml sh -c "java -jar $JAR_PATH -failfast -v $tempFile 2>&1"
    $errorLines = $detailError | Select-String "Error line"
    
    if ($errorLines) {
        Write-Host "`n📍 에러 위치:" -ForegroundColor Magenta
        $errorLines | ForEach-Object { 
            Write-Host "   $($_.Line)" -ForegroundColor Red 
        }
    }
}

# 임시 파일 삭제
Write-Host "`n4. 임시 파일 정리 중..." -ForegroundColor Gray
docker exec plantuml sh -c "rm -f $tempFile" 2>$null
Write-Host "   ✅ 정리 완료" -ForegroundColor Green

Write-Host "`n=== 검사 완료 ===" -ForegroundColor Cyan