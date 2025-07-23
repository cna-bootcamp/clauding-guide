# PlantUML 문법 검사 가이드

## 개요

PlantUML 다이어그램의 문법 오류를 사전에 검출하여 렌더링 실패를 방지하기 위한 가이드입니다. Docker 기반 PlantUML 서버를 활용하여 로컬에서 빠르게 문법을 검증할 수 있습니다.

## PlantUML 서버 설치 검사

### Docker로 PlantUML 서버 실행

```bash
# PlantUML 서버가 실행 중인지 확인
docker ps | grep plantuml

# PlantUML 서버가 없으면 설치 및 실행
docker run -d --name plantuml -p 38080:8080 plantuml/plantuml-server:latest

# 서버 상태 확인
docker logs plantuml
```

## 문법 검사 방법
현재 OS에 맞게 수행 

### Linux/macOS 버전

```bash
# 1. 고유 파일명 생성 (충돌 방지)
TEMP_FILE="/tmp/puml_$(date +%s)_$$.puml"

# 2. 파일 복사
docker cp {검사할 파일} plantuml:${TEMP_FILE}

# 3. JAR 파일 위치 찾기
JAR_PATH=$(docker exec plantuml find / -name "plantuml*.jar" 2>/dev/null | head -1)

# 4. 문법 검사
docker exec plantuml java -jar ${JAR_PATH} -checkonly ${TEMP_FILE}

# 5. 상세 에러 확인 (필요시)
docker exec plantuml sh -c "cd /tmp && java -jar ${JAR_PATH} -failfast -v ${TEMP_FILE} 2>&1 | grep -E 'Error line'"

# 6. 임시 파일 삭제
ddocker exec -u root plantuml rm -f $TEMP_FILE
```

### Windows PowerShell 버전
**스크립트 파일(tools/check-plantuml.ps1)을 생성하여 수행**.

1. tools/check-plantuml.ps1 파일 존재 여부 확인 
2. 스크립트 파일이 없으면 아래 내용으로 스크립트 파일을 만듦.
3. 스크립트 파일이 있으면 그 스크립트 파일을 이용하여 검사.
 
```powershell
param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath = "C:\home\workspace\tripgen\design\backend\system\azure-physical-architecture.puml"
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

```

### 검사 결과 해석

| 출력 | 의미 | 대응 방법 |
|------|------|-----------|
| 출력 없음 | 문법 오류 없음 ✅ | 정상, 렌더링 가능 |
| "Some diagram description contains errors" | 오류 존재 ❌ | 파이프 방식으로 상세 확인 |
| "ERROR" + 라인 번호 | 특정 라인 오류 ❌ | 해당 라인 수정 |
| "Error line X in file" | X번째 줄 오류 ❌ | 해당 라인 문법 확인 |

## 화살표 문법 규칙

### 시퀀스 다이어그램 올바른 화살표 사용법

```plantuml
@startuml
' 올바른 사용법 ✅
A -> B: 동기 메시지 (실선)
A ->> B: 비동기 메시지 (실선, 열린 화살촉)
A -->> B: 비동기 응답 (점선, 열린 화살촉)  
A --> B: 점선 화살표 (일반)
A <-- B: 응답 (점선)
A ->x B: 실패/거부 (X 표시)
A ->>o B: 비동기 열린 원

' 잘못된 사용법 ❌
A ..> B: ' 오류! sequence diagram에서 유효하지 않음
@enduml
```

### 클래스 다이어그램 화살표

```plantuml
@startuml
' 클래스 다이어그램에서는 ..> 사용 가능
ClassA ..> ClassB : 의존성 (점선)
ClassC --> ClassD : 연관 (점선)
@enduml
```

### 화살표 문법 주의사항

1. **`..>`는 sequence diagram에서 사용 금지**
2. 비동기 메시지는 `->>` 또는 `-->>` 사용
3. 동기/비동기를 명확히 구분하여 일관되게 사용
4. 다이어그램 타입별로 유효한 화살표가 다름