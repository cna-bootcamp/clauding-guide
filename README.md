# Claude를 활용한 서비스 기획, 설계, 개발, 배포 가이드  

- [Claude를 활용한 서비스 기획, 설계, 개발, 배포 가이드](#claude를-활용한-서비스-기획-설계-개발-배포-가이드)
  - [사전준비](#사전준비)
  - [사전지식](#사전지식)
    - [역할과 작업 약어 이해](#역할과-작업-약어-이해)
    - [작업과 약어 사용 프롬프트 예시](#작업과-약어-사용-프롬프트-예시)
    - [프로젝트 단계별 사용 프롬프트](#프로젝트-단계별-사용-프롬프트)
    - [기타 중요한 지침](#기타-중요한-지침)
  - [프로젝트 단계별 Claude Code 이용](#프로젝트-단계별-claude-code-이용)
    - [시작하기](#시작하기)
    - [서비스 기획 하기](#서비스-기획-하기)
      - [작업 방법 가이드](#작업-방법-가이드)
      - [프로토타입 개발](#프로토타입-개발)
    - [설계하기](#설계하기)
      - [작업 방법 가이드](#작업-방법-가이드-1)
      - [시퀀스 설계](#시퀀스-설계)
      - [API 설계](#api-설계)
      - [클래스 설계](#클래스-설계)
    - [개발하기](#개발하기)
      - [작업 방법 가이드](#작업-방법-가이드-2)
      - [백엔드 개발/테스트 팁](#백엔드-개발테스트-팁)
      - [프론트엔드 개발/테스트 팁](#프론트엔드-개발테스트-팁)
        - [프론트엔드설계서 작성](#프론트엔드설계서-작성)
        - [프론트엔드 개발](#프론트엔드-개발)
    - [배포하기](#배포하기)
    - [유용한 Tip](#유용한-tip)
      - [공통 Tip](#공통-tip)
      - [**Lessons Learned 등록하게 하기**](#lessons-learned-등록하게-하기)
      - [**계획 세우게 하기**](#계획-세우게-하기)
      - [**단위테스트 코드 작성시켜 검증하기**](#단위테스트-코드-작성시켜-검증하기)
      - [**서버 로그 디버깅 하기**](#서버-로그-디버깅-하기)
      - [**context7 MCP 이용**](#context7-mcp-이용)
      - [**실행 프로파일 작성**](#실행-프로파일-작성)
      - [**API테스트**](#api테스트)
      - [**버그픽스는 AI, 서버재시작은 사람이 수행**](#버그픽스는-ai-서버재시작은-사람이-수행)
      - [**깊게 고민하게 하기**](#깊게-고민하게-하기)
      - [**이전 git commit 참고 또는 복원하기**](#이전-git-commit-참고-또는-복원하기)

---

**경고) 이 가이드는 토큰을 매우 많이 사용합니다. Max Plan(최소 5배 Plan)으로 업그레이드 할 것을 권고합니다.**

## 사전준비 
- [기본 프로그램 설치(1)](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/00.prepare1.md)
- [Claude Code와 SuperClaude 설치](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/01.install-claude-code.md)
- [Claude Code 설정](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/02.setup-claude-code.md)
- [프로젝트 Instruction 설정](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/01.setup-prompt.md)
  
---

## 사전지식  
CLAUDE.md파일의 설정에 대한 주요 사전지식입니다.   

### 역할과 작업 약어 이해 
SuperClaude 명령어와 파라미터가 복잡하기 때문에 기획, 설계, 개발, 배포에서 사용하는 작업들을   
약어로 만들어서 CLAUDE.md에 만들었습니다.    
위 '프로젝트 Instruction 설정'작업을 하면 생성됩니다.    
프로젝트 루트의 CLAUDE.md 맨 아래에 있습니다.   
작업 뿐 아니라 역할에 대한 약어도 있습니다.    
약어에 대한 의미는 아래 'SuperClaude 명령어 및 파라미터 목록' 문서를 참고하면 됩니다.  
아래 링크의 마지막 부분을 참고하세요.  

[역할과 작업 약어](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/GUIDE.md)

### 작업과 약어 사용 프롬프트 예시   
vscode나 IntelliJ와 통합된 Claude Code에서 수행하면 편합니다.  

**1.웹브라우저 연동**     
'프로토타입'의 위치가 CLAUDE.md에 정의되어 있으므로 그 하위에서 '대시보드'가 포함된 html파일을   
웹브라우저에 자동으로 열어 내용을 분석합니다.  
'--play'는 프론트엔드 테스트를 해주는 Playwright라는 MCP를 사용하라는 옵션입니다.  
```
@analyze as @front --play 프로토타입의 대시보드 화면을 브라우저에서 열어 분석
```

아래와 같이 복합적으로 사용도 가능합니다. 
- 프론트엔드 역할로 웹브라우저에서 '여행지 설정'화면을 띄워 분석  
- 현재 열린 파일에서 유저스토리 ID로 찾아 내용을 이해 
- 화면 분석 결과를 바탕으로 해당되는 유저스토리 ID를 직접 수정  
```
@analyze as @front --play 프로토타입의 여행지설정 화면을 브라우저에서 열어 분석하고,  
@improve as @scribe 유저스토리 'UFR-TRIP-040'을 수정해 줘요.
```

테스트까지 한꺼번에 요청하는 예입니다.  
```
@improve as @front 'UFR-LOC-030'에 명시된 대로 프로토타입 '장소상세정보'화면의 리뷰 및 평점을 수정해 주세요.
@analyze as @front --play 먼저 장소상세정보 화면을 웹브라우저에서 열어 리뷰 부분을 분석한 후 수정 바랍니다.
@test-front 수정 후에는 웹브라우저에서 테스트 까지 해주세요.
```

모바일 화면 크기로 변환하여 여러 페이지를 테스트 할 수도 있습니다. 
```
@test-front 프로토타입을 웹브라우저의 모바일 화면크기로 테스트 해주십시오. 대시보드 화면부터 시작하십시오.    
```

**2.평가요청**   
'@estimate'명령 약어와 역할 약어를 이용하여 어떤 평가를 하게 할 수 있음 

백엔드 개발자와 프론트엔드 개발자가 현재 열린 파일의 유저스토리를 검토하여 스코어를 평가  
```
@estimate as @back and @front 모든 유저스토리에 대해 스코어를 재평가해 주세요
```

Product Owner로서 현재 열린 파일의 유저스토리를 검토하여 비즈니스 중요도를 평가  
역할 약어에 없어도 'PO'라는 말이 CLAUDE.md의 팀 멤버에 있기 때문에 잘 수행됩니다.   
```
@estimate as PO 모든 유저스토리의 비즈니스 중요도를 재평가해 주세요
```

**3.분석요청**   

백엔드 개발자와 프론트엔드 개발자로서 열린 파일의 유저스토리의 기술검토를 수행합니다.  
```
@analyze as @back and @front 모든 유저스토리의 기술적 실현 가능성을 검토해 주세요
```

**4.설명요청**   
아키텍트에게 GIN 인덱스에 대한 설명을 요청합니다.   
```
@explain as @archi GIN인덱스에 대한 설명해줘요.
```

참고) ClaudeCode/SuperClaude 명령과 파라미터
- [Claude Code 명령어 및 파라미터](https://github.com/cna-bootcamp/clauding-guide/blob/main/references/Claude%20Code%20%EB%AA%85%EB%A0%B9%EC%96%B4%20%EB%B0%8F%20%ED%8C%8C%EB%9D%BC%EB%AF%B8%ED%84%B0.md)
- [SuperClaude 명령어 및 파라미터 목록](https://github.com/cna-bootcamp/clauding-guide/blob/main/references/SuperClaude%20%EB%AA%85%EB%A0%B9%EC%96%B4%20%EB%B0%8F%20%ED%8C%8C%EB%9D%BC%EB%AF%B8%ED%84%B0%20%EB%AA%A9%EB%A1%9D.md)

### 프로젝트 단계별 사용 프롬프트 
이 약어들을 이용하여 각 단계별로 작업하는 프롬프트는 아래에 있습니다.  
- [기획 프롬프트](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/02.think-prompt.md)
- [설계 프롬프트](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/03.design-prompt.md)
- [개발 프롬프트](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/04.develop-prompt.md)
- [배포 프롬프트]()

**1.프로젝트 단계별 가이드**.   
CLAUDE.md에는 각 프로젝트 단계별로 사용되는 가이드의 URL이 정의되어 있습니다.   
프로젝트 단계별 사용하는 프롬프트는 이 가이드를 참조하도록 되어 있습니다.   
예를 들어 아래와 같이 'UI/UX설계가이드'의 URL이 정의되어 있기 때문에   
프롬프트에 'UI/UX설계가이드'를 참조하라고 하면 이 URL이 claude/uiux-design.md 디렉토리에 다운로드 되어  
Claude Code가 사용하게 됩니다.  
```
- UI/UX설계가이드
  - 설명: UI/UX 설계 방법 안내 
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/design/uiux-design.md
  - 파일명: uiux-design.md
```

**2.산출물 디렉토리 약어 이해**.   
CLAUDE.md에는 각 단계별 산출물의 위치가 정의되어 있습니다.   
프롬프트에서 산출물 이름만 입력하면 Claude Code는 그 위치를 알 수 있게 됩니다. 

### 기타 중요한 지침
CLAUDE.md에는 중요한 지침들이 더 있습니다.     
- Git연동: '[Git 연동]' 섹션 참조   
  Claude Code에 아래 명령을 사용하여 Git과 연동 합니다. 
  - pull: 원격 Git Repo에서 pull을 수행하고 충돌 시 최신 파일로 자동 병합합니다.   
  - push 또는 푸시: 변경사항을 비교하여 자동으로 commit message를 만들고 원격 Git Repo에 푸시합니다.  
- URL링크 처리: '[URL링크 참조]' 섹션 참조   
  Claude는 URL링크가 있으면 기본적으로 WebFetch라는 툴로 다운로드 합니다.   
  문제는 **원본 그대로 다운로드 하지 않고** 자기가 요약 또는 변형한다는 것입니다.  
  그래서 이 지침을 제공하여 curl명령으로 파일을 다운로드 해서 사용하도록 가이드 하는 것입니다.   
- 핵심원칙: '[핵심 원칙]' 섹션 참조   
  - 서브 에이젼트를 만들어 병렬 처리하게 함으로써 처리 속도를 높이도록 합니다.  
  - PlantUML 스크립트와 OpenAPI swagger 파일을 만들면 반드시 검사까지 하도록 합니다.  
- 가이드 로딩: '[가이드 로딩]' 섹션 참조  
  - CLAUDE.md에 있는 가이드('[가이드] 섹션 하위에 있음')를 갱신하는 지침입니다.   
  - 가이드를 표준화하여 공통으로 사용하기 위한 지침입니다.  
  - 프롬프트에 '가이드 로딩'이라고 입력하면 원격 Repository의 가이드를 다시 다운로드 하여 CLAUDE.md를 갱신합니다.    
  
---

## 프로젝트 단계별 Claude Code 이용  
### 시작하기 
- Claude 로그인: Claude Code 를 실행하고 '/login'명령으로 수행 
- Claude Model 선택: '/model'명령 수행하여 선택. 설계 시에는 opus가 더 나으나 토큰이 빨리 소모됨  
  
'프로젝트 단계별 사용 프롬프트'를 이용하여 순서대로 작업하면 됩니다.   
중간 중간 자주 '/clear'명령을 사용해 주세요. 이전 대화 기록을 삭제하므로 토큰 절약에 약간(?) 도움 됩니다.   
- 프롬프트 로딩: 
  - 프롬프트 창에 '프롬프트 로딩'이라고 입력하여 기획, 설계, 개발, 배포 명령어를 로딩합니다. 
    - 모두 완료 후 Claude Code를 '/exit'로 종료 후 재시작합니다.  
    - 이 작업은 한 번만 수행하면 됩니다.
  - 완료 후 '/think-help', '/design-help', '/develop-help', '/deploy-help'를 입력하면 작업 순서와 각 작업의 명령어를 확인할 수 있습니다.      
- 가이드 갱신: 
  - [Claudeing Guide](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/GUIDE.md)의 '최종 수정일시'값과 CLAUDE.md의 '[가이드]'섹션 아래에 있는 '최종 수정일시'가 다르면 갱신이 필요 합니다.  
  - 프롬프트 창에 '가이드 로딩'이라고 입력하면 갱신됩니다.  

### 서비스 기획 하기
#### 작업 방법 가이드  
- [서비스 기획 가이드](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/think/think-guide.md)  
- [유저스토리 작성하기](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/02.think-prompt.md) 

#### 프로토타입 개발
- 수동 테스트 요청 
  가이드에는 프로토타입 개발 완료 후 자동으로 웹브라우저에서 테스트하라고 되어 있는데, 안할 수 있음.  
  아래 프롬프트로 수행 요청을 합니다.  
  ```
  @test-front 웹브라우저에서 테스트 해주세요.
  ```
  시간이 조금 걸리는 데 한참 멈춘것 같으면 아래 프롬프트로 진행상황 문의할 수 있습니다.  
  ```
  테스트가 아직 진행중인가요? 
  ```
- 수정 요청 
  수정 사항을 요청하고 바로 테스트까지 수행하도록 요청할 수 있습니다.  
  계속 수정할 수 있으니 브라우저를 종료하지 말라고 합니다. 
  ```
  각 화면간 전환이 되도록 개발해 줘요. @test-front 개발 완료 후 웹브라우저에서 테스트까지 해주세요. 
  계속 수정할 수 있으니 브라우저는 종료하지 말아요.
  ```

  모든 수정이 완료되면 브라우저를 종료 요청합니다. 
  ```
  모두 잘 수정 되었네요. 고생 했어요. 이제 브라우저를 종료해요. 
  ```

### 설계하기 
#### 작업 방법 가이드
**1.사전 설치**   
설계하기 부터는 추가로 아래 링크의 프로그램들을 설치하고 시작 하십시오.     
[기본 프로그램 설치(2)](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/00.prepare2.md)

**2.설계 프롬프트**   
[설계 프롬프트](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/03.design-prompt.md)

#### 시퀀스 설계
- 프로토타입을 먼저 보여주고 설계를 하는것도 좋습니다. 현재 가이드에는 그렇게 되어 있습니다.  
- 시퀀스 설계 결과 검토 시 
관련된 프로토타입 화면을 보고 개선하라고 하는게 좋습니다.  
예)
```
프로토타입 기본설정 화면을 웹브라우저로 띄워서 확인한 후 계속 해 주세요.
```

- 설계서 리뷰와 수정이 끝나면 설계간의 일관성 검사를 요청함 
```
@analyze @archi @back @front --ultrathink 외부/내부 시퀀스 설계를 꼼꼼히 리뷰하여 설계간의 일관성과 충돌 여부를 검사해 주세요.
```
- 분석결과에서 적용이 필요한 부분 수정 요청
예)
```
긴급개선사항 API 엔드포인트 통일, 캐싱 TTL 표준화, 상태 값 통일만 적용 바랍니다.
```

#### API 설계

설계서 리뷰와 수정이 끝나면 시퀀스설계서와의 일관성 검사를 요청합니다.  
```
@analyze as @archi @back @front --ultrathink 외부시퀀스설계서와 내부시퀀스설계서의 설계 결과와 일관성 검사를 해주세요.
```

#### 클래스 설계
클래스간의 Dependency와 Association 관계가 제대로 표현 안된 경우 개선 요청합니다. 
```
@improve as @back 클래스 관계 Dependency와 Association이 제대로 표현 안되어 있으니 개선 바랍니다. 
서브 에이젼트를 병렬로 수행하여 동시에 수행하세요.
```

간단 클래스설계서({서비스명}-simple.puml)가 가이드대로 잘 생성이 안된 경우, 수정 요청합니다. 
```
클래스설계가이드의 간단 클래스설계서 규칙을 다시 읽고 잘못된것을 고쳐줘요.
서브 에이젼트를 병렬로 수행하여 동시에 수행하세요.
```

### 개발하기
#### 작업 방법 가이드
[개발 프롬프트](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/04.develop-prompt.md)

#### 백엔드 개발/테스트 팁
한꺼번에 모든 서비스를 개발하면 누락되는것이 많을 수 있습니다.   
각 서비스별로 개발하는게 좋습니다.   
만약 서비스가 복잡하면 각 기능단위로 개발하는게 더 좋습니다.     
```
@develop as @back user-service를 개발해 주세요.  
```

개발을 할 때는 계획-수행-테스트의 과정으로 하십시오.   
아래 예시를 참조하세요.  
https://github.com/cna-bootcamp/clauding-guide/blob/main/samples/sample-%EA%B8%B0%EB%8A%A5%EC%B6%94%EA%B0%80%EC%98%88%EC%8B%9C.md


**테스트**       
백엔드 테스트도 각 서비스별로 하나씩 테스트하는게 좋습니다.   
각 서비스별로 **각 API를 하나 하나 테스트** 합니다.   
이때 AI에게 맡겨만 두지 말고 **진행상황을 꼭 모니터링**해야 합니다.   
왜냐하면 중간에 엉뚱하게 바꾸거나 임시코드를 만들거나 가이드와 다르게 수행하는 경우가 종종 있기 때문입니다.    
사람의 개입이 필요하다고 판단되면 'ESC'를 눌러 수행을 잠시 중단하게 하고 프롬프팅을 해서 작업 수정 요청합니다.   
그리고 계속 진행해도 되면 '계속'이라고 입력합니다.    

#### 프론트엔드 개발/테스트 팁
##### 프론트엔드설계서 작성

1)프론트엔드설계서 작성 요청   
프론트엔드설계서 작성 시 API명세서를 참조하므로 백엔드를 실행하고 swagger api docs페이지 주소를 제공합니다.  
API명세서는 design/backend/api/spec디렉토리에 생성됩니다.   
프론트엔드설계서는 design/frontend/frontend-design.md 파일로 생성됩니다.  
예시)
```
/design-frontend
[API명세서 주소]
- user service: http://localhost:8081/v3/api-docs
- location service: http://localhost:8082/v3/api-docs
- trip service: http://localhost:8083/v3/api-docs
- ai service: http://localhost:8084/v3/api-docs
```

2)검토후 수정 요청   
예시)
```
프론트엔드설계서 검토의견
- 2.1 사이트맵
  - 메인영역에 로그아웃 추가
  - 질문: 프로필 변경, 암호변경은 사이트맵에 추가할 필요 없나요?   
- 3.2 UI/UX 설계서 업데이트
  - API명세서에 정의된 모든 API가 반영되었는지 점검 
  - AI일정생성 화면: 실시간 상태 확인이 AI service의 API임을 명확히 함
- 7.1 API 클라이언트 설정
  - getBaseURL: 'localhost:{포트}' 대신에 '${gatewayHost}'를 사용해야 함
  - 7.2 백엔드 API 경로 정보: 각 서비스 엔드포인트 변수는 필요 없음. 위 getBaseURL함수 이용 
```

3)팀원리뷰 요청   
```
팀원 여러분, 프론트엔드설계서를 검토해 주세요.  
```

4)팀원의견 반영   
```
팀원의견을 반영하여 프론트엔드설계서를 갱신해 주세요. 
단, 백엔드에서 지원 않하는 기능은 반영하지 마세요. 
```

##### 프론트엔드 개발
1)프로젝트 디렉토리 생성 및 Instruction 설정    
[프로젝트 Instruction 설정](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/01.setup-prompt.md)가이드에 따라 프론트엔드 프로젝트 디렉토리 생성 및 Instruction 설정 수행  

2)개발   
```
/develop-dev-front
```

3)검토    
검토계획 수립
```
@plan \
프론트엔드설계서를 다시 꼼꼼히 보고 누락되거나 개선된것이 있는지 찾으세요.
그리고 개선계획서를 claude 디렉토리 밑에 생성하세요. 
- 슈도코드를 포함하여 상세하게 작성 
- 계획서만 작성하고 개발은 검토후 진행
```

4)검토결과 반영   
검토결과에서 제외할 부분을 명시하여 추가 개발 요청 

예시)
```
프론트엔드 계선 계획서를 보고 누락된 주요 기능을 개발하세요. '제외'항목은 제외하고 개발.   
### 1.2 누락된 주요 기능

#### 설계서에 명시되었으나 미구현된 항목: '제외'항목은 추가 개발하지 않음  
  1. **React Query 설정 및 적용** ⚠️
  2. **PWA 설정 (오프라인 지원)** ⚠️ => 제외
  3. **국제화(i18n) 시스템** ⚠️ => 제외 
  4. **드래그 앤 드롭 기능** (일정 재배치) ⚠️
  5. **Web Vitals 모니터링** ⚠️ => 제외
  6. **에러 바운더리 고도화** ⚠️ => 제외
  7. **이미지 최적화 (LazyImage)** ⚠️
  8. **폼 유효성 검증 시스템** ⚠️ => 제외
  9. **테스트 코드** ⚠️ => 제외
  10. **Storybook 설정** ⚠️ => 제외
```

5)API명세서 일치 확인   
API명세서랑 다른 부분을 점검하고 수정하도록 합니다. 
```
각 API의 path, request, response를  API명세서를 다시 보고 틀린걸 수정하세요.
```

6)빌드 및 에러 수정 요청    
```
프로그램을 빌드하고 에러를 잡아주세요.  
```

7)실행 및 에러 수정 요청    
아래 명령으로 로컬에서 실행하고 웹브라우저에서 오픈한 후 런타임 에러를 수정하세요.   
```
npm run dev
```

직접 브라우저로 열어 런타임 에러를 수정하게 할 수도 있습니다.  
예시)
``` 
-play http://localhost:3000번으로 접근하여 에러가 있으면 수정해요. 
```
```
'http://localhost:3000/dashboard'을 웹브라우저로 열어 직접 확인해봐요.
id: hiondal, pw: 0sri1234$ 
```

### 배포하기
[배포 프롬프트]()

### 유용한 Tip
#### 공통 Tip
- 작업 중단 시키기: 
  - 작업 중 ESC를 누르면 진행중인 작업이 중단됩니다.
  - 다시 시작하려면 '계속'이라고 입력. 또는 특정 단계명을 입력하여 계속하게 함.
    예) 아래와 같은 단계로 구성되어 있었고 5번째 단계에서 ESC로 취소한 경우  
    '외부 시퀀스 다이어그램 작성 (주요 플로우별)'의 처음부터 시작   
    ```
    Update Todos
    ⎿  ☒ 공통설계원칙 가이드 다운로드 및 분석       
      ☒ 외부시퀀스설계가이드 다운로드 및 분석
      ☒ 유저스토리 분석 및 주요 플로우 도출
      ☒ API 설계서 확인 및 연계
      ☐ 외부 시퀀스 다이어그램 작성 (주요 플로우별)
      ☐ 회원가입/로그인 플로우 다이어그램 작성
      ☐ 여행 일정 생성 플로우 다이어그램 작성
      ☐ 주변 장소 검색 플로우 다이어그램 작성
      ☐ PlantUML 문법 검증
      ☐ 일정 재생성 플로우 다이어그램 작성
      ☐ 일정 내보내기 플로우 다이어그램 작성
    ```
  - 완전히 중단하려면 '/clear'를 수행    
- 병렬 작업 시키기:
  - CLAUDE.md의 '[핵심원칙]'섹션에 병렬 처리 전략이 있으므로 병렬 처리가 됨  
  - 만약 병렬처리를 안하면 '서브 에이젼트로 병렬처리'라는 프롬프트를 추가하면 됨   

- 프롬프트에 이미지 제공 방법   
  - CLAUDE.md에 정의된 아래 약어 이용  
    - @error: debug/error.png 
    - @info: debug/info.png  
  - 사용방법
    - 에러 화면인지 정보 제공 화면인지에 따라 화면을 캡처하여 파일로 저장  
    - 프롬프트팅에 약어를 이용   
  - 사용예시
    ```
    @fix as @front 
    아래 오류를 해결해 주세요. see @error 
    [오류내용] 
    ```

#### **Lessons Learned 등록하게 하기**     
Claude Code는 완벽하지 않아 시행착오를 자꾸합니다.   
이를 방지하기 위해 아래와 같이 'CLAUDE.md'에 재실수를 방지하기 위한 추가 지침을 하도록 합니다.  
그냥 등록하라고 하면 너무 길게 등록하므로 '간략하고 명확하게' 등록하라고 합니다.  

```
CLAUDE.md에 'Lessons Learned' 섹션을 추가하고 
실수를 했을 때 재실수를 방지하기 위한 지침을 간략하고 명확하게 추가하세요.   
```
  
AI가 실수 하면 아래 예와 같이 Lessons Learned에 추가 요청합니다.  
예1)
```
소스를 수정하면 컴파일까지 하고 서버 재시작을 사람에게 요청해야 합니다. lessons learned 에 간략하고 명확하게 추가하세요.
```
예2)
실행을 'ESC'로 멈추고 지침 추가를 요청.  
```
잠깐 환경설정값은 applicaiton.yml이 아니라 실행프로파일을 점검해야 합니다. lessons learned에 간략하고 명확하게 추가해주고 계속해줘요.
```

#### **계획 세우게 하기**    
개발이나 리팩토링을 실제 수행하기 전에 계획을 먼저 세우게 하고 검토하는 것이 좋습니다.  
```
@plan 'AsyncProcessingServie'클래스에서 공통함수를 분리할 계획을 세우세요.  
```

#### **단위테스트 코드 작성시켜 검증하기**     
추가/수정된 코드가 검증이 필요하다고 판단되면 클로드에게 단위테스트코드를 작성하라고 요청하십시오.   
그리고 그 단위테스트 코드를 직접 수행하여 코드에 문제가 없는지 검증 시키십시오.    
이때 실제와 동일한 sample 데이터를 제공하여 정확도를 높이는게 좋습니다.  

```
지금 추가한 코드를 '테스트코드표준'를 준용하여 단위 테스트 코드를 작성해 검증 합시다.
'ScheduleGenerationMessageRequest'객체는 resource/mq_dailyrequest.json을 이용하세요.  
```

sample 데이터는 실제 데이터로 하는게 당연히 제일 좋습니다.    
코드에 sample데이터를 특정 디렉토리에 남기도록 요청해서 만드세요. 
```
선택영역 밑에 scheduleJson과 promptRequest의 값을 파일로 만들어요.            
resource/validate_place_schedule.json과 resource/valiedate_place_promptrequest.json으로 만들고 계속 덮어쓰면 되요.                                      
```

#### **서버 로그 디버깅 하기**       
application.yml에 'logs/{service-name}.log'로 콘솔 로그를 남기도록 설정하도록 되어 있습니다.  
만약 안되어 있으면 추가하도록 요청하세요.   
```
# Logging Configuration
logging:
  ...
  file:
    name: ${LOG_FILE:logs/trip-service.log}
  logback:
    rollingpolicy:
      max-file-size: 10MB
      max-history: 7
      total-size-cap: 100MB
```
서버 시작 시 에러나 테스트 시 런타임 에러가 나면 이 로그를 보고 원인을 분석해서 해결하도록 요청하세요.  

#### **context7 MCP 이용**        
최신 개발 Best practice를 참조하여 개발할 수 있습니다.  
context7 MCP를 이용하면 됩니다.   
개발명령어(/develop-dev-backend, /develop-fix-backend, develop-test-backend)에 이미 '-c7'이라는 옵션이 있습니다.   
이 명령어를 사용하지 않고 프롬프트에서 수정이나 개선을 요청할 때는 이 옵션을 명시해 줘야 합니다.   
예) -c7 Google Place API를 이용하여 주변 주차장 정보를 찾도록 해주세요.  

#### **실행 프로파일 작성**     
'/develop-make-run-profile' 명령으로 IntelliJ의 서비스 실행 프로파일을 작성할 수 있습니다.    
{service}/.run/{service}.run.xml에 등록됩니다.    
등록이 되면 서비스탭에 나타납니다.    
![](images/2025-08-07-09-23-54.png)  
먼저 실행구성을 클릭하고 'Gradle'이나 'Maven' 등 빌드툴을 선택해야 표시됩니다.   
![](images/2025-08-07-09-24-30.png)    

#### **API테스트**      
'@test-api'를 앞에 붙여 테스트를 요청하면 API 스펙을 정확히 확인하여 테스트 하게 됩니다.  

```
@test-api recommendations API를 테스트 해요.

토큰: eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJmZjA0NGNkYy04YTMxLTRkZWUtYmQ5Yi04YjNlMTdhYTcyNWQiLCJpYXQiOjE3NTQ1MjI4ODMsImV4cCI6MTc1NDYwOTI4MywidHlwZSI6ImFjY2VzcyJ9.mQVnFKUDtMa426Qn25_2UMj8uABJ85uFwVrgdEsulZI
```

하지만 가끔 제대로 수행 못하는 경우가 있습니다.  
이때는 아래와 같이 swagger page에서 curl 명령어를 복사하여 제공하세요.  
```
로그아웃 API 를 테스트 하고 에러를 고쳐주세요.

curl -X 'POST' \
  'http://localhost:8081/api/v1/users/logout' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJmZjA0NGNkYy04YTMxLTRkZWUtYmQ5Yi04YjNlMTdhYTcyNWQiLCJpYXQiOjE3NTU4MzU2MTMsImV4cCI6MTc1NTkyMjAxMywidHlwZSI6ImFjY2VzcyIsInVzZXJuYW1lIjoib25kYWwiLCJhdXRob3JpdHkiOiJVU0VSIn0.qM3x9jm4IbQbJ7M3rpuaoAKtOuOv9WP6ERc5fGLBJEw' \
  -d ''
```

#### **버그픽스는 AI, 서버재시작은 사람이 수행**           
AI가 서버 재시작을 하면 시간이 오래 걸리거나 제대로 못합니다.    
서버재시작은 본인이 하겠다고 프롬프트에 말해 주세요.   
'/develop-test-backend'명령어에는 이미 이 프롬프트가 있지만 가끔 AI가 서버를 시작하려고 합니다.    
프롬프트 예시)
```
이제 테스트를 시작하는데 컴파일까지는 네가 하고 서버 시작은 나한테 요청해 주세요.   
```

만약, 프롬프트에 서비스 직접 실행을 요청할 때는 '@run-back' 약어 사용.
특별한 경우가 아니면 사람이 시작하는게 편하고 빠릅니다.    
```
@run-back user-service
```

서버가 시작되어 있어 포트 충돌이 나면 중단해달라고 요청하고 실행 프로파일로 시작함. 
```
user service를 중단하세요.  
```

#### **깊게 고민하게 하기**    
잘 문제를 못풀면 깊게 고민하는 옵션을 프롬프트에 추가할 수 있습니다.  
고민을 얼마나 깊게 할 지에 따라 --think, --think-hard, --ultra-think가 있습니다.  
```
--think 
```

#### **이전 git commit 참고 또는 복원하기**   
개발하다 보면 이전 commit 소스를 찾아 참고하거나 복원해야할 경우가 있습니다. 
이때 commit id를 제공하여 작업을 수행할 수 있습니다.    
```
원격 commit 'abb2a9d'에서 찾아서 API '일자별 일정 재생성' API와 관련 리소스 클래스를 복원해요.
```


