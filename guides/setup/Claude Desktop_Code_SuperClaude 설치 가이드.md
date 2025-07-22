# Claude Desktop/Code/SuperClaude 설치 가이드

## Overview
- Claude Desktop: Local 설치하여 Claude 사용  
- Claude Code: Vibe 코딩툴   
- SuperClaude: Claude Code의 기능 확장 툴   

## 🚀 Claude Code 설치 가이드

### 사전 요구사항 확인
먼저 터미널에서 다음을 확인하세요:

**Linux/Mac**  
```bash
# Python 버전 확인 (3.8 이상 필요)
python3 --version

# Node.js 확인 (선택사항, MCP 서버용)
node --version
```

**Window**  
```
# Python 버전 확인 (3.8 이상 필요)
python --version

# Node.js 확인 (선택사항, MCP 서버용)
node --version
```

### 필수 도구 설치
- Python이 없다면 공식 웹사이트에서 다운로드  
  https://python.org/downloads/

- Node.js 설치  

### Claude Desktop 설치 
https://claude.ai/download

### Claude Code 설치
https://claude.ai/code

Node Version Manager 사용
- nvm 설치   
  Linux/Mac  
  ```bash
  # nvm이 없다면 설치
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  ```

  window
  ```
  1. 브라우저에서 이동: https://github.com/coreybutler/nvm-windows/releases
  2. 최신 릴리스에서 'nvm-setup.exe' 다운로드
  3. 다운로드한 설치 파일 실행
  4. 설치 마법사 따라서 진행
  ```

- 설치 
  ```
  # 터미널 재시작 후
  nvm install node
  nvm use node

  # 이제 권한 문제 없이 설치
  npm install -g @anthropic-ai/claude-code
  ```

---

## SuperClaude 설치

### 사전준비

uv 설치 (빠르고 현대적인 패키지 매니저):

1)Linux/Mac  
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

기본 이름으로 가상환경 생성

```bash
uv venv
```

가상환경 활성화 (올바른 방법)

```bash
source .venv/bin/activate
```

SuperClaude 설치
가상환경이 활성화된 상태에서:
```bash
uv pip install SuperClaude
```

2)Wiondow
```
# PowerShell에서 실행
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```
```bash
pip install SuperClaude
```


### 설치 확인

```bash
SuperClaude --help
```

### 설정 실행

```bash
SuperClaude install --quick
```

---

## MCP 설치

### 사전작업

bun 설치:

Linux/Mac
```bash
curl -fsSL https://bun.sh/install | bash
```
설정 적용: Mac은 ~/.zshrc, Linux는 ~/.bashrc에 추가 
```
export PATH="$HOME/.bun/bin:$PATH"
```


Window
```
powershell -c "irm bun.sh/install.ps1|iex"
```

참고) MCP 설정 파일

- **Linux**: `~/.config/Claude/claude_desktop_config.json`
- **Mac**: `/Users/{user}/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `{user home}\AppData\Roaming\Claude\claude_desktop_config.json`

## 주요 MCP 설치

### Context7 MCP

```bash
# GitHub 링크: https://github.com/upstash/context7
# 설치는 MCP 설정 파일에 추가
```

### Sequential Thinking MCP

```bash
# GitHub 링크: https://mcp.so/server/sequentialthinking/modelcontextprotocol
# 설치는 MCP 설정 파일에 추가
```

### Magic MCP

```bash
# GitHub 링크: https://github.com/21st-dev/magic-mcp
# API Key 생성 필요: https://21st.dev/magic/console 에서 'Setup Magic MCP' 버튼 클릭
# IDE를 Cursor로 선택하면 생성됨
```

### Playwright MCP

```bash
# GitHub 링크: https://github.com/microsoft/playwright-mcp
# 설치는 MCP 설정 파일에 추가
```

### GitHub MCP 설치

https://smithery.ai/ 에서 'GitHub'로 찾아 추가:

```json
"github": {
  "command": "npx",
  "args": [
    "-y",
    "@smithery/cli@latest",
    "run",
    "@smithery-ai/github",
    "--key",
    "6bf03d02-65a9-4a0d-ac05-6d4a5b0d4343",
    "--profile",
    "motionless-flamingo-aj9dsM"
  ]
}
```

**※ 접근할 Organization에 'Smithery AI'를 추가해야 함**
- '[Deploy Server]' 클릭 후 GitHub 로그인
- 'Add Github Account' 선택하여 접근할 Organization 추가

### Figma MCP 설치

claude_desktop_config.json에 아래와 같이 추가:

```json
"figma-mcp": {
  "command": "npx",
  "args": [
    "-y",
    "cursor-talk-to-figma-mcp@latest",
    "--server=vps.sonnylab.com"
  ]
}
```

#### Figma MCP 사용법

1. Figma에서 'Cursor Talk To Figma MCP Plugin' 설치
2. Claude Desktop이나 Claude Code에서 연동할 Figma 객체 선택 후 플러그인 실행
3. 플러그인 창에서 채널 ID 복사. 이 플러그인 창을 닫지 않고 그대로 둠
4. Claude Desktop 또는 Claude Code에서 프롬프팅

### 설치 확인

Claude Desktop의 '설정' 메뉴에서 확인.

**※ 설정 파일 수정 후 메인메뉴에서 클로드를 종료 후 다시 시작해야 적용됨**

## MCP 설정 파일 예시

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@smithery/cli@latest",
        "run",
        "@smithery-ai/github",
        "--key",
        "6bf03d02-65a9-4a0d-ac05-6d4a5b0d4343",
        "--profile",
        "motionless-flamingo-aj9dsM"
      ]
    },
    "figma-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "cursor-talk-to-figma-mcp@latest",
        "--server=vps.sonnylab.com"
      ]
    },
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp"
      ]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    },
    "magic": {
      "command": "npx",
      "args": [
        "-y",
        "@21st-dev/magic@latest"
      ],
      "env": {
        "API_KEY": "5ec762189bd67fb2e4b3d3832cc35b80d4ff067418a6f0c872a3724d1283ab43"
      }
    },
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@playwright/mcp@latest"
      ]
    },
    "mcp-kakao-local": {
      "command": "npx",
      "args": [
        "-y",
        "@smithery/cli@latest",
        "run",
        "@yunkee-lee/mcp-kakao-local",
        "--key",
        "6bf03d02-65a9-4a0d-ac05-6d4a5b0d4343",
        "--profile",
        "motionless-flamingo-aj9dsM"
      ]
    }
  }
}
```

## Claude Desktop MCP 설정 기반으로 Claude Code MCP 서버 추가

### Linux/Mac:

```bash
claude mcp add-from-claude-desktop -s user
```

### Windows:

사용자 홈 디렉토리에 CLAUDE.md 파일 생성하고 아래 내용 붙여 넣기.
claude 명령으로 claude code 실행하고 프롬프트에 'MCP 서버 동기화'라고 입력.
자동으로 생성된 배치 파일을 cmd 창에서 수행함.
설정 파일은 `{사용자 홈 디렉토리}/.claude` 파일임.

## Claude Desktop → Claude Code MCP 자동 동기화

### 📋 개요

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

### ✅ 3단계: 설치 검증 및 확인

#### 기본 검증

배치 파일 실행 완료 후 Windows CMD 창을 열고 다음 명령어로 확인:

```cmd
claude mcp list
```

## 참고사항/Tip

### 공식 Git Repository

- **Claude Code**: https://github.com/anthropics/claude-code
- **SuperClaude**: https://github.com/SuperClaude-Org/SuperClaude_Framework

**※ 위 Git Repo를 본인것으로 Fork 한 후 클로드 Project에 본인 Git Repo를 추가. 학습이나 문제해결 시 클로딩함.**

