# SuperClaude 명령어 및 파라미터 목록

## 📋 **명령어(Commands) 목록**

| 명령어 | 카테고리 | 용도 | Wave 지원 | 성능 프로필 |
| :---- | :---- | :---- | :---- | :---- |
| `/build` | Development & Deployment | 프로젝트 빌더 (프레임워크 자동 감지) | ✅ | optimization |
| `/implement` | Development & Implementation | 기능 및 코드 구현 | ✅ | standard |
| `/design` | Design & Architecture | 시스템 아키텍처 및 컴포넌트 설계 | ✅ | standard |
| `/analyze` | Analysis & Investigation | 다차원 코드 및 시스템 분석 | ✅ | complex |
| `/troubleshoot` | Analysis & Investigation | 문제 조사 및 디버깅 | ❌ | complex |
| `/explain` | Analysis & Investigation | 교육적 설명 및 학습 | ❌ | standard |
| `/improve` | Quality & Enhancement | 증거 기반 코드 향상 | ✅ | optimization |
| `/cleanup` | Quality & Enhancement | 프로젝트 정리 및 기술 부채 감소 | ❌ | standard |
| `/test` | Testing & QA | 테스팅 워크플로우 | ❌ | standard |
| `/document` | Documentation | 문서 생성 | ❌ | standard |
| `/git` | Version Control | Git 워크플로우 어시스턴트 | ❌ | standard |
| `/estimate` | Planning | 증거 기반 추정 | ❌ | standard |
| `/task` | Planning | 장기 프로젝트 관리 | ✅ | complex |
| `/load` | Meta | 프로젝트 컨텍스트 로딩 | ❌ | standard |
| `/spawn` | Meta & Orchestration | 작업 오케스트레이션 | ❌ | complex |
| `/index` | Meta | 명령어 카탈로그 탐색 | ❌ | standard |

## 🏁 **플래그(Flags) 목록**

### **🎭 페르소나 활성화 플래그**

| 플래그 | 페르소나 | 전문 분야 | 자동 활성화 |
| :---- | :---- | :---- | :---- |
| `--persona-architect` | 🏗️ architect | 시스템 설계, 장기 아키텍처 | 아키텍처 관련 작업 |
| `--persona-frontend` | 🎨 frontend | UX, 접근성, 프론트엔드 성능 | React/Vue/Angular 작업 |
| `--persona-backend` | ⚙️ backend | API, 데이터베이스, 신뢰성 | 서버 사이드 작업 |
| `--persona-security` | 🛡️ security | 위협 모델링, 취약점 | 보안 관련 코드 |
| `--persona-performance` | ⚡ performance | 최적화, 병목점 제거 | 성능 문제 |
| `--persona-analyzer` | 🔍 analyzer | 근본 원인 분석 | 디버깅, 조사 |
| `--persona-qa` | 🧪 qa | 품질 보증, 테스팅 | 테스트 관련 작업 |
| `--persona-refactorer` | 🔄 refactorer | 코드 품질, 기술 부채 | 리팩토링 작업 |
| `--persona-devops` | 🚀 devops | 인프라, 배포 자동화 | 배포, CI/CD |
| `--persona-mentor` | 👨‍🏫 mentor | 교육, 지식 전달 | 설명, 학습 |
| `--persona-scribe` | ✍️ scribe | 전문 문서화 | 문서 작성 |

### **📊 계획 및 분석 플래그**

| 플래그 | 설명 | 자동 활성화 조건 | 토큰 사용량 |
| :---- | :---- | :---- | :---- |
| `--plan` | 작업 실행 전 계획 표시 | 수동 설정만 | 표준 |
| `--think` | 다중 파일 분석 | import 체인 \>5개, 모듈 간 호출 \>10개 | \~4K |
| `--think-hard` | 심층 아키텍처 분석 | 시스템 리팩토링, 병목점 \>3모듈 | \~10K |
| `--ultrathink` | 최대 심도 분석 | 레거시 현대화, 성능 저하 \>50% | \~32K |

### **⚡ 압축 및 효율성 플래그**

| 플래그 | 설명 | 자동 활성화 조건 | 토큰 절약 |
| :---- | :---- | :---- | :---- |
| `--uc` / `--ultracompressed` | 심볼 기반 압축 출력 | 컨텍스트 사용률 \>75% | 30-50% |
| `--answer-only` | 직접 응답만 (워크플로우 자동화 없음) | 수동 설정만 | 높음 |
| `--validate` | 사전 검증 및 위험 평가 | 위험 점수 \>0.7 | 표준 |
| `--safe-mode` | 최대 검증 모드 | 리소스 사용률 \>85% | 높음 |
| `--verbose` | 최대 상세 설명 | 수동 설정만 | 매우 높음 |

### **🔧 MCP 서버 제어 플래그**

| 플래그 | MCP 서버 | 자동 활성화 조건 | 용도 |
| :---- | :---- | :---- | :---- |
| `--c7` / `--context7` | Context7 | 외부 라이브러리 임포트, 문서 요청 | 문서화 및 패턴 |
| `--seq` / `--sequential` | Sequential | 복잡한 디버깅, 시스템 설계 | 구조화된 분석 |
| `--magic` | Magic | UI 컴포넌트 요청, 프론트엔드 페르소나 | UI 컴포넌트 생성 |
| `--play` / `--playwright` | Playwright | 테스팅 워크플로우, QA 페르소나 | 테스팅 자동화 |
| `--all-mcp` | 모든 MCP | `--ultrathink` 활성화 시 | 종합 분석 |
| `--no-mcp` | MCP 비활성화 | 수동 설정만 | 빠른 실행 |

### **🎯 포커스 및 스코프 플래그**

| 플래그 | 값 | 설명 | 사용 예시 |
| :---- | :---- | :---- | :---- |
| `--focus` | security | 보안 관점 분석 | `--focus security` |
| `--focus` | performance | 성능 관점 분석 | `--focus performance` |
| `--focus` | quality | 품질 관점 분석 | `--focus quality` |
| `--focus` | architecture | 아키텍처 관점 분석 | `--focus architecture` |
| `--scope` | file | 파일 단위 스코프 | `--scope file` |
| `--scope` | module | 모듈 단위 스코프 | `--scope module` |
| `--scope` | project | 프로젝트 단위 스코프 | `--scope project` |
| `--scope` | system | 시스템 단위 스코프 | `--scope system` |

### **🔄 고급 오케스트레이션 플래그**

| 플래그 | 값 | 설명 | 자동 활성화 조건 |
| :---- | :---- | :---- | :---- |
| `--delegate` | auto | 서브 에이전트 자동 위임 | \>7 디렉토리 OR \>50 파일 |
| `--delegate` | force | 강제 서브 에이전트 위임 | 수동 설정만 |
| `--wave-mode` | auto | 자동 웨이브 모드 | 복잡도 ≥0.7 \+ 파일 \>20 |
| `--wave-mode` | force | 강제 웨이브 모드 | 수동 설정만 |
| `--wave-mode` | off | 웨이브 모드 비활성화 | 수동 설정만 |
| `--loop` | \- | 반복 개선 모드 | polish, refine 키워드 감지 |
| `--iterations` | 1-10 | 개선 사이클 수 (기본: 3\) | 수동 설정만 |
| `--interactive` | \- | 사용자 확인 모드 | 수동 설정만 |

### **🔍 투명성 및 내성적 플래그**

| 플래그 | 설명 | 자동 활성화 조건 | 출력 |
| :---- | :---- | :---- | :---- |
| `--introspect` | 깊은 투명성 모드 | SuperClaude 프레임워크 작업 | 🤔 🎯 ⚡ 📊 💡 마커 |
| `--introspection` | 내성적 플래그 (동일) | 복잡한 디버깅 | 대화형 반성 |

## 🎮 **사용 예시**

### **기본 사용법 (자동 활성화)**

/build src/                     \# → frontend 페르소나 \+ magic MCP 자동 활성화

/analyze auth.js               \# → security 페르소나 \+ validate 플래그 자동 활성화

/troubleshoot "performance"    \# → performance 페르소나 \+ sequential MCP 자동 활성화

### **수동 플래그 조합**

/analyze src/ \--focus security \--persona-security \--validate

/improve code.js \--safe-mode \--iterations 5 \--interactive

/build \--wave-mode force \--all-mcp \--ultrathink

### **성능 최적화 조합**

\# 빠른 실행

/analyze \--uc \--no-mcp \--scope file

\# 상세 분석  

/analyze \--think-hard \--all-mcp \--delegate auto

\# 안전한 실행

/improve \--safe-mode \--validate \--preview

## 📋 **플래그 우선순위**

1. **안전 플래그** (`--safe-mode`) \> 최적화 플래그  
2. **명시적 플래그** \> 자동 활성화  
3. **사고 깊이**: `--ultrathink` \> `--think-hard` \> `--think`  
4. **MCP 제어**: `--no-mcp` \> 개별 MCP 플래그  
5. **스코프**: `system` \> `project` \> `module` \> `file`  
6. **페르소나**: 마지막 지정된 페르소나 우선  
7. **웨이브 모드**: `off` \> `force` \> `auto`

## 💡 **자동 활성화 조건 요약**

| 조건 | 자동 활성화되는 플래그/페르소나 |
| :---- | :---- |
| 보안 관련 코드 감지 | `--persona-security`, `--focus security`, `--validate` |
| React/Vue 컴포넌트 | `--persona-frontend`, `--magic` |
| 성능 문제 키워드 | `--persona-performance`, `--focus performance` |
| 복잡도 ≥0.7 \+ 파일 \>20 | `--wave-mode auto` |
| 컨텍스트 사용률 \>75% | `--uc` |
| 위험 점수 \>0.7 | `--validate` |
| polish/refine 키워드 | `--loop` |

---

## 🌊 **Wave 시스템이란?**

**Wave 시스템**은 복잡한 작업을 **여러 단계로 나누어 차례대로 처리**하는 고급 오케스트레이션 시스템입니다.

### **🎭 Wave vs 일반 처리 비교**

| 구분 | 일반 처리 | Wave 처리 |
| :---- | :---- | :---- |
| **방식** | 한 번에 처리 | 여러 단계로 분할 |
| **적용 대상** | 단순한 작업 | 복잡한 대규모 작업 |
| **품질** | 표준 | 30-50% 향상된 결과 |
| **처리 시간** | 빠름 | 더 오래 걸리지만 정확 |

### **🎯 Wave 자동 활성화 조건**

Wave 활성화 조건:

  복잡도: ≥ 0.7

  파일 수: \> 20개

  작업 유형: \> 2가지

예시:

  ✅ "대규모 레거시 시스템 현대화"

  ✅ "엔터프라이즈 보안 감사"  

  ✅ "전체 프로젝트 성능 최적화"

  ❌ "단일 파일 버그 수정"

### **🎯 Wave 전략 4가지**

| 전략 | 용도 | 특징 |
| :---- | :---- | :---- |
| **progressive** | 점진적 개선 | 단계별 향상, 안전함 |
| **systematic** | 체계적 분석 | 철저한 방법론, 정확함 |
| **adaptive** | 동적 구성 | 상황에 맞춰 조정 |
| **enterprise** | 대기업 규모 | 100+ 파일, 복잡도 \>0.7 |

---

## ⚡ **성능 프로필 3가지**

성능 프로필은 **작업의 특성에 따라 리소스 사용을 최적화**하는 방식입니다.

### **🚀 optimization (최적화)**

특징:

  \- 빠른 실행 속도

  \- 캐싱 활용

  \- 병렬 처리

  \- 효율적 리소스 사용

적용 명령어:

  \- /build (프로젝트 빌드)

  \- /improve (코드 개선)

사용 상황:

  \- 자주 실행하는 작업

  \- 빠른 피드백이 필요한 경우

  \- 개발 중 반복 작업

### **📊 standard (표준)**

특징:

  \- 균형잡힌 성능

  \- 적정 리소스 사용

  \- 안정적 처리

  \- 일반적 품질

적용 명령어:

  \- /implement (기능 구현)

  \- /design (설계)

  \- /document (문서화)

  \- /test (테스팅)

사용 상황:

  \- 일반적인 개발 작업

  \- 중간 복잡도 작업

  \- 표준 품질이 필요한 경우

### **🔬 complex (복합)**

특징:

  \- 심층 분석

  \- 높은 리소스 사용

  \- 최고 품질 결과

  \- 긴 처리 시간

적용 명령어:

  \- /analyze (코드 분석)

  \- /troubleshoot (문제 해결)

  \- /task (프로젝트 관리)

사용 상황:

  \- 복잡한 문제 해결

  \- 정확한 분석이 중요한 경우

  \- 품질이 속도보다 중요한 경우

---

## 🎮 **실전 사용 예시**

### **예시 1: 대규모 프로젝트 분석**

/analyze enterprise-system/

**자동 활성화:**

- **Wave 모드**: 파일 200개 \+ 복잡도 0.9 → `auto`  
- **성능 프로필**: `complex` (심층 분석)  
- **전략**: `enterprise` (대기업 규모)

**처리 과정:**

🌊 Wave 1: 구조 분석 및 문제점 식별

🌊 Wave 2: 아키텍처 평가 및 개선 전략

🌊 Wave 3: 상세 분석 및 권장사항

🌊 Wave 4: 검증 및 최종 보고서

### **예시 2: 간단한 컴포넌트 빌드**

/build Button.tsx

**자동 활성화:**

- **Wave 모드**: `off` (단순 작업)  
- **성능 프로필**: `optimization` (빠른 빌드)  
- **전략**: 일반 처리

**처리 과정:**

⚡ 즉시 처리: 컴포넌트 분석 → 빌드 → 결과 반환

### **예시 3: 수동 Wave 강제 활성화**

/improve small-app/ \--wave-mode force \--wave-strategy systematic

**강제 활성화:**

- **Wave 모드**: `force` (수동 지정)  
- **성능 프로필**: `optimization`  
- **전략**: `systematic` (체계적)

---

## 🎯 **Wave 활성화 조건 상세**

### **자동 활성화 매트릭스**

| 조건 | 임계값 | 가중치 |
| :---- | :---- | :---- |
| **복잡도** | ≥ 0.7 | 30% |
| **파일 수** | \> 20개 | 25% |
| **작업 유형** | \> 2가지 | 20% |
| **도메인 수** | \> 1개 | 15% |
| **플래그 modifier** | 특수 키워드 | 10% |

### **복잡도 계산 요소**

높은 복잡도 (0.7+):

  \- 레거시 시스템 현대화

  \- 엔터프라이즈 보안 감사

  \- 성능 저하 \> 50%

  \- 시스템 전체 리팩토링

중간 복잡도 (0.4-0.7):

  \- 모듈 단위 개선

  \- API 설계 및 구현

  \- 중규모 버그 수정

낮은 복잡도 (\< 0.4):

  \- 단일 파일 수정

  \- 간단한 컴포넌트 생성

  \- 문서 업데이트

---

## 💡 **실무 활용 팁**

### **🚀 빠른 작업이 필요할 때**

\# Wave 비활성화로 빠른 처리

/build \--wave-mode off

/improve \--scope file \--uc

### **🔬 정확한 분석이 필요할 때**

\# Wave 강제 활성화로 철저한 분석

/analyze \--wave-mode force \--wave-strategy systematic

/troubleshoot \--ultrathink \--wave-strategy enterprise

### **⚖️ 균형잡힌 처리**

\# 자동 활성화 신뢰 (권장)

/analyze src/

/improve legacy-code/

\# SuperClaude가 알아서 최적 선택

---

