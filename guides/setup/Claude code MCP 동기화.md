
# Claude Desktop MCP 설정 기반으로 Claude Code MCP 서버 추가

## Linux/Mac:

```bash
claude mcp add-from-claude-desktop -s user
```

## Windows:

사용자 홈 디렉토리에 CLAUDE.md 파일 생성하고 아래 내용 붙여 넣기.
claude 명령으로 claude code 실행하고 프롬프트에 'MCP 서버 동기화'라고 입력.
자동으로 생성된 배치 파일을 cmd 창에서 수행함.
설정 파일은 `{사용자 홈 디렉토리}/.claude` 파일임.

Claude Desktop의 MCP 설정을 자동으로 분석하여 Claude Code용 MCP 서버 설치 배치 파일을 생성합니다. 사용자는 생성된 배치 파일을 실행하고 결과만 확인하면 됩니다.

### 🔧 1단계: 자동 배치 파일 생성

Claude Code가 Claude Desktop 설정을 읽어서 맞춤형 배치 파일을 자동으로 생성합니다.

**✅ Batch파일 자동 생성**: Claude Desktop 설정을 기반으로 배치 파일이 생성되었습니다.
- claude desktop 설정 파일 위치: `{User Home}\AppData\Roaming\Claude\claude_desktop_config.json`
- 기존에 배치 파일이 있는 경우 자동으로 덮어씁니다.
- 배치파일 생성 위치: `C:\Users\{사용자명}\sync_mcp_servers_auto.bat`
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

1. **파일 탐색기**에서 `C:\Users\hiond\sync_mcp_servers_auto.bat` 파일을 찾습니다
2. 파일을 **더블클릭**하여 실행합니다
3. 각 서버별 설치 진행상황을 확인합니다:
   - ✅ 설치 완료 메시지 확인
   - ❌ 설치 실패시 오류 메시지 확인
4. 마지막에 설치된 서버 목록이 출력됩니다
5. **아무 키나 눌러서** 창을 닫습니다

#### 설치 검증 및 확인

배치 파일 실행 완료 후 Windows CMD 창을 열고 다음 명령어로 확인:

```cmd
claude mcp list
```

