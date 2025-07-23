Claude Desktop 설정을 읽어서 맞춤형 배치 파일을 자동으로 생성합니다.
- **Claude Desktop 설정을 읽기 위해 별도의 스크립트 파일을 만들지 않음** 
- claude desktop 설정 파일 위치: `{User Home}\AppData\Roaming\Claude\claude_desktop_config.json`
- **배치파일 생성 위치**: `C:\Users\{사용자명}\sync_mcp_servers_auto.bat`
- **기존에 배치 파일이 있는 경우 자동으로 덮어씀**
- **배치파일은 영어로 작성**
- 반드시 PowerShell이 아닌 Command창에서 수행하도록 가이드
- 아래 예시를 참고하여 배치파일 생성

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

echo ===============================================
echo   Installation Complete!
echo ===============================================
echo.
echo Checking installed servers:
claude mcp list
echo.
echo Next steps:
echo 1. Run: claude 
echo 2. Wait 2 minutes then use /mcp command to check server status
echo 3. Verify all servers are working properly
echo.
pause
