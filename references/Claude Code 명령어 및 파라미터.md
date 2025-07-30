# Claude Code 명령어 및 파라미터

## 기본 CLI 명령어

| 명령어 | 설명 | 사용 예시 | 비고 |
| :---- | :---- | :---- | :---- |
| `claude` | 인터랙티브 모드 시작 | `claude` | 기본 대화형 인터페이스 |
| `claude -p "<prompt>"` | 헤드리스 모드 (일회성 실행) | `claude -p "이 함수를 설명해주세요"` | SDK 모드, 실행 후 종료 |
| `claude -c` | 최신 대화 계속 | `claude -c` | 이전 세션 재개 |
| `claude -r <session_id>` | 특정 세션 재개 | `claude -r abc123` | 세션 ID로 재개 |
| `claude commit` | Git 커밋 생성 | `claude commit` | AI가 커밋 메시지 작성 |
| `claude update` | 최신 버전으로 업데이트 | `claude update` | CLI 업데이트 |
| `claude mcp` | MCP 설정 관리 | `claude mcp` | Model Context Protocol 설정 |

## CLI 플래그 및 옵션

### API 사용 

| 플래그 | 설명 | 값 | 예시 |
| :---- | :---- | :---- | :---- |
| `--anthropic-api-key` | Anthropic API 키 | string | `--anthropic-api-key sk-ant-...` |
| `--claude-code-oauth-token` | OAuth 토큰 (API 키 대안) | string | `--claude-code-oauth-token token123` |

### 모델 설정

| 플래그 | 설명 | 값 | 예시 |
| :---- | :---- | :---- | :---- |
| `--model` | 사용할 모델 지정 | string | `--model claude-opus-4-20250514` |
| `--model sonnet` | Sonnet 모델 (별칭) | \- | `--model sonnet` |
| `--model opus` | Opus 모델 (별칭) | \- | `--model opus` |
| `--fallback-model` | 폴백 모델 지정 | string | `--fallback-model claude-sonnet-4-20250514` |

### 권한 및 보안

| 플래그 | 설명 | 값 | 예시 |
| :---- | :---- | :---- | :---- |
| `--dangerously-skip-permissions` | 권한 프롬프트 우회 (YOLO 모드) "You Only Live Once”의 약자로 작업 중간에 사용자의 승인 없이 수행하게 함. 위험할 수 있으나 개발 시에는 편함.   | \- | `--dangerously-skip-permissions` |
| `--permission-mode` | 권한 모드 설정 | plan/ask | `--permission-mode plan` |
| `--permission-prompt-tool` | 권한 프롬프트용 MCP 툴 | string | `--permission-prompt-tool mcp_auth_tool` |

### 도구 제어

| 플래그 | 설명 | 값 | 예시 |
| :---- | :---- | :---- | :---- |
| `--allowed-tools` | 허용된 도구 목록 | string | `--allowed-tools "Bash,Read,Edit"` |
| `--disallowed-tools` | 금지된 도구 목록 | string | `--disallowed-tools "TaskOutput,KillTask"` |
| `--allowedTools` | 허용된 도구 (GitHub Action용) | string | `--allowedTools "Bash(git:*),View"` |

### 출력 및 로깅

| 플래그 | 설명 | 값 | 예시 |
| :---- | :---- | :---- | :---- |
| `--output-format` | 출력 형식 | json/text/stream-json | `--output-format json` |
| `--input-format` | 입력 형식 | text/stream-json | `--input-format stream-json` |
| `--verbose` | 상세 로그 활성화 | \- | `--verbose` |
| `--json` | JSON 출력 (파이프라인용) | \- | `claude -p "분석" --json` |

### 세션 제어

| 플래그 | 설명 | 값 | 예시 |
| :---- | :---- | :---- | :---- |
| `--max-turns` | 최대 대화 턴 수 제한 | number | `--max-turns 5` |
| `-c --continue` | 최신 대화 로드 | \- | `--continue` |
| `-r --resume` | 특정 세션 재개 | session\_id | `--resume abc123` |

### 작업 디렉토리

| 플래그 | 설명 | 값 | 예시 |
| :---- | :---- | :---- | :---- |
| `--add-dir` | 추가 작업 디렉토리 지정 | path | `--add-dir ../apps ../lib` |

### 시스템 프롬프트

| 플래그 | 설명 | 값 | 예시 |
| :---- | :---- | :---- | :---- |
| `--system-prompt` | 시스템 프롬프트 오버라이드 | string | `--system-prompt "당신은 시니어 개발자입니다"` |
| `--append-system-prompt` | 시스템 프롬프트에 추가 | string | `--append-system-prompt "코드 리뷰도 해주세요"` |

## 인터랙티브 모드 슬래시 명령어

### 기본 세션 관리

| 명령어 | 설명 | 사용법 | 비고 |
| :---- | :---- | :---- | :---- |
| `/help` | 사용 가능한 명령어 목록 | `/help` | 모든 명령어 확인 |
| `/clear` | 대화 히스토리 초기화 | `/clear` | 컨텍스트 윈도우 리셋 |
| `/compact [instructions]` | 대화 압축 | `/compact` | 토큰 사용량 최적화 |
| `/status` | 계정 및 시스템 상태 | `/status` | 현재 상태 확인 |
| `/cost` | 토큰 사용 통계 | `/cost` | 비용 추적. API 사용시에만 동작 |

### 계정 및 로그인

| 명령어 | 설명 | 사용법 | 비고 |
| :---- | :---- | :---- | :---- |
| `/login` | Anthropic 계정 전환 | `/login` | 계정 변경 |
| `/logout` | 계정에서 로그아웃 | `/logout` | 세션 종료 |

### 모델 및 설정

| 명령어 | 설명 | 사용법 | 비고 |
| :---- | :---- | :---- | :---- |
| `/model` | AI 모델 선택/변경 | `/model opus-4` | 모델 전환 |
| `/config` | 설정 표시/변경 | `/config` | 설정 관리 |
| `/permissions` | 권한 설정 표시/업데이트 | `/permissions` | 권한 관리 |

### 프로젝트 관리

| 명령어 | 설명 | 사용법 | 비고 |
| :---- | :---- | :---- | :---- |
| `/init` | CLAUDE.md 가이드로 프로젝트 초기화 | `/init` | 프로젝트 메모리 생성 |
| `/memory` | CLAUDE.md 메모리 파일 편집 | `/memory` | CLAUDE.md의 내용은 인터랙티브 모드 로딩 시 자동으로 읽음 |
| `/add-dir` | 추가 작업 디렉토리 지정 | `/add-dir ../components` | 작업 범위 확장 |

### 코드 리뷰 및 GitHub

| 명령어 | 설명 | 사용법 | 비고 |
| :---- | :---- | :---- | :---- |
| `/review` | 코드 리뷰 요청 | `/review` | 코드 품질 검토 |
| `/pr_comments` | PR 코멘트 표시 | `/pr_comments` | GitHub PR 통합 |
| `/install-github-app` | GitHub 앱 설치 | `/install-github-app` | GitHub 통합 설정 |

### MCP 및 외부 도구

| 명령어 | 설명 | 사용법 | 비고 |
| :---- | :---- | :---- | :---- |
| `/mcp` | MCP 서버 상태 확인 | `/mcp` | 연결된 서버 상태 표시 |

## 

## Alias 등록 및 YOLO Mode 제어 설정

guides/setup/Claude code setup.md를 참조 

## MCP (Model Context Protocol) 명령어 상세

### 기본 MCP CLI 명령어 구조

claude mcp \<subcommand\> \[options\] \[arguments\]

### MCP 하위 명령어

#### 서버 추가 명령어

| 명령어 | 설명 | 문법 | 예시 |
| :---- | :---- | :---- | :---- |
| `claude mcp add` | 기본 서버 추가 (stdio) | `claude mcp add <name> [options] -- <command> [args...]` | `claude mcp add my-server -- /path/to/server arg1 arg2` |
| `claude mcp add --transport sse` | SSE 서버 추가 | `claude mcp add --transport sse <name> <url>` | `claude mcp add --transport sse api-server https://api.example.com/sse-endpoint` |
| `claude mcp add --transport http` | HTTP 서버 추가 | `claude mcp add --transport http <name> <url>` | `claude mcp add --transport http http-server https://example.com/mcp` |
| `claude mcp add-json` | JSON 설정으로 서버 추가 | `claude mcp add-json <name> '<json>'` | `claude mcp add-json weather '{"type":"stdio","command":"node","args":["weather.js"]}'` |

#### 서버 관리 명령어

| 명령어 | 설명 | 문법 | 예시 |
| :---- | :---- | :---- | :---- |
| `claude mcp list` | 설정된 MCP 서버 목록 | `claude mcp list` | \- |
| `claude mcp remove` | MCP 서버 제거 | `claude mcp remove <name>` | `claude mcp remove my-server` |
| `claude mcp get` | 특정 서버 설정 조회 | `claude mcp get <name>` | `claude mcp get github-server` |
| `claude mcp status` | 서버 연결 상태 확인 | `claude mcp status` | \- |

#### MCP 서버 실행 및 연결

| 명령어 | 설명 | 문법 | 예시 |
| :---- | :---- | :---- | :---- |
| `claude mcp serve` | Claude Code를 MCP 서버로 실행 | `claude mcp serve` | \- |
| `claude mcp reset-project-choices` | 프로젝트 승인 선택 초기화 | `claude mcp reset-project-choices` | \- |
| `claude mcp import-claude-desktop` | Claude Desktop 설정 가져오기 | `claude mcp import-claude-desktop` | \- |

### MCP 스코프 옵션

#### 스코프 종류

| 스코프 | 설명 | 사용법 | 적용 범위 |
| :---- | :---- | :---- | :---- |
| `--scope local` (기본값) | 현재 디렉토리에만 적용 | `-s local` 또는 생략 | 현재 프로젝트만 |
| `--scope project` | 프로젝트 전체에 적용 | `-s project` | 프로젝트 루트에 .mcp.json 생성 |
| `--scope user` | 사용자 레벨 전역 적용 | `-s user` | 모든 프로젝트에서 사용 가능 |
| `--scope global` | 시스템 전역 적용 | `-s global` | 시스템 전체 |

### MCP 설정 옵션

#### 환경 변수 설정

| 옵션 | 설명 | 사용법 | 예시 |
| :---- | :---- | :---- | :---- |
| `-e KEY=VALUE` | 환경 변수 설정 | `-e API_KEY=abc123` | `claude mcp add weather -e API_KEY=secret -- node weather.js` |
| `--env KEY=VALUE` | 환경 변수 설정 (긴 형태) | `--env API_KEY=abc123` | `claude mcp add server --env TOKEN=xyz` |

#### HTTP/SSE 서버 옵션

| 옵션 | 설명 | 사용법 | 예시 |
| :---- | :---- | :---- | :---- |
| `--header "KEY: VALUE"` | HTTP 헤더 추가 | `--header "Authorization: Bearer token"` | `claude mcp add --transport http api --header "X-API-Key: key"` |
| `--timeout <seconds>` | 연결 타임아웃 설정 | `--timeout 30` | `claude mcp add server --timeout 60` |

### 인기 MCP 서버 설정 예시

#### GitHub 서버

\# 기본 GitHub MCP 서버

claude mcp add github \-e GITHUB\_PERSONAL\_ACCESS\_TOKEN=ghp\_xxx \-- npx \-y @modelcontextprotocol/server-github

\# 스코프 지정

claude mcp add github-user \-s user \-e GITHUB\_PERSONAL\_ACCESS\_TOKEN=ghp\_xxx \-- npx \-y @modelcontextprotocol/server-github

#### Filesystem 서버

\# 파일시스템 접근 서버

claude mcp add filesystem \-- npx @modelcontextprotocol/server-filesystem $(pwd)

\# 특정 디렉토리 접근

claude mcp add filesystem-home \-- npx @modelcontextprotocol/server-filesystem /home/user

#### 웹 검색 서버

\# Brave 검색 서버

claude mcp add brave-search \-e BRAVE\_API\_KEY=xxx \-- npx @modelcontextprotocol/server-brave-search

\# Perplexity 서버

claude mcp add perplexity \-e PERPLEXITY\_API\_KEY=pplx\_xxx \-- npx \-y perplexity-mcp

#### 데이터베이스 서버

\# PostgreSQL 서버

claude mcp add postgres \-e DATABASE\_URL=postgresql://user:pass@localhost/db \-- npx @modelcontextprotocol/server-postgres

\# SQLite 서버

claude mcp add sqlite \-- npx @modelcontextprotocol/server-sqlite ./database.db

### MCP 서버 JSON 설정 예시

#### 복잡한 서버 설정

\# 복합 설정 예시

claude mcp add-json omnisearch '{

  "type": "stdio",

  "command": "npx",

  "args": \["-y", "mcp-omnisearch"\],

  "env": {

    "TAVILY\_API\_KEY": "tvly-xxx",

    "BRAVE\_API\_KEY": "xxx",

    "KAGI\_API\_KEY": "xxx",

    "PERPLEXITY\_API\_KEY": "pplx-xxx"

  }

}'

#### Docker 컨테이너 기반 서버

\# Docker 컨테이너로 실행

claude mcp add-json docker-server '{

  "type": "stdio",

  "command": "docker",

  "args": \["run", "-i", "--rm", "my-mcp-server:latest"\],

  "env": {

    "API\_KEY": "xxx"

  }

}'

### MCP 환경 변수

#### 전역 MCP 설정 환경 변수

| 변수명 | 설명 | 예시 |
| :---- | :---- | :---- |
| `MCP_TIMEOUT` | MCP 서버 시작 타임아웃 (ms) | `MCP_TIMEOUT=10000 claude` |
| `MCP_LOG_LEVEL` | MCP 로그 레벨 | `MCP_LOG_LEVEL=debug claude` |
| `MCP_CONFIG_PATH` | 사용자 정의 설정 파일 경로 | `MCP_CONFIG_PATH=/custom/path/.mcp.json` |

### MCP 설정 파일 위치

#### 설정 파일 경로

| OS | 설정 파일 위치 |
| :---- | :---- |
| **macOS** | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| **Windows** | `%APPDATA%\Claude\claude_desktop_config.json` |
| **Linux** | `~/.config/claude/claude_desktop_config.json` |
| **프로젝트 스코프** | `<project_root>/.mcp.json` |

### MCP 도구 사용법

#### 인터랙티브 모드에서 MCP 도구 호출

\# MCP 도구 직접 호출 (서버명이 github인 경우)

/mcp\_\_github\_\_list\_prs

\# 인수와 함께 호출

/mcp\_\_github\_\_create\_issue "Bug title" "Bug description"

\# 여러 인수 전달

/mcp\_\_jira\_\_create\_issue "Bug title" high urgent

### MCP 문제 해결

#### 일반적인 문제와 해결책

| 문제 | 해결책 |
| :---- | :---- |
| 서버가 연결되지 않음 | `claude mcp status`로 상태 확인, 환경 변수 검증 |
| 권한 오류 | `--scope user`로 권한 범위 조정 |
| 타임아웃 오류 | `MCP_TIMEOUT` 환경 변수 증가 |
| npx 명령어 실패 | Node.js 및 npm 설치 확인 |
| 프로젝트 서버 승인 안됨 | `claude mcp reset-project-choices` 실행 |

### 유틸리티

| 명령어 | 설명 | 사용법 | 비고 |
| :---- | :---- | :---- | :---- |
| `/doctor` | Claude Code 설치 상태 체크 | `/doctor` | 문제 진단 |
| `/bug` | 버그 보고 (대화를 Anthropic에 전송) | `/bug` | 문제 신고 |
| `/vim` | Vim 모드 진입 | `/vim` | Vim 키바인딩 |
| `/terminal-setup` | Shift+Enter 키바인드 설치 | `/terminal-setup` | 단축키 설정 |

## GitHub Actions 전용 파라미터

| 입력 | 설명 | 필수 | 기본값 | 예시 |
| :---- | :---- | :---- | :---- | :---- |
| `prompt` | 직접 프롬프트 | No\* | '' | "API 서버를 빌드하세요" |
| `prompt_file` | 프롬프트 파일 경로 | No\* | '' | "/path/to/prompt.txt" |
| `allowed_tools` | 허용 도구 (쉼표 구분) | No | '' | "Bash(git:\*),View,Edit" |
| `disallowed_tools` | 금지 도구 (쉼표 구분) | No | '' | "TaskOutput,KillTask" |
| `max_turns` | 최대 대화 턴 수 | No | '' | "5" |
| `mcp_config` | MCP 설정 JSON 파일 또는 문자열 | No | '' | '{"servers": {...}}' |
| `settings` | Claude Code 설정 JSON | No | '' | '{"model": "opus"}' |
| `system_prompt` | 시스템 프롬프트 오버라이드 | No | '' | "당신은 시니어 개발자입니다" |
| `append_system_prompt` | 시스템 프롬프트에 추가 | No | '' | "코드 리뷰도 해주세요" |
| `model` | 사용할 모델 | No | '' | "claude-opus-4-20250514" |
| `fallback_model` | 폴백 모델 | No | '' | "claude-sonnet-4-20250514" |
| `claude_env` | 환경 변수 (YAML 멀티라인) | No | '' | "NODE\_ENV: production" |
| `anthropic_api_key` | Anthropic API 키 | Yes\*\* | '' | "${{ secrets.ANTHROPIC\_API\_KEY }}" |
| `claude_code_oauth_token` | OAuth 토큰 | Yes\*\* | '' | "${{ secrets.CLAUDE\_CODE\_OAUTH\_TOKEN }}" |

\*prompt와 prompt\_file 중 하나는 필수 \*\*anthropic\_api\_key와 claude\_code\_oauth\_token 중 하나는 필수

## 사용자 정의 명령어

### .claude/commands 디렉토리

사용자 정의 슬래시 명령어를 만들 수 있습니다:

mkdir \-p .claude/commands

echo "GitHub 이슈 \#$ARGUMENTS를 분석하고 수정하세요" \> /commands/fix-issue.md

사용법: `/fix-issue 123`

### 전역 명령어

mkdir \-p \~/.claude/commands

## 파이프라인 및 스크립팅

### 데이터 파이프라인

\# CSV 분석

cat data.csv | claude \-p "가장 많이 승리한 사람은?"

\# 로그 모니터링

tail \-f app.log | claude \-p "이상 현상이 보이면 슬랙으로 알려주세요"

\# JSON 출력으로 스크립팅

result=$(claude \-p "코드 생성" \--output-format json)

code=$(echo "$result" | jq \-r '.result')

### 자동화 예시

\# 디버깅과 함께 상세 로그

claude \--verbose \-p "복잡한 쿼리" 

\# 도구 제한

claude \--allowedTools "Read" "Grep" \--disallowed-tools "Edit"

\# 턴 수 제한

claude \--max-turns 3 \-p "간단한 작업"

## 키보드 단축키

| 단축키 | 기능 | 설명 |
| :---- | :---- | :---- |
| `Escape` | Claude 중지 | 실행 중인 작업 중지 |
| `Escape` (2번) | 이전 메시지 목록 | 과거 대화로 점프 |
| `Command+C` | 완전 종료 | 프로그램 종료 |
| `Control+V` | 이미지 붙여넣기 | 클립보드 이미지 (Command+V 아님) |
| `↑` | 이전 대화 탐색 | 과거 세션 검색 |
| `Shift+Enter` | 멀티라인 입력 | 긴 프롬프트 작성 |

## 환경 변수

| 변수명 | 설명 | 예시 |
| :---- | :---- | :---- |
| `ANTHROPIC_API_KEY` | Anthropic API 키 | `sk-ant-api03-...` |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth 토큰 | `token_abc123...` |
| `CLAUDE_MODEL` | 기본 모델 | `claude-opus-4-20250514` |

## 성능 최적화 팁

1. **컨텍스트 관리**: 자주 `/clear` 사용으로 토큰 절약  
2. **압축 활용**: `/compact`로 긴 대화 요약  
3. **YOLO 모드**: `--dangerously-skip-permissions`로 권한 프롬프트 우회  
4. **모델 선택**: 간단한 작업은 Sonnet, 복잡한 작업은 Opus  
5. **도구 제한**: 필요한 도구만 `--allowed-tools`로 지정

## 주의사항

- **YOLO 모드**: `--dangerously-skip-permissions`는 안전한 환경(Docker 등)에서만 사용  
- **토큰 비용**: 대화가 길어지면 `/compact` 또는 `/clear` 활용  
- **권한 관리**: 프로덕션 환경에서는 `--allowed-tools`로 도구 제한  
- **세션 관리**: 작업별로 새 세션 시작 권장

