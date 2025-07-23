
# Claude Desktop MCP 설정 기반으로 Claude Code MCP 서버 추가

## Linux/Mac:

```bash
claude mcp add-from-claude-desktop -s user
```

## Windows:

### 🔧 1단계: 자동 배치 파일 생성

Claude Desktop 설정을 읽어서 맞춤형 배치 파일을 자동으로 생성합니다.
- Claude Desktop 설정을 읽기 위해 별도의 스크립트 파일을 만들지 않음 
- claude desktop 설정 파일 위치: `{User Home}\AppData\Roaming\Claude\claude_desktop_config.json`
- 배치파일 생성 위치: `C:\Users\{사용자명}\sync_mcp_servers_auto.bat`
- 기존에 배치 파일이 있는 경우 자동으로 덮어씁니다.
- 배치파일은 영어로 작성
- 아래 예시를 참고하여 배치파일 생성

```batch
@echo off
echo ===============================================
echo   Claude Desktop MCP Auto Sync
echo ===============================================
echo.
echo Installing 6 MCP servers to Claude Code...
echo Each installation may take 10-30 seconds.
echo.

echo [1/6] Installing MCP-GitHub...
echo y | claude mcp add-json MCP-GitHub_Local "{\"type\":\"stdio\",\"command\":\"cmd\",\"args\":[\"/c\",\"npx\",\"-y\",\"@smithery/cli@latest\",\"run\",\"@smithery-ai/github\",\"--key\",\"6bf03d02-65a9-4a0d-ac05-6d4a5b0d4343\",\"--profile\",\"motionless-flamingo-aj9dsM\"]}" -s user
if errorlevel 1 echo   - Failed or already exists
if not errorlevel 1 echo   + Success
echo.

echo [2/6] Installing TalkToFigma...
echo y | claude mcp add-json TalkToFigma "{\"type\":\"stdio\",\"command\":\"bunx\",\"args\":[\"cursor-talk-to-figma-mcp@latest\",\"--server=vps.sonnylab.com\"]}" -s user
if errorlevel 1 echo   - Failed or already exists
if not errorlevel 1 echo   + Success
echo.

echo [3/6] Installing Context7...
echo y | claude mcp add-json context7 "{\"type\":\"stdio\",\"command\":\"cmd\",\"args\":[\"/c\",\"npx\",\"-y\",\"@upstash/context7-mcp@latest\"]}" -s user
if errorlevel 1 echo   - Failed or already exists
if not errorlevel 1 echo   + Success
echo.

echo [4/6] Installing Sequential-thinking...
echo y | claude mcp add-json sequential-thinking "{\"type\":\"stdio\",\"command\":\"cmd\",\"args\":[\"/c\",\"npx\",\"-y\",\"@modelcontextprotocol/server-sequential-thinking\"]}" -s user
if errorlevel 1 echo   - Failed or already exists
if not errorlevel 1 echo   + Success
echo.

echo [5/6] Installing Magic...
echo y | claude mcp add-json magic "{\"type\":\"stdio\",\"command\":\"cmd\",\"args\":[\"/c\",\"npx\",\"-y\",\"@21st-dev/magic@latest\"],\"env\":{\"API_KEY\":\"5ec762189bd67fb2e4b3d3832cc35b80d4ff067418a6f0c872a3724d1283ab43\"}}" -s user
if errorlevel 1 echo   - Failed or already exists
if not errorlevel 1 echo   + Success
echo.

echo [6/6] Installing Playwright...
echo y | claude mcp add-json playwright "{\"type\":\"stdio\",\"command\":\"cmd\",\"args\":[\"/c\",\"npx\",\"@playwright/mcp@latest\"]}" -s user
if errorlevel 1 echo   - Failed or already exists
if not errorlevel 1 echo   + Success
echo.

echo ===============================================
echo   Installation Complete!
echo ===============================================
echo.
echo Checking installed servers:
claude mcp list
echo.
echo Next steps:
echo 1. Run: claude --debug
echo 2. Wait 2 minutes then use /mcp command to check server status
echo 3. Verify all servers are working properly
echo.
pause
```

### 🚀 2단계: 자동 생성된 배치 파일 실행 안내

#### 배치 파일 실행 안내
아래와 같이 실행 안내를 합니다. 반드시 PowerShell이 아닌 Command창에서 수행하도록 가이드 합니다. 
```
1. **파일 탐색기**에서 `C:\Users\hiond\sync_mcp_servers_auto.bat` 파일을 찾아 파일을 **더블클릭**하여 실행합니다.
2. 또는, Command창(cmd명령으로 수행)에서 `C:\Users\{사용자명}\sync_mcp_servers_auto.bat`을 실행합니다. 
3. 각 서버별 설치 진행상황을 확인합니다:
   - ✅ 설치 완료 메시지 확인
   - ❌ 설치 실패시 오류 메시지 확인
4. 마지막에 설치된 서버 목록이 출력됩니다
5. **아무 키나 눌러서** 창을 닫습니다
```

#### 설치 검증 및 확인 안내 
배치 파일 실행 완료 후 Windows CMD 창을 열고 다음 명령어로 확인하도록 안내 합니다. 

```cmd
claude mcp list
```

