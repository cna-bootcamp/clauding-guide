# Claude를 활용한 서비스 기획, 설계, 개발, 배포 가이드

**⚠️ 법적 고지**    
본 가이드의 모든 내용은 저작자의 동의없이 상업적 목적으로 사용할 수 없으며, 개인 학습 목적으로만 사용 가능합니다.   
(저작자: 이해경, 유니콘주식회사 대표, hiondal@gmail.com)  

## 목차  
- [Claude를 활용한 서비스 기획, 설계, 개발, 배포 가이드](#claude를-활용한-서비스-기획-설계-개발-배포-가이드)
  - [목차](#목차)
  - [사전준비](#사전준비)
  - [프로젝트 생성 및 Instruction 설정](#프로젝트-생성-및-instruction-설정)
  - [유용한 Tip](#유용한-tip)
    - [공통 Tip](#공통-tip)
    - [Lessons Learned 등록하게 하기](#lessons-learned-등록하게-하기)
    - [context7 MCP 이용](#context7-mcp-이용)
    - [깊게 고민하게 하기](#깊게-고민하게-하기)
    - [이전 git commit 참고 또는 복원하기](#이전-git-commit-참고-또는-복원하기)
    - [Azure 방화벽 오픈](#azure-방화벽-오픈)
  - [프로젝트 단계별 수행 가이드](#프로젝트-단계별-수행-가이드)
    - [서비스 기획 하기](#서비스-기획-하기)
      - [1.상위수준기획](#1상위수준기획)
      - [2.기획 구체화](#2기획-구체화)
      - [3.유저스토리 작성](#3유저스토리-작성)
      - [4.프로토타입 개발](#4프로토타입-개발)
    - [백엔드 설계](#백엔드-설계)
      - [0.사전 설치](#0사전-설치)
      - [1.클라우드 아키텍처 패턴 선정](#1클라우드-아키텍처-패턴-선정)
      - [2.논리아키텍처 설계](#2논리아키텍처-설계)
      - [3.외부 시퀀스 설계](#3외부-시퀀스-설계)
      - [4.내부 시퀀스 설계](#4내부-시퀀스-설계)
      - [5.API설계](#5api설계)
      - [6.클래스 설계](#6클래스-설계)
      - [7.데이터 설계](#7데이터-설계)
      - [8.High Level 아키텍처 정의서 작성](#8high-level-아키텍처-정의서-작성)
      - [9.물리 아키텍처 설계](#9물리-아키텍처-설계)
    - [클라우드 환경 설정](#클라우드-환경-설정)
    - [백엔드 개발](#백엔드-개발)
      - [백킹서비스 설치](#백킹서비스-설치)
      - [백엔드 개발/테스트](#백엔드-개발테스트)
    - [프론트엔드 설계](#프론트엔드-설계)
    - [프론트엔드 개발](#프론트엔드-개발)
    - [컨테이너로 배포하기](#컨테이너로-배포하기)
      - [컨테이너 이미지 빌드](#컨테이너-이미지-빌드)
      - [컨테이너 실행](#컨테이너-실행)
      - [컨테이너 명령어 실습](#컨테이너-명령어-실습)
    - [쿠버네티스에 배포하기](#쿠버네티스에-배포하기)
      - [ingress controller 추가](#ingress-controller-추가)
      - [백엔드 배포](#백엔드-배포)
      - [프론트엔드 배포](#프론트엔드-배포)
      - [쿠버네티스 리소스 학습](#쿠버네티스-리소스-학습)
      - [kubectl 명령어 실습](#kubectl-명령어-실습)
    - [CI/CD](#cicd)
      - [CI/CD 툴 설치: Jenkins, SonarQube, ArgoCD](#cicd-툴-설치-jenkins-sonarqube-argocd)
      - [Jenkins를 이용한 CI/CD](#jenkins를-이용한-cicd)
        - [백엔드 서비스](#백엔드-서비스)
        - [프론트엔드 서비스](#프론트엔드-서비스)
        - [WebhHook 설정](#webhhook-설정)
      - [GitHub Actions를 이용한 CI/CD](#github-actions를-이용한-cicd)
        - [백엔드 서비스](#백엔드-서비스-1)
        - [프론트엔드 서비스](#프론트엔드-서비스-1)
      - [ArgoCD를 이용한 CI와 CD 분리](#argocd를-이용한-ci와-cd-분리)
  - [맺음말](#맺음말)

---

**경고) 이 가이드는 토큰을 매우 많이 사용합니다. Max Plan(최소 5배 Plan)으로 업그레이드 할 것을 권고합니다.**

## 사전준비 
- [기본 프로그램 설치(1)](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/00.prepare1.md)
- [Claude Code와 SuperClaude 설치](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/01.install-claude-code.md)
- [Claude Code 설정](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/02.setup-claude-code.md)

| [Top](#목차) |

---

## 프로젝트 생성 및 Instruction 설정   
아래 가이드를 참고하여 프로젝트 디렉토리를 만들고 Instruction를 설정합니다.    

https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/01.setup-prompt.md

## 유용한 Tip
### 공통 Tip
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

- 특정 대화 재개
  - 바로 이전 대화 계속하기  
    대화창을 종료한 후에 다시 그 대화를 계속하고 싶을 때 'claude -r' 옵션을 사용   
  - 특정 대화로 진입하여 계속하기     
    클로드코드 대화창에서 '/resume'이라고 입력하고 엔터를 지면 과거 대화 목록이 나옵니다.   
    여기서 대화를 선택하면 됩니다.   

- 병렬 작업 시키기:
  - CLAUDE.md의 '[핵심원칙]'섹션에 병렬 처리 전략이 있으므로 병렬 처리가 됨  
  - 만약 병렬처리를 안하면 '서브 에이젼트로 병렬처리'라는 프롬프트를 추가하면 됨   

- 프롬프트에 이미지 제공 방법   
  제공할 이미지를 클립보드에 복사한 후 프롬프트창에 붙여 넣습니다.   
  맥은 'CTRL-V'키, 윈도우는 'ALT-V' 키를 이용하여 붙입니다.   

| [Top](#목차) |

---

### Lessons Learned 등록하게 하기     
Claude와 같은 AI와 같이 작업할 때 과거 작업을 기억하는데 한계가 있어 이전 실수를 반복할 경우가 있습니다.      
이를 방지하기 위해 아래와 같이 'CLAUDE.md'에 재실수를 방지하기 위한 추가 지침을 하도록 합니다.   
CLAUDE.md는 Claude Code 실행 시 메모리에 로딩되므로 대화를 종료하지 않는 한 기억할 가능성이 높아집니다.   
그냥 등록하라고 하면 너무 길게 등록하므로 '간략하고 명확하게' 등록하라고 합니다.  

```
CLAUDE.md에 'Lessons Learned' 섹션을 추가하고 
실수를 했을 때 재실수를 방지하기 위한 지침을 간략하고 명확하게 추가하세요.   
```
  
AI가 실수 하면 아래 예와 같이 Lessons Learned에 추가 요청합니다.  
예1)
```
소스를 수정하면 컴파일까지 하고 서버 재시작을 사람에게 요청해야 합니다. lessons learned 에 간략하고. 명확하게 추가하세요.
```
예2)
실수가 포착되면 실행을 'ESC'로 멈추고 지침 추가를 요청.  
```
잠깐 환경설정값은 applicaiton.yml이 아니라 실행프로파일을 점검해야 합니다. lessons learned에 간략하고. 명확하게 추가해주고 계속해줘요.
```

| [Top](#목차) |

---

### context7 MCP 이용       
최신 개발 Best practice를 참조하여 개발할 수 있습니다.  
context7 MCP를 이용하면 됩니다.   
개발명령어(/develop-dev-backend, /develop-fix-backend, develop-test-backend)에 이미 '-c7'이라는 옵션이 있습니다.   
이 명령어를 사용하지 않고 프롬프트에서 수정이나 개선을 요청할 때는 이 옵션을 명시해 줘야 합니다.   
예) -c7 Google Place API를 이용하여 주변 주차장 정보를 찾도록 해주세요.  

| [Top](#목차) |

---

### 깊게 고민하게 하기  
잘 문제를 못풀면 깊게 고민하는 옵션을 프롬프트에 추가할 수 있습니다.  
고민을 얼마나 깊게 할 지에 따라 --think, --think-hard, --ultra-think가 있습니다.  
```
--think 왜 로그인 에러가 나는지 원인을 찾아요.  
```

| [Top](#목차) |

---

### 이전 git commit 참고 또는 복원하기  
개발하다 보면 이전 commit 소스를 찾아 참고하거나 복원해야할 경우가 있습니다. 
이때 commit id를 제공하여 작업을 수행할 수 있습니다.    
```
원격 commit 'abb2a9d'에서 찾아서 API '일자별 일정 재생성' API와 관련 리소스 클래스를 복원해요.
```

| [Top](#목차) |

---

### Azure 방화벽 오픈
AKS에 배포된 DB나 서비스를 접근하기 위해 방화벽 포트를 오픈하는 방법입니다.    
- AKS찾기   
![](images/2025-09-01-17-22-07.png)

- 노드풀 클릭: 기본 생성되는 노드풀 이름은 보통 'nodepool1'임.  
![](images/2025-09-01-17-24-30.png)

- 서브넷 클릭 
  ![](images/2025-09-01-17-25-43.png)

- 보안그룹 클릭 
  ![](images/2025-09-01-17-26-23.png)

- 방화벽 포트 추가 :  
  ![](images/2025-09-01-17-26-59.png)
  
  ![](images/2025-09-01-17-28-01.png)  

| [Top](#목차) |

---

## 프로젝트 단계별 수행 가이드  

### 서비스 기획 하기

#### 1.상위수준기획
Design Thinking 기반으로 문제정의와 솔루션 탐색/선택을 합니다.   
[서비스 기획하기](https://github.com/cna-bootcamp/aiguide/blob/main/AI%ED%99%9C%EC%9A%A9%20%EC%84%9C%EB%B9%84%EC%8A%A4%20%EA%B8%B0%ED%9A%8D%20%EA%B0%80%EC%9D%B4%EB%93%9C.md)

상위수준 서비스 기획은 온라인Claude 또는 Claude Desktop에서 수행합니다.   

| [Top](#목차) |

---

#### 2.기획 구체화 
DDD 전략설계 방법인 Event Storming기법을 이용하여 기획을 구체화 합니다.   
기획 구체화는 Figma에서 수행합니다.  

- 팀원들과 Event Storming 수행  
Event Storming을 Figma의 FigJam을 이용하여 수행합니다. 
![](design/think/images/2025-07-26-15-24-23.png) 

- Claude 활용한 보완  
Claude Desktop/Clade Code에서 MCP를 사용하여 Figma를 연동하여 수행합니다.  

  **1)사전준비: [MCP 설치/MCP Plugin 설치](https://github.com/cna-bootcamp/clauding-guide/blob/main/references/MCP%EC%84%A4%EC%B9%98%EA%B5%AC%EC%84%B1.md#figma-mcp-%EC%84%A4%EC%B9%98)**
  
  **2)Claude Desktop 또는 Claude Code에서 프롬프팅**   
  예시)
  ```
  Figma 채널'cgqs7jzi'의 이벤트 스토밍 결과를 읽어 아래를 수행해 주십시오.                                                                                 │
    - 도메인 이벤트를 분석하여 추가가 필요한 이벤트를 추천 
  ```

| [Top](#목차) |

---

#### 3.유저스토리 작성   
피그마로 이벤트스토밍을 수행한 경우 아래와 같이 Figma MCP를 이용하여 유저스토리 초안을 빠르게 만듭니다.   
기획 구체화는 Claude Code에서 수행합니다.  이 이후의 작업은 Claude Code에서 수행합니다.   

- 백엔드 프로젝트 디렉토리 생성 및 프로젝트 Instruction 설정
  이미 수행하였다면 Skip 하십시오.  
  https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/01.setup-prompt.md

- Claude Code 시작하기   
  작업 디렉토리 이동  
  ```
  cd ~/home/workspace/{백엔드 디렉토리}  
  ```

  YOLO모드로 전환   
  ```
  claude-yolo
  ```

  Claude Code 시작: 터미널에서 시작하거나 IntelliJ에서 시작합니다.  
  IntelliJ 내부에서 Claude Code 시작: 작업이 더 편해 권장      
  ![](images/2025-09-01-22-25-58.png)   

  터미널에서 시작
  ```
  claude 
  ```


- 이벤트스토밍결과 선택 및 MCP Plugin 수행: 피그마에서 이벤트스토밍결과를 선택하고 우측 마우스 버튼에서 'Cursor Talk to Figma MCP Plugin' 수행  
![](images/2025-09-01-15-31-35.png)

- 프롬프팅
  MCP 플러그인에서 제공한 채널ID를 제공하여 요청합니다.   
  예제)
  ```
  /think-userstory
  [요구사항]
  피그마 채널ID 'abcde'에 접속하여 분석
  ```
- 유저스토리 검토/수정
  'design/userstory.md'파일로 생성된 유저스토리를 검토하고 수정합니다.  

| [Top](#목차) |

---

#### 4.프로토타입 개발
**1.UI/UX설계**   
아래 명령을 수행합니다.    
```
/design-uiux
```

UI/UX설계서와 스타일가이드가 생성됩니다.      
- UI/UX설계서: design/uiux/uiux.md
- 스타일가이드: design/uiux/style-guide.md 

**2.프로토타입 개발 요청**    
아래 명령을 수행합니다.    
``` 
/design-prototype
```
프로토타입 파일들이 아래와 같은 형식으로 생성됩니다.   
design/uiux/prototype/{화면순서번호 2자리}-{화면명}.html    

**3.프로토타입 테스트**    
```
/design-test-prototype
```

**4.프로토타입 버그픽스**       
예시)
```
/design-fix-prototype
[오류내용]
- 이메일 형식 검사가 제대로 안됨  
```

**5.프로토타입 개선**    
추가 또는 개선사항을 요청합니다.   

예시)
```
/design-improve-prototype
[개선내용]
- 암호 보이기/숨기기 기능 추가  
```

**6.유저스토리 업데이트**    
모든 프로토타입을 완성한 후에 변경사항을 유저스토리에 업데이트 하도록 요청 합니다.   
```
/design-improve-userstory
```

**7.UI/UX설계서와 스타일가이드 업데이트**     
변경된 유저스토리에 따라 UI/UX설계서와 스타일가이드도 업데이트 요청 합니다.   
```
/design-update-uiux
```

**8.유용한 팁**   
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

| [Top](#목차) |

---

### 백엔드 설계 
#### 0.사전 설치
설계하기 부터는 추가로 아래 링크의 프로그램들을 설치하고 시작 하십시오.     
[기본 프로그램 설치(2)](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/00.prepare2.md)
  
아래 설계 프롬프트에 있는 순서대로 '클라우드 아키텍처 패턴 선정' 부터 '물리 아키텍처 설계'까지 수행 합니다.   
[설계 프롬프트](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/prompt/03.design-prompt.md)


| [Top](#목차) |

---

#### 1.클라우드 아키텍처 패턴 선정   
적용할 클라우드 아키텍처 패턴을 추천받고 검토합니다.   
결과는 'design/pattern/architecture-pattern.md'에 생성됩니다.  

```
/clear
```

```
/design-pattern
```

클라우드 아키텍처 패턴 선정 결과를 검토하고 적용할 패턴을 결정합니다.   
결정한 패턴만으로 클라우드 아키텍처 패턴 문서를 정리 요청합니다.   

예시) 
```
기존 클라우드 아키텍처 패턴 적용 방안을 백업하고 
아래 클라우드 아키텍처 패턴만 적용하는 것으로 문서를 재작성 하세요.   
- API Gateway 
- Cache-Aside 
- Circuit Breaker  
```

| [Top](#목차) |

---

#### 2.논리아키텍처 설계
논리 아키텍처를 설계하고 검토합니다.   
결과는 'design/backend/logical' 디렉토리에 생성됩니다.   
```
/clear
```

```
/design-logical
```

| [Top](#목차) |

---

#### 3.외부 시퀀스 설계  
각 서비스 사이, 서비스와 외부시스템 사이의 인터페이스를 외부 시퀀스로 설계합니다.   
결과는 '/design/backend/outer' 디렉토리에 생성됩니다.  
```
/clear
```

```
/design-seq-outer
```

| [Top](#목차) |

---

#### 4.내부 시퀀스 설계
각 서비스 내부의 처리 흐름을 내부 시퀀스로 설계합니다.   
결과는 '/design/backend/inner' 디렉토리에 생성됩니다.   
```
/clear
```

```
/design-seq-inner
```

- 설계 개선 시 프로토타입 활용
  설계 결과가 요구사항을 제대로 반영 못했다고 생각되면 관련된 프로토타입 화면을 보고 개선하라고 하는게 좋습니다.  
  예)
  ```
  프로토타입 기본설정 화면을 웹브라우저로 띄워서 확인한 후 계속 해 주세요.
  ```

- 설계서 리뷰와 수정이 끝나면 설계간의 일관성 검사를 요청함 
  ```
  @analyze @archi @back @front --think 외부/내부 시퀀스 설계를 꼼꼼히 리뷰하여 설계간의 일관성과 충돌 여부를 검사해 주세요.
  ```

  분석결과에서 적용이 필요한 부분 수정 요청    
  예)  
  ```
  긴급개선사항 API 엔드포인트 통일, 캐싱 TTL 표준화, 상태 값 통일만 적용 바랍니다.
  ```

| [Top](#목차) |

---

#### 5.API설계   
각 서비스의 API를 설계합니다.  
결과는 '/design/backend/api' 디렉토리에 생성됩니다.   
생성된 swagger 파일(확장자가 yaml)을 'https://editor.swagger.io/'에 붙여서 테스트 하면서 검토합니다.   
```
/clear
```

```
/design-api
```

설계서 리뷰와 수정이 끝나면 시퀀스설계서와의 일관성 검사를 요청합니다.  
```
@analyze as @archi @back @front --think 외부시퀀스설계서와 내부시퀀스설계서의 설계 결과와 일관성 검사를 해주세요.
```

아래처럼 서버를 localhost가 아닌 다른 서버를 선택하고 테스트 하면서 검토합니다.   
![](images/2025-09-08-11-58-46.png)

| [Top](#목차) |

---

#### 6.클래스 설계
각 서비스의 클래스 설계를 합니다.
아래 예제와 같이 설계를 위한 정보를 프롬프트에 제공합니다. 
결과는 'design/backend/class' 디렉토리에 생성됩니다.   
```
/clear
```

예제)
```
/design-class
[클래스설계 정보]
- 패키지 그룹: com.unicorn.tripgen
- 설계 아키텍처 패턴 
  - User: Layered 
  - Trip: Clean
  - Location: Layered 
  - AI: Layered
```

- 클래스간의 Dependency와 Association 관계가 제대로 표현 안된 경우 개선 요청합니다. 
  ```
  @improve as @back 클래스 관계 Dependency와 Association이 제대로 표현 안되어 있으니 개선 바랍니다. 
  서브 에이젼트를 병렬로 수행하여 동시에 수행하세요.
  ```

- 간단 클래스설계서({서비스명}-simple.puml)가 가이드대로 잘 생성이 안된 경우, 수정 요청합니다. 
  ```
  클래스설계가이드의 간단 클래스설계서 규칙을 다시 읽고 잘못된것을 고쳐줘요.
  서브 에이젼트를 병렬로 수행하여 동시에 수행하세요.
  ```

| [Top](#목차) |

---

#### 7.데이터 설계
데이터설계를 합니다.  
결과는 'design/backend/database' 디렉토리에 생성됩니다.  
```
/clear
```

```
/design-data
```

| [Top](#목차) |

---

#### 8.High Level 아키텍처 정의서 작성
지금까지 설계를 바탕으로 상위 수준의 종합적인 아키텍처 정의서를 작성합니다.    
'CLOUD' 항목에 사용할 클라우드플랫폼 제공자를 Azure, AWS, Google과 같이 입력합니다.   
결과는 'design/high-level-architecture.md'에 생성됩니다.   
```
/clear
```

예시)
```
/design-high-level
- CLOUD: Azure
```

| [Top](#목차) |

---

#### 9.물리 아키텍처 설계
클라우드 플랫폼에 배포하기 위한 물리 아키텍처를 설계합니다.   
'CLOUD' 항목에 사용할 클라우드플랫폼 제공자를 Azure, AWS, Google과 같이 입력합니다.   
결과는 'design/backend/physical' 디렉토리에 생성됩니다.    
물리 아키텍처는 개발환경과 운영환경으로 나누어 설계됩니다. 
```
/clear
```

예시)
```
/design-physical
- CLOUD: Azure
```

| [Top](#목차) |

---

### 클라우드 환경 설정
개발을 위해서는 사전에 클라우드 환경설정이 완료되어야 합니다.   
Azure외의 클라우드 플랫폼은 Claude나 Perplexity를 이용하여 작업합니다.  

가이드를 참고하여 아래 작업만 하십시오. 
- Azure 구독
- 리소스 프로바이더 등록
- 리소스그룹 생성
- Azure CLI 설치 및 로그인
- 기본 configuratioon 셋팅 
- AKS/ACR생성

https://github.com/cna-bootcamp/handson-azure/blob/main/prepare/setup-server.md

| [Top](#목차) |

---

### 백엔드 개발
#### 백킹서비스 설치
**0.사전작업**   
터미널을 열고 데이터베이스를 배포할 클라우드플랫폼에 로그인하고 Kubernetes 인증 정보를 가져옵니다.   
각 클라우드플랫폼별 CLI와 Kubernetes 인증정보를 갖고 오는 방법은 claude나 perplexity에 문의하세요.    

예를 들어 Azure는 아래와 같이 작업합니다.   
- Azure 로그인   
```
az login 
```

- AKS(Azure Kubernetes Service) 인증정보 획득    
```
az aks get-credentials [-g {리소스그룹}] -n {AKS명} -f ~/.kube/config
```
예시)
```
az aks get-credentials -n dg0100-aks -f ~/.kube/config
```

**1.데이터베이스 설치**    
1)데이터베이스 설치 계획서 작성    
'develop/database/plan' 디렉토리에 개발환경과 운영환경의 설치계획서가 생성됩니다.  
```
/clear
```

```
/develop-db-guide
```
2)데이터베이스 설치 수행    
데이터베이스를 계획서에 따라 설치합니다.   
'[설치정보]' 섹션에 설치정보를 제공해줘야 합니다.   
설치결과 레포트가 'develop/database/exec' 디렉토리에 생성됩니다.   
```
/clear
```

예시)
```
/develop-db-install
[설치정보]
- 설치대상환경: 개발환경
- AKS Resource Group: rg-digitalgarage-01
- AKS Name: aks-digitalgarage-01
- Namespace: tripgen-dev
```


3)방화벽오픈    
데이터베이스를 로컬에서 접속할 수 있도록 방화벽 포트를 오픈합니다.    
AKS기준으로 작성되었으며 다른 클라우드의 Kubernetes서비스는 Claude나 perplexsity에 문의하여 작업하세요.    

- 오픈할 포트 찾기
  db와 redis가 사용하는 포트를 찾습니다.   
  ![](images/2025-09-01-17-33-15.png)

- [방화벽 오픈](https://github.com/cna-bootcamp/clauding-guide/tree/main?tab=readme-ov-file#azure-%EB%B0%A9%ED%99%94%EB%B2%BD-%EC%98%A4%ED%94%88) 참고하여 포트 오픈 


**팁) 데이터베이스 제거**    
설치된 데이터베이스를 모두 제거하려면 아래 프롬프트를 이용합니다.   
```
/clear
```

```
/develop-db-remove
```

**2.MQ 설치**    
1)설치계획서 작성    
Message Queue 설치계획서 작성을 요청합니다.    
결과는 'develop/mq/mq-plan-{대상환경}.md' 파일로 생성됩니다.   
```
/clear
```

```
/develop-mq-guide
```

2)MQ설치    
Message Queue 설치를 요청합니다.   
'[설치정보]' 섹션에 설치정보를 제공해줘야 합니다.   
결과는 'develop/mq/mq-exec-{대상환경}.md' 파일로 생성됩니다.   
```
/clear
```

예제)
```
/develop-mq-install
[설치정보]
- 설치대상환경: 개발환경
- Resource Group: rg-digitalgarage-01
- Namespace: tripgen-dev
```

**팁) MQ 제거**    
설치된 MQ를 모두 제거하려면 아래 프롬프트를 이용합니다.   
```
/clear
```

```
/develop-mq-remove
```


| [Top](#목차) |

---

#### 백엔드 개발/테스트
 
**1.초안개발**        
1)개발요청   
설계 결과를 참조하여 모든 백엔드서비스를 개발 요청합니다.    
간단한 기능은 제대로 개발하나 복잡한 기능은 TODO로 남겨놓는 경우도 많습니다.  
```
/clear
```

```
/develop-dev-backend
```

2)마이크로서비스 확인    
개발 초기에 settings.gradle이 생성되면 올바르게 마이크로서비스를 정의했는지 확인합니다.   
만약 잘못되어 있다면 ESC를 눌러 잠깐 중지하고 아래 예와 같이 정정 요청합니다.     
![](images/2025-09-08-15-49-15.png)


3)개발완료 체크 요청     
```
/clear
```

```
/develop-dev-backend

```

4)Gradle 프로젝트 인식 확인    
아래와 같이 우측 바 3번째에 코끼리 아이콘이 나와야 합니다.   
![](images/2025-09-08-22-43-36.png)  

만약 나오지 않는다면 아래와 같이 조치합니다.   
'.idea' 디렉토리를 선택하고 우측 마우스 메뉴에서 '삭제'를 수행합니다.   


'[파일] > 캐시무효화'를 클릭합니다. 그리고 '무효화 및 다시 시작'버튼을 누릅니다.   
![](images/2025-09-08-22-45-39.png)

프로젝트 재시작 후 Gradle로 인식되는지 확인합니다.   

5)자바 버전 설정    
설정에서 자바 버전을 루트 build.gradle에 지정한 버전과 일치시킵니다.   
![](images/2025-09-08-22-56-55.png)

6)컴파일 하기   
먼저 '빌드' 탭이 나오도록 합니다.    
![](images/2025-09-08-22-49-02.png)

서비스를 선택하고 우측 마우스 메뉴에서 '빌드'를 선택합니다.    
![](images/2025-09-08-22-50-38.png)  

'빌드'탭에서 컴파일 결과를 확인합니다.   
에러가 나면 클로드에 버그 픽스를 요청합니다.   
예)   
```
product service 빌드 및 버그 픽스 
```

**2.실행 프로파일 작성**    
서비스를 실행하기 위한 실행 프로파일을 작성 요청합니다.    
각 서비스에 생성된 application.yml을 분석하여 환경변수까지 등록된 IntelliJ의 서비스 실행 프로파일이 작성됩니다.       
결과는 {service}/.run/{service}.run.xml로 생성됩니다.    
```
/clear
```

'[작성정보]'에 외부 API Key와 같은 정보를 제공하세요.  
DB나 Redis의 접근 정보는 지정할 필요 없습니다. 특별히 없으면 '[작성정보]'섹션에 '없음'이라고 하세요.      

예1)  
```
/develop-make-run-profile
[작성정보]
- API Key
  - Claude: sk-ant-ap...
  - OpenAI: sk-proj-An4Q...
  - Open Weather Map: 1aa5b...
  - Kakao API Key: 5cdc24....
```

예2)   
```
/develop-make-run-profile
[작성정보]
없음
```

등록이 되면 서비스탭에 나타납니다.    
![](images/2025-08-07-09-23-54.png)  
먼저 실행구성을 클릭하고 'Gradle'이나 'Maven' 등 빌드툴을 선택해야 표시됩니다.   
![](images/2025-08-07-09-24-30.png)    


팁) 실행 프로파일이 존재하지만 서비스탭에 표시 안되는 경우    
실행 프로파일에 오류가 있기 때문입니다.   
프롬프트에 실행 프로파일 오류를 체크하여 수정하라고 하십시오.   

예)  
```
실행 프로파일 'ai-service.run.xml'이 실행 프로파일로 인식되지 않고 있습니다.   
문제를 체크하여 수정해 주십시오.  
```

**3.로그파일 설정 하기**       
application.yml에 'logs/{service-name}.log'로 콘솔 로그를 남기도록 되어 있지 않다면 추가하도록 요청하세요.   
서버 시작 시 에러나 테스트 시 런타임 에러가 나면 이 로그를 보고 원인을 분석하도록 요청하기 위해서 로그파일을 만듭니다.    
예제)
```
아래 예제와 같이 각 서비스의 로그를 남기도록 설정을 추가하세요.    
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

**4.서버 재시작은 사람이 수행하게 하기**           
AI가 서버 재시작을 하면 시간이 오래 걸리거나 제대로 못합니다.    
서버재시작은 사람이 하겠다고 Lessons Learned에 등록하게 요청 하세요.

```
CLAUDE.md에 Lessons Learned 섹션을 만들고, 아래 예시처럼 개발 워크플로우를 등록하세요.   

예시)
# Lessons Learned 
## 개발 워크플로우 
- **❗ 핵심 원칙**: 코드 수정 → 컴파일 → 사람에게 서버 시작 요청 → 테스트
- **소스 수정**: Spring Boot는 코드 변경 후 반드시 컴파일 + 재시작 필요
- **컴파일**: 최상위 루트에서 `./gradlew {service-name}:compileJava` 명령 사용
- **서버 시작**: AI가 직접 서버를 시작하지 말고 반드시 사람에게 요청할것
```

**5.런타임에러 해결**         
'서비스'탭에서 서비스를 실행합니다.   
에러가 나면 AI에게 에러 메시지를 제공하거나 로그를 분석하여 에러를 해결하도록 요청합니다.    

예1)
```
user-service 런타임 에러가 발생합니다.   

Task :api-gateway:bootRun FAILED
00:49:19.924 [main] ERROR org.springframework.boot.SpringApplication -- Application run failed
...
```

예2)  
```
user-service 런타임 에러가 발생합니다.   
서버 로그를 분석하여 해결하세요.   
```

일단, 모든 서비스의 런타임에러까지 해결한 후 다음 단계를 진행합니다.   

**6.방화벽 오픈**    
API swagger 페이지 접속을 위해 방화벽 오픈 작업을 합니다.   

- 오픈할 포트 찾기 
각 서비스의 실행 프로파일에서 'SERVER_PORT'값을 확인
![](images/2025-09-01-17-43-08.png)   
![](images/2025-09-01-17-44-19.png)

- [방화벽 오픈](https://github.com/cna-bootcamp/clauding-guide/tree/main?tab=readme-ov-file#azure-%EB%B0%A9%ED%99%94%EB%B2%BD-%EC%98%A4%ED%94%88) 참고하여 오픈  

**7.API별 개발**          
각 API별로 (AI)API 테스트 -> (AI)코드수정 및 컴파일 -> (사람)서버 재시작의 과정을 반복하면서 완성해 나갑니다.   
가장 먼저 완성해야할 API는 '로그인'입니다.   

로그인API를 예로 해서 API별 개발을 설명하겠습니다.    
0)사용자등록   
사용자 등록 API가 없으면 개발 요청을 합니다.      
개발된 API를 이용하여 로그인을 하여 토큰을 구합니다.  

1)Swagger페이지 접속 및 설정   
'http://localhost:{서비스별 포트}/swagger-ui.html'으로 접속합니다.   
로그인 API를 수행합니다.   
![](images/2025-09-01-17-57-51.png)   


2)에러 발생 시 API명령을 제공하여 에러 수정 요청   

![](images/2025-09-01-17-58-20.png)  

```
/clear
```

예시)
```
로그인 API 를 테스트 하고 에러를 고쳐주세요.

curl -X 'POST' \
  'http://localhost:8081/api/v1/users/login' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d '{
  "username": "trip01",
  "password": "P@ssw0rd$",
  "rememberMe": true
}'
```

3)코드수정 및 컴파일    
AI가 코드를 수정하고 컴파일까지 하는것을 모니터링 합니다.   
엉뚱한 수행을 하려고 하면 'ESC'를 눌러 중지시키고 프롬프트에 새로운 요청을 합니다.   

코드 수정 후 컴파일을 제대로 하는지 확인합니다.   
서버를 시작하려고 하면 즉시 중단시키고 CLAUDE.md의 가이드대로 서버 시작은 사용자에게 요청해야 한다고 말해 줍니다.   

4)서비스 재시작    
'서비스'탭에서 서비스를 재시작 합니다.   
중단하고 시작하는게 좋습니다.      
![](images/2025-09-01-18-03-25.png)  

5)재 테스트를 요청

```
서버 재시작 했어요. 다시 테스트 하세요. 
```

'1) ~ 5)' 작업을 각 API별로 수행하십시오.   

  
인증이 필요한 API는 아래와 같이 사전 작업을 한 후 수행하세요.   
1)토큰복사    
로그인API 수행 결과에서 accessToken값 복사   
![](images/2025-09-01-18-06-58.png)

2)인증처리

![](images/2025-09-01-18-07-34.png)

![](images/2025-09-01-18-08-05.png)

3)API 테스트
아래 예와 같이 Authorization 헤더에 토큰값이 셋팅되어야 합니다.   
```
curl -X 'GET' \
  'http://localhost:8081/api/v1/users/check/email/user01%40tripgen.com' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxYTFhNDViNi1lZmU5LTRjMjMtOWI2Yi05NTgwYmExNWNhZDkiLCJpYXQiOjE3NTY3MTcwNzYsImV4cCI6MTc1NjgwMzQ3NiwidHlwZSI6ImFjY2VzcyIsInVzZXJuYW1lIjoidHJpcDAxIiwiYXV0aG9yaXR5IjoiVVNFUiJ9.ht7mmEtZyuba5FXnjtEByDFAQGTXI3Uwb3PLrJyQH8A'
```

**8.복잡한 기능 개발**         
복잡한 기능을 개발을 할 때는 계획-수행-테스트의 과정으로 하십시오.   
아래 예시를 참조하세요.  
https://github.com/cna-bootcamp/clauding-guide/blob/main/samples/sample-%EA%B8%B0%EB%8A%A5%EC%B6%94%EA%B0%80%EC%98%88%EC%8B%9C.md

개발 진행 과정을 꼭 지켜보셔야 합니다.   
AI가 엉뚱하게 개발하는 경우가 가끔 있기 때문입니다.   
이때는 빨리 ESC로 중단하고 올바른 방법을 안내해줘야 합니다.   

팁) 단위테스트 코드 작성시켜 검증하기      
추가/수정된 코드가 검증이 필요하다고 판단되면 클로드에게 단위테스트코드를 작성하라고 요청하십시오.   
그리고 그 단위테스트 코드를 직접 수행하여 코드에 문제가 없는지 검증 시키십시오.    
이때 실제와 동일한 sample 데이터를 제공하여 정확도를 높이는게 좋습니다.  

예시)  
```
지금 추가한 코드를 '테스트코드표준'를 준용하여 단위 테스트 코드를 작성해 검증 합시다.
'ScheduleGenerationMessageRequest'객체는 resource/mq_dailyrequest.json을 이용하세요.  
```

sample 데이터는 실제 데이터로 하는게 당연히 제일 좋습니다.    
코드에 sample데이터를 특정 디렉토리에 남기도록 요청해서 만드세요.  

예시)  
파일 생성 부분을 소스에서 선택하여 코드를 추가할 곳을 지정할 수 있습니다.   
```
선택한 라인 밑에 scheduleJson과 promptRequest의 값을 파일로 만드는 코드를 추가해요.             
resource/validate_place_schedule.json과 resource/valiedate_place_promptrequest.json으로 만들고 계속 덮어쓰면 되요.                                      
```
  
**9.Git 레포지토리 생성 및 푸시**   
GitHub에 원격 레포지토리를 생성합니다.   
![](images/2025-09-12-15-21-00.png) 

Private 레포지토리로 지정합니다.  
내용에 보안 정보가 있을 가능성이 높기 때문입니다.   
![](images/2025-09-12-15-21-32.png)

원격 레포지토리 주소를 복사합니다.   
![](images/2025-09-12-15-22-42.png)  

프로젝트 디렉토리로 이동 후 로컬 레포지토리를 생성합니다.
```
cd ~/home/workspace/phonebill
```

Git설정을 먼저 하세요.
https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/00.prepare1.md#git-%EC%84%A4%EC%A0%95
  
로컬 레포지토리 생성.   
```
git init
```

브랜치를 main으로 변경.   
```
git checkout -b main
```

원격 레포지토리 주소를 지정.  
```
git remote add origin {원격 레포지토리 주소}
```

원격 레포지토리로 푸시.   
```
git add . 
```

```
git commit -m "{메시지}"
```

```
git push -u origin main
```

Git Bash나 Mac에서는 아래 예와 같이 한줄로 사용할 수 있습니다.   
```
git add . && git commit -m "push first" && git push -u origin main
```

'-u origin main'은 최초 한번만 하면 됩니다.  


| [Top](#목차) |

---

### 프론트엔드 설계
**1.준비작업**  
1)작업 디렉토리 작성  
{사용자홈}/home/workspace 밑에 작성합니다.   
예시)
```
mkdir -p ~/home/workspace/tripgen-front 
```
vscode에서 오픈합니다.   
예시)  
```
cd ~/home/workspace/tripgen-front
code . 
```

2)CLAUDE.md 생성    
아래 내용으로 CLAUDE.md 파일을 만듭니다.   
```
# 프론트엔드 가이드

[Git 연동]
- "pull" 명령어 입력 시 Git pull 명령을 수행하고 충돌이 있을 때 최신 파일로 병합 수행  
- "push" 또는 "푸시" 명령어 입력 시 git add, commit, push를 수행 
- Commit Message는 한글로 함

[URL링크 참조]
- URL링크는 WebFetch가 아닌 'curl {URL} > claude/{filename}'명령으로 저장
- 동일한 파일이 있으면 덮어 씀 
- 'claude'디렉토리가 없으면 생성하고 다운로드   
- 저장된 파일을 읽어 사용함

## 산출물 디렉토리 
- 프로토타입: design/prototype/*
- API명세서: design/api/*.json
- UI/UX설계서: design/frontend/uiux-design.md
- 스타일가이드: design/frontend/style-guide.md
- 정보아키텍처: design/frontend/ia.md
- API매핑설계서: design/frontend/api-mapping.md
- 유저스토리: design/userstory.md

## 가이드 
- 프론트엔드설계가이드
  - 설명: 프론트엔드 설계 방법 안내 
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/design/frontend-design.md
  - 파일명: frontend-design.md
- 프론트엔드개발가이드
  - 설명: 프론트엔드 개발 가이드 
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/develop/dev-frontend.md
  - 파일명: dev-frontend.md   
- 프론트엔드컨테이너이미지작성가이드
  - 설명: 프론트엔드 컨테이너 이미지 작성 가이드  
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/deploy/build-image-front.md
  - 파일명: build-image-front.md
- 프론트엔드컨테이너실행방법가이드
  - 설명: 프론트엔드 컨테이너 실행방법 가이드  
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/deploy/run-container-guide-front.md
  - 파일명: run-container-guide-front.md
- 프론트엔드배포가이드
  - 설명: 프론트엔드 서비스를 쿠버네티스 클러스터에 배포하는 가이드  
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/deploy/deploy-k8s-front.md
  - 파일명: deploy-k8s-front.md 
- 프론트엔드Jenkins파이프라인작성가이드
  - 설명: 프론트엔드 서비스를 Jenkins를 이용하여 CI/CD하는 배포 가이드  
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/deploy/deploy-jenkins-cicd-front.md
  - 파일명: deploy-jenkins-cicd-front.md  
- 프론트엔드GitHubActions파이프라인작성가이드
  - 설명: 프론트엔드 서비스를 GitHub Actions를 이용하여 CI/CD하는 배포 가이드  
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/deploy/deploy-actions-cicd-front.md
  - 파일명: deploy-actions-cicd-front.md 

## 프롬프트 약어 
### 역할 약어 
- "@front": "--persona-front"
- "@devops": "--persona-devops"

### 작업 약어 
- "@complex-flag": --seq --c7 --uc --wave-mode auto --wave-strategy systematic --delegate auto

- "@plan": --plan --think
- "@dev-front": /sc:implement @front --think-hard @complex-flag
- "@cicd": /sc:implement @devops --think @complex-flag
- "@document": /sc:document --think @scribe @complex-flag
- "@fix": /sc:troubleshoot --think @complex-flag
- "@estimate": /sc:estimate --think-hard @complex-flag
- "@improve": /sc:improve --think @complex-flag
- "@analyze": /sc:analyze --think --seq 
- "@explain": /sc:explain --think --seq --answer-only 

## Lessons Learned
**프론트엔드 개발 절차**:
- 개발가이드의 "6. 각 페이지별 구현" 단계에서는 빌드 및 에러 해결까지만 수행
- 개발서버(`npm run dev`) 실행은 항상 사용자가 직접 수행
- 개발자는 빌드(`npm run build`) 성공까지만 확인하고 서버 실행을 사용자에게 요청
- 개발자가 임의로 서버를 실행하고 테스트하지 않고 사용자 확인 후 진행

**프로토타입 분석 및 테스트**:
- 프로토타입 HTML 파일은 반드시 Playwright MCP를 사용하여 모바일 화면(375x812)에서 확인
- 프로토타입의 모든 인터랙션과 액션을 실제로 클릭하여 동작 확인 필요

**서비스 재배포 가이드**
서비스 수정 후 재배포 시 다음 절차를 따릅니다:
1. 이미지 빌드: deployment/container/build-image.md 참조하여 빌드 
2. 이미지를 ACR형식으로 태깅
3. 컨테이너 실행: deployment/container/run-container-guide.md의 '8. 재배포 방법' 참조하여 실행 
   - 컨테이너 중단
   - 이미지 삭제
   - 컨테이너 실행
* 테스트는 사용자에게 요청

```

3)유저스토리와 프로토타입 복사      
백엔드개발 시 만든 유저스토리와 프로토타입을 아래 디렉토리에 복사합니다.   
- 유저스토리: design/userstory.md
- 프로토타입: design/prototype/*

**2.프론트엔드 설계 요청**       
프론트엔드설계서 작성 시 API명세서를 참조하므로 백엔드를 실행하고 swagger api docs페이지 주소를 제공합니다.  
API명세서는 design/api 디렉토리에 생성됩니다.   
프론트엔드설계서는 아래와 같이 생성됩니다.
- UI/UX설계서: design/frontend/uiux-design.md
- 스타일가이드: design/frontend/style-guide.md
- 정보아키텍처: design/frontend/ia.md
- API매핑설계서: design/frontend/api-mapping.md
  
예시) 백엔드시스템과 요구사항은 본인 프로그램에 맞게 수정해야 합니다.  
```
@design-front
'프론트엔드설계가이드'를 준용하여 프론트엔드설계서를 작성해 주세요.
[백엔드시스템]
- 마이크로서비스: user-service, location-service, trip-service, ai-service 
- API문서
  - user service: http://localhost:8081/v3/api-docs
  - location service: http://localhost:8082/v3/api-docs
  - trip service: http://localhost:8083/v3/api-docs
  - ai service: http://localhost:8084/v3/api-docs
[요구사항]
- 각 화면에 Back 아이콘 버튼과 화면 타이틀 표시
- 하단 네비게이션 바 아이콘화: 홈, 새여행, 주변장소검색, 여행보기
```

**3.설계서 검토후 수정 요청**       
설계서를 검토하고 수정 요청을 합니다.  

| [Top](#목차) |

---

### 프론트엔드 개발
[프론트엔드개발가이드](https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/develop/dev-frontend.md)를 이용하여 개발 합니다.   
아래와 같이 가이드에 있는것처럼 0~5단계까지는 AI가 수행하고 6단계 부터는 같이 각 화면별로 개발합니다.  
- '0. 준비'를 수행하고 완료 후 다음 단계 진행여부를 사용자에게 확인  
- '1. 기술스택 결정 ~ 5. 공통 컴포넌트 개발'까지 숳애하고 완료 후 다음 단계 진행여부를 사용자에게 확인   
- '6. 각 페이지별 구현'은 사용자와 함께 각 페이지를 개발  

**0.방화벽 오픈**      
백엔드서비스 접속을 위해 방화벽 오픈 작업을 합니다.   

- 오픈할 포트 찾기 
'npm run dev'를 수행했을 때 표시되는 포트를 확인합니다.   
보통 3000번 포트입니다.   

- [방화벽 오픈](https://github.com/cna-bootcamp/clauding-guide/tree/main?tab=readme-ov-file#azure-%EB%B0%A9%ED%99%94%EB%B2%BD-%EC%98%A4%ED%94%88) 참고하여 3000번 포트 오픈  
  
**1.기본개발 요청(0단계~5단계)**  
개발요청 프롬프트는 아래와 같습니다.  
'개발정보'는 본인 프로그램에 맞게 수정해야 합니다.    
```
@dev-front
"프론트엔드개발가이드"에 따라 개발해 주세요.   
[개발정보]
- 개발프레임워크: Typescript + React 18
- UI프레임워크: MUI v5
- 상태관리: Redux Toolkit
- 라우팅: React Router v6
- API통신: Axios
- 스타일링: MUI + styled-components
- 빌드도구: Vite
```

**2.각 페이지별 개발**   
각 페이지별 구현은 요청->테스트->수정->완성의 단계로 수행합니다.   
1)개발요청   
개발 요청시에는 유저스토리, 프로토타입, 관련 API테스트 명령을 제공합니다.   

요청 시 아래 내용은 동일한 컨텍스트 대화창에서는 한번만 제공하면됨   
단, 새로운 대화를 시작하거나 '/clear'명령으로 새로운 컨텍스트를 시작하면 다시 제공해야 함.  
```
제공한 유저스토리 이해. 
제공한 프로토타입을 웹브라우저로 실행하여 분석. 
제공한 API를 실행하여 요청과 응답 구조를 이해.
API 호출 시 백엔드 서비스별 클라이언트 객체 이용.   
```

예시)
```
대시보드 화면을 개발합시다.   
제공한 유저스토리 이해. 
제공한 프로토타입을 웹브라우저로 실행하여 분석. 
제공한 API를 실행하여 요청과 응답 구조를 이해.
API 호출 시 백엔드 서비스별 클라이언트 객체 이용. 

1. 유저스토리: UFR-TRIP-010
2. 프로토타입: 02-대시보드.html.  
3. API:  
1) 상태별 여행목록 구하기: 
tripStatus: planning, ongoing, completed
curl -X 'GET' \
  'http://localhost:8083/api/v1/trips?tripStatus=planning&sort=latest&page=1&size=3' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2YTAxOTBjYi1jZWIxLTQxYTMtODYwMy1mMGZmY2QzMWIxODEiLCJpYXQiOjE3NTY0OTIxMjYsImV4cCI6MTc1NjU3ODUyNiwidHlwZSI6ImFjY2VzcyIsInVzZXJuYW1lIjoiaGlvbmRhbCIsImF1dGhvcml0eSI6IlVTRVIifQ.v-c7A_GyxoB_6Xro4G0kY874XWFhNh5FYXLWIEv_Izg'
2) 사용자 기본정보 구하기
curl -X 'GET' \
  'http://localhost:8081/api/v1/users/profile' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJmZjA0NGNkYy04YTMxLTRkZWUtYmQ5Yi04YjNlMTdhYTcyNWQiLCJpYXQiOjE3NTY0Njk0NzksImV4cCI6MTc1NjU1NTg3OSwidHlwZSI6ImFjY2VzcyIsInVzZXJuYW1lIjoib25kYWwiLCJhdXRob3JpdHkiOiJVU0VSIn0.5MBzkDUUUmiYOouod3Pg66JGwuYoYGbgZ8zVxd2O1bA'
```

2)테스트/수정/완료    
개발된 페이지를 테스트하고 프롬프트로 수정 요청을 하여 완성해 나갑니다.   
터미널에서 아래 명령으로 개발서버를 시작합니다.  
```
npm run dev
```
브라우저에서 'http://localhost:3000'을 접속하여 테스트 합니다.   

Tip)3000번 포트로 실행 안되는 경우.  
아래 프롬프트로 기존 개발서버를 중단시킨후 다시 개발서버를 시작합니다.   
```
3000번 포트로 실행중인 개발서버를 중단하세요.  
```

3)유용한 팁    
요구사항을 잘 이해 못하거나 제대로 수정 못하는 경우 직접 웹브라우저를 열어 테스트하고 조치 요청합니다.    

예)  
```
직접 웹브라우저에서 열어 확인한 후 조치하세요.  
id: user01, pw: P@ssw0rd$
```

**3.Git 레포지토리 생성 및 푸시**   
Private 원격 레포지토리를 만들고 푸시 합니다.  

| [Top](#목차) |

---

### 컨테이너로 배포하기

#### 컨테이너 이미지 빌드 
컨테이너 이미지 빌드를 위해서는 Docker 데몬이 실행되어야 합니다.    
**Docker Desktop을 실행**해 주세요.   
Window는 'Docker Desktop'을 찾아 실행하고 Mac은 터미널에서 'open -a docker'명령을 실행하세요.   

**1.백엔드 컨테이너 이미지 빌드**        
**1)사전체크**         
1-1.Actuator설정     
각 서비스의 application.yml에 Actuator설정이 아래와 같이 되어 있어야 합니다.    
다른 설정이 추가된것은 괜찮지만 아래 항목은 반드시 있어야 합니다.  
```
# Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
      base-path: /actuator
  endpoint:
    health:
      show-details: always
      show-components: always
  health:
    livenessState:
      enabled: true
    readinessState:
      enabled: true
```

1-2.Actuator 라이브러리 추가 확인     
최상위 build.gradle에 아래 라이브러리가 있는지 확인   
```
// Actuator for health checks and monitoring
implementation 'org.springframework.boot:spring-boot-starter-actuator'
```

1-3.Actuator 경로 무인증 허용    
각 서비스의 SecurityConfig 클래스에 '.requestMatchers("/actuator/**").permitAll()'와 같이    
Actuator 경로를 인증없이 접근하도록 허용해야 합니다.  
```
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                    // Actuator endpoints
                    .requestMatchers("/actuator/**").permitAll()
                    // Swagger UI endpoints - context path와 상관없이 접근 가능하도록 설정
                    .requestMatchers("/swagger-ui/**", "/swagger-ui.html", "/v3/api-docs/**", "/swagger-resources/**", "/webjars/**").permitAll()
                    // Health check
                    .requestMatchers("/health").permitAll()
                    // All other requests require authentication
                    .anyRequest().authenticated()
            )
            .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider), 
                            UsernamePasswordAuthenticationFilter.class)
            .build();
}
```

**2)컨테이너 이미지 빌드**         
IntelliJ에서 백엔드 프로젝트를 오픈하고 Claude Code를 실행합니다.   
프롬프트에 아래 명령으로 이미지를 빌드합니다.   
수행결과는 deployment/container/build-image.md 파일로 생성됩니다.   

```
/deploy-build-image-back
```
아래 명령으로 생성된 이미지를 확인합니다.   
```
docker images 
```

**2.프론트엔드 컨테이너 이미지 빌드**        
vscode에서 프론트엔드 프로젝트를 오픈하고 Claude Code를 실행합니다.   
프롬프트에 아래 명령으로 이미지를 빌드합니다.   
수행결과는 deployment/container/build-image.md 파일로 생성됩니다.  
```
@cicd 
'프론트엔드컨테이너이미지작성가이드'에 따라 컨테이너 이미지를 작성해 주세요. 
```
아래 명령으로 생성된 이미지를 확인합니다.   
```
docker images 
```

| [Top](#목차) |

---

#### 컨테이너 실행 

**1.VM 생성 및 필요툴 설치**    
컨테이너 실행은 VM에서 수행합니다.  
아래 가이드대로 VM을 생성하고 필요한 툴을 설치하십시오.  

https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/04.setup-vm.md


**2.백엔드 컨테이너 실행 가이드 작성 및 실행**           
IntelliJ에서 백엔드 프로젝트를 오픈하고 Claude Code를 실행합니다.   

1)컨테이너 실행 가이드 작성 요청    
프롬프트에 아래 명령으로 컨테이너 실행 가이드를 작성 요청 합니다.   
수행결과는 deployment/container/run-container-guide.md 파일로 생성됩니다.   
'[실행정보]'에 정확한 값을 제공합니다.   

예시) 
```
/deploy-run-container-guide-back
[실행정보]
- ACR명: acrdigitalgarage01
- VM
  - KEY파일: ~/home/bastion-dg0500
  - USERID: azureuser
  - IP: 4.230.5.6
```
실행이 완료되면 'deployment/container/run-container-guide.md'파일을 열어 내용을 검토 및 수정합니다.    
특히 'localhost'로 찾아서 잘못된 부분이 있으면 수정합니다.    
그리고 프롬프트에 '푸시'라고 입력하여 원격 Git Repo에 푸시합니다.   
  
2)컨테이너 실행     
웹브라우저에서 실행가이드를 오픈하여 안내대로 아래 작업을 수행합니다.    
- VM 접속
- 어플리케이션 빌드 및 컨테이너 이미지 생성 
- 이미지를 ACR에 푸시할 수 있도록 이미지 태깅
- ACR로그인 및 이미지 푸시  
- 컨테이너 실행    

아래 명령으로 컨테이너가 실행되었는지 확인합니다.   
```
docker ps
```

**2.프론트엔드 컨테이너 실행 가이드 작성 및 실행**        
vscode에서 프론트엔드 프로젝트를 오픈하고 Claude Code를 실행합니다.   
프롬프트에 아래 명령으로 이미지를 빌드합니다.   
수행결과는 deployment/container/run-container-guide.md 파일로 생성됩니다.   
'[실행정보]'에 정확한 값을 제공합니다.   

예시) 
```
@cicd 
'프론트엔드컨테이너실행방법가이드'에 따라 컨테이너 실행 가이드를 작성해 주세요. 
[실행정보]
- 시스템명: tripgen
- ACR명: acrdigitalgarage01
- VM
  - KEY파일: ~/home/bastion-dg0500
  - USERID: azureuser
  - IP: 4.230.5.6
```
실행이 완료되면 'deployment/container/run-container-guide.md'파일을 열어 내용을 검토 및 수정합니다.    
특히 'localhost'로 찾아서 잘못된 부분이 있으면 수정합니다.    
그리고 프롬프트에 '푸시'라고 입력하여 원격 Git Repo에 푸시합니다.   
  
2)컨테이너 실행     
웹브라우저에서 실행가이드를 오픈하여 안내대로 아래 작업을 수행합니다.    
- VM 접속
- 컨테이너 이미지 생성
- 이미지를 ACR에 푸시할 수 있도록 이미지 태깅
- ACR로그인 및 이미지 푸시  
- 컨테이너 실행    

아래 명령으로 컨테이너가 실행되었는지 확인합니다.   
```
docker ps
```

| [Top](#목차) |

---

#### 컨테이너 명령어 실습  

아래 링크를 새 탭으로 열어 기타 Docker 명령어를 실습합니다.   
https://github.com/cna-bootcamp/clauding-guide/blob/main/references/docker-command.md


| [Top](#목차) |

---

### 쿠버네티스에 배포하기

#### ingress controller 추가
Ingress Controller는 Simple한 API Gateway입니다.   
  
쿠버네티스 설치 시 Ingress Controller가 기본으로 설치 안되기 때문에 먼저 그거부터 설치해야 합니다.  
Ingress Controller 중 가장 많이 사용하는 nginx ingress controller를 추가합니다.  

작업 디렉토리를 먼저 만듭니다.    
로컬 터미널에서 작업합니다.   
```
mkdir -p ~/install/ingress-controller && cd ~/install/ingress-controller 
```

helm으로 설치할 겁니다.   
따라서 helm repository 부터 추가해야겠죠?  
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update 
```

아래 내용으로 ingress-values.yaml 파일을 만듭니다.  
appProtocol 옵션을 비활성해야 제대로 생성이 됩니다.  
```
controller:
  replicaCount: 1
  service:
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
    loadBalancerIP: ""
    
    #해당 포트가 어떤 애플리케이션 프로토콜을 사용하는지 명시적으로 지정하는 옵션 비활성화
    #targetPort를 named port("http", "https")로 매핑하려고 시도해서 
    #Ingress Nginx Controller pod의 container port는 숫자(80, 443)로 정의되어 있어서 매핑이 실패 
    appProtocol: false  
    
  config:
    use-forwarded-headers: "true"
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi

```

ingress-nginx 네임 스페이스에 설치 합니다.    
```
helm upgrade -i ingress-nginx -f ingress-values.yaml \
-n ingress-nginx --create-namespace ingress-nginx/ingress-nginx 
```

제대로 생성되었는지 체크해 봅니다.   
```
k get svc -n ingress-nginx
k get po -n ingress-nginx
```

잠깐 ingress controller가 어떻게 외부의 요청을 내부로 연결할까요?  
ingress controller 파드는 준실시간으로 ingress object들의 설정을 읽어 내부의 nginx.conf파일에 업데이트 합니다.  
외부에서는 ingress-nginx-controller의 L/B IP로 접근합니다.  
이 트래픽 요청의 Host와 경로에 따라 적절한 서비스 오브젝트로 proxying합니다.    
결론적으로 외부의 트래픽을 내부로 전달하는 것은 인그레스 오브젝트가 아니라 인그레스 컨트롤러 파드드인것입니다.  
![](images/2025-09-03-21-15-51.png)
  
내친김에 ingress controller pod의 nginx.conf 내용도 볼까요? 
아직 ingress 오브젝트를 만들지 않았기 때문에 지금은 실습 못하지만,  
이 실습이 완료된 후에 한번 직접 확인해 보십시오.  
```
k get po -n ingress-nginx

k exec -it {ingress controller pod}  -n ingress-nginx -- bash
ingress-nginx-controller-5d9dcdb7b8-dx65z:/etc/nginx$ cat nginx.conf | more
```

스페이스를 눌러 내려가다 보면 아래 예와 같은 설정이 있는걸 확인할 수 있을겁니다.  
보시면 아시겠죠? ingress 오브젝트 'backend-ingress'의 설정이 그대로 반영되어 있습니다.   
```
## start server _
server {
    ...
    location ~* "^/recommend(/|$)(.*)" {

        set $namespace      "${ID}-lifesub-ns";
        set $ingress_name   "backend-ingress";
        set $service_name   "recommend";
        set $service_port   "80";
        set $location_path  "/recommend(/|${literal_dollar})(.*)";
        ...
 
        # Custom Response Headers
        rewrite "(?i)/recommend(/|$)(.*)" /$2 break;
        proxy_pass http://upstream_balancer;
    }
    ...
}
```

| [Top](#목차) |

---

#### 백엔드 배포   
IntelliJ에서 백엔드 프로젝트를 오픈하고 Claude Code를 실행합니다.   
아래 프롬프트 예제와 같이 백엔드 배포를 위한 매니페스트와 배포 가이드 작성을 요청합니다.   
'[실행정보]'에 정확한 값을 제공합니다.   
실행결과는 deployment/k8s 디렉토리 밑에 생성됩니다.   

```
/deploy-k8s-guide-back
[실행정보]
- ACR명: acrdigitalgarage01
- k8s명: aks-digitalgarage-01
- 네임스페이스: tripgen-dev
- 파드수: 1
- 리소스(CPU): 256m/1024m
- 리소스(메모리): 256Mi/1024Mi
```

만약 아래와 같이 '배포 전 필수 작업'을 안내하면 매니페스트에 정확한 값이 안들어간것입니다.   
![](images/2025-09-11-10-58-32.png)

이때는 아래와 같이 프롬프팅하여 매니페스트를 수정합니다.   
```
'배포 전 필수 작업'을 수행하여 yaml과 가이드를 업데이트 해요.
```

deployment/k8s/deploy-k8s-guide.md의 배포 가이드에 따라 쿠버네티스에 객체를 생성합니다.  

| [Top](#목차) |

---

#### 프론트엔드 배포   
vscode에서 프론트엔드 프로젝트를 오픈하고 Claude Code를 실행합니다.   
아래 프롬프트 예제와 같이 프론트엔드 배포를 위한 매니페스트와 배포 가이드 작성을 요청합니다.   
'[실행정보]'에 정확한 값을 제공합니다.   
Gateway Host는 아래 명령으로 백엔드 Ingress Host의 값을 읽어 지정합니다.   
```
kubectl get ing
```

실행결과는 deployment/k8s 디렉토리 밑에 생성됩니다.   

예시)   
```
@cicd 
'프론트엔드배포가이드'에 따라 프론트엔드 서비스 배포 방법을 작성해 주세요. 
[실행정보]
- 시스템명: tripgen
- ACR명: acrdigitalgarage01
- k8s명: aks-digitalgarage-01
- 네임스페이스: tripgen
- 파드수: 2
- 리소스(CPU): 256m/1024m
- 리소스(메모리): 256Mi/1024Mi
- Gateway Host: http://tripgen-api.20.214.196.128.nip.io
```

deployment/k8s/deploy-k8s-guide.md의 배포 가이드에 따라 쿠버네티스에 객체를 생성합니다.  

| [Top](#목차) |

---

#### 쿠버네티스 리소스 학습    

아래 링크를 새 탭으로 열어 쿠버네티스 리소스에 대해 학습합니다.   
https://github.com/cna-bootcamp/clauding-guide/blob/main/references/k8s-resources.md


| [Top](#목차) |

---

#### kubectl 명령어 실습    

아래 링크를 새 탭으로 열어 kubectl 명령어에 대해 실습합니다.   
https://github.com/cna-bootcamp/clauding-guide/blob/main/references/k8s-command.md


| [Top](#목차) |

---

### CI/CD

#### CI/CD 툴 설치: Jenkins, SonarQube, ArgoCD

https://github.com/cna-bootcamp/clauding-guide/blob/main/guides/setup/05.setup-cicd-tools.md

| [Top](#목차) |

---

#### Jenkins를 이용한 CI/CD
##### 백엔드 서비스 
작업 단계는 아래와 같습니다.    
https://github.com/cna-bootcamp/clauding-guide/blob/main/references/cicd-jenkins-backend-tasks.svg


**1.루트 build.gradle 수정**    
1)플러그인 'sonarqube'를 추가    
```
plugins {
  ...
  id "org.sonarqube" version "5.0.0.4638" apply false
}
```

2)플러그인 'jacoco' 추가    
jacoco는 소스 품질 검사 툴입니다.   
```
subprojects {
  ...

  apply plugin: 'org.sonarqube'
  apply plugin: 'jacoco' // 서브 프로젝트에 JaCoCo 플러그인 적용

  jacoco {
      toolVersion = "0.8.11" // JaCoCo 최신 버전 사용
  }

  ...
```

3)Test 설정    
기존에 'test'항목이 있으면 지우고 아래와 같이 변경합니다.     

```
subprojects {
  ...

  test {
      useJUnitPlatform()
      include '**/*Test.class'
      testLogging {
          events "passed", "skipped", "failed"
      }
      finalizedBy jacocoTestReport // 테스트 후 JaCoCo 리포트 생성
  }
  jacocoTestReport {
      dependsOn test
      reports {
          xml.required = true // SonarQube 분석을 위해 XML 형식 필요
          csv.required = false
          html.required = true
          html.outputLocation = layout.buildDirectory.dir("jacocoHtml").get().asFile
      }

      afterEvaluate {
          classDirectories.setFrom(files(classDirectories.files.collect {
              fileTree(dir: it, exclude: [
                      "**/config/**",        // 설정 클래스 제외
                      "**/entity/**",        // 엔티티 클래스 제외
                      "**/dto/**",           // DTO 클래스 제외
                      "**/*Application.class", // 메인 애플리케이션 클래스 제외
                      "**/exception/**"      // 예외 클래스 제외
              ])
          }))
      }
  }
}
```

**2.SonarQube 프로젝트 만들기**     
SonarQube에 로그인하여 수행합니다.  
1)각 서비스별 프로젝트 만들기    
{root project}-{서비스명}-{대상환경:dev/staging/prod}
아래 5개의 프로젝트를 만듭니다. 
- phonebill-user-service-dev 
- phonebill-bill-service-dev
- phonebill-product-service-dev
- phonebill-kos-mock-dev
- phonebill-api-gateway-dev
 
![](images/2025-09-11-19-07-13.png)  

branch명은 'main'으로 함.
![](images/2025-09-12-13-34-25.png) 

![](images/2025-09-11-19-08-46.png)

2)각 프로젝트에서 Quality Gate 수정    

![](images/2025-09-11-19-09-11.png)

![](images/2025-09-11-19-11-44.png)  


**3.Jenkins CI/CD 파일 작성**     
IntelliJ를 실행하고 Claude Code도 시작한 후 수행 하세요.   
아래와 같이 프롬프팅하여 Jenkins CI/CD파일들을 작성합니다.    
deployment/cicd 디렉토리 하위에 파일들이 생성됩니다.    

예시)  
```
/deploy-jenkins-cicd-guide-back

[실행정보]
- ACR_NAME: acrdigitalgarage01
- RESOURCE_GROUP: rg-digitalgarage-01
- AKS_CLUSTER: aks-digitalgarage-01
```

deployment/cicd 디렉토리 밑에 생성된 파일을 검토하고 수정합니다.   


**4.Git Push**     
Jenkins 파이프라인 구동 시 원격 Git Repo에서 소스와 CI/CD파일들을 내려 받아 수행합니다.   
따라서 로컬에서 수정하면 반드시 원격 Git Repo에 푸시해야 합니다.    
프롬프트창에 아래 명령을 내립니다.   
```
push 
```

**5.GitHub Credential 작성**        
Jenkins에서 Git에 접근할 수 있는 정보를 등록합니다.    
![](images/2025-09-12-14-53-13.png). 


**6.Jenkins 파이프라인 작성**        

1)'새로운 Item'을 클릭   
![](images/2025-09-12-13-56-01.png)

2)프로파일명 입력 후 Pipeline 카드 선택    
![](images/2025-09-12-13-57-33.png)

3)GitHub hook trigger for GITScm polling 체크    
GitHub Repository에 WebHook을 설정을 하여 소스 업로드 시 Jenkins에 파이프라인 구동을 요청할 수 있습니다.   
이를 위해 이 옵션을 체크해야 합니다.   

![](images/2025-09-12-13-58-37.png)

4)Pipeline 설정   
매개변수 지정:    
배포 대상 환경 'ENVIRONMENT'를 추가. 값은 dev, staging, prod 중 하나인데 실습시에는 'dev'로 지정합니다.    
소스품질검사 Skip여부 'SKIP_SONARQUBE'를 추가. 값은 true 또는 false로 지정.
![](images/2025-09-13-16-50-46.png) 
![](images/2025-09-13-16-53-22.png) 
![](images/2025-09-13-16-54-01.png) 

원격 Git 레포지토리 주소와 인증 Credential 지정   
![](images/2025-09-12-15-18-54.png)

브랜치를 'main'으로 하고 Jenkinsfile의 경로를 정확하게 입력합니다.   
![](images/2025-09-12-15-39-23.png)

**7.CI/CD 노드 증가**    
현재 CI/CD 관련 노드는 한개입니다.   
```
k get node | grep cicd
aks-cicd-33603374-vmss000002        Ready    <none>   130d   v1.30.10
```
Azure Portal에 로그인하여 노드를 한개 더 늘립니다.   

AKS 검색  
![](images/2025-09-12-16-58-32.png)

노드풀 클릭   
![](images/2025-09-12-16-59-20.png)

'cicd' 노드풀을 선택     
![](images/2025-09-12-16-59-47.png)

2개로 노드 증가   
![](images/2025-09-12-17-01-14.png)


**8.파이프라인 실행**    
1)기존 배포된 k8s객체 삭제     
intelliJ에서 터미널을 열고 아래 명령으로 모든 객체를 삭제합니다. 
'-R'옵션은 하위 모든 서브 디렉토리에서 매니페스트 파일을 찾는 옵션입니다.      
```
kubectl delete -f deployment/k8s -R
```

2)파이프라인 실행  
1)실행방법   
'지금빌드'를 클릭하여 실행합니다.  
![](images/2025-09-12-15-40-58.png)  

2)BlueOcean 사용법    
블루오션은 진행상황을 더 편하게 볼 수 있는 플러그인입니다.   
![](images/2025-09-12-15-43-28.png)  

![](images/2025-09-12-15-44-04.png)

- 좌측 상단 'Jenkins'로고 클릭: 파이프라인 목록 보기
- 파이파라인 이름 옆에 톱니바퀴: 파이프라인 설정으로 이동
- 우측 상단 'Administration' 클릭: Jenkins 관리로 이동

아래 예와 같이 각 단계 진행상황을 볼 수 있으며, 작업을 클릭하면 로그를 확인할 수 있습니다.   
![](images/2025-09-12-15-50-03.png)


3)트러블슈팅   
아래와 같이 파이프라인 실행 중 나오는 에러 메시지를 복사하여 Claude Code에 해결 요청을 합니다.   
```
파이프라인 실행 에러. 

FAILURE: Build failed with an exception.
* What went wrong:

Execution failed for task ':bill-service:sonar'.

> Could not resolve all files for configuration ':bill-service:testCompileClasspath'.

   > Could not find redis.embedded:embedded-redis:0.7.3.

     Required by:

         project :bill-service

```

로컬에서 수정 후 반드시 'push'명령으로 원격 Git 레포지토리에 푸시합니다.   
그리고 다시 파이프라인을 실행합니다.   

4)새로운 파이프라인 빠르게 시작하기     
파이프라인에서 에러가 나서 중단되었고 에러를 고쳐 새로 파이프라인을 시작했는데 한참동안 시작이 안될 경우가 있습니다.    
원인은 그전 에이젼트 파드가 없어지지 않아 리소스를 점유하고 있기 때문입니다.   
아래와 같이 에이젼트 파드를 찾아서 삭제 하세요.    
```
% k get po -n jenkins
NAME                       READY   STATUS    RESTARTS   AGE
12-kp6r4-wqw0z             0/4     Pending   0          3m28s
jenkins-69dc948556-tnpx7   1/1     Running   0          130d
```

```
k delete po 12-kp6r4-wqw0z -n jenkins --force --grace-period=0
```


| [Top](#목차) |

---

##### 프론트엔드 서비스  
작업 단계는 아래와 같습니다.    
https://github.com/cna-bootcamp/clauding-guide/blob/main/references/cicd-jenkins-frontend-tasks.svg

**1.사전작업**         
  
1)'.dockerignore' 파일 작성         
Frontend의 Pipeline 구동 시 성능을 높이기 위해 image 빌드 시   
image 내로 파일 복사할 때 제외할 파일이나 디렉토리를 정의합니다.   

아래 내용으로 .dockerignore 파일을 생성합니다.   
```
images
node_modules
npm-debug.log
build
.git
.github
coverage
.env*
.cache
dist
logs
**/*.log
**/.DS_Store
```
  
**2.SonarQube 프로젝트 만들기**     
SonarQube에 로그인하여 프론트엔드를 위한 프로젝트를 작성합니다.  
{서비스명}-{대상환경:dev/staging/prod}

아래 이름으로 작성합니다.  
- phonebill-front-dev 


**3.Jenkins CI/CD 파일 작성**     
vscode를 실행하고 프론트엔드 서비스를 오픈하세요.   
Claude Code도 시작한 후 수행 하세요.   
아래와 같이 프롬프팅하여 Jenkins CI/CD파일들을 작성합니다.    
deployment/cicd 디렉토리 하위에 파일들이 생성됩니다.    

예시)
```
@cicd 
'프론트엔드Jenkins파이프라인작성가이드'에 따라 Jenkins를 이용한 CI/CD 가이드를 작성해 주세요. 
[실행정보]
- SYSTEM_NAME: phonebill
- ACR_NAME: acrdigitalgarage01
- RESOURCE_GROUP: rg-digitalgarage-01
- AKS_CLUSTER: aks-digitalgarage-01 
```

deployment/cicd 디렉토리 밑에 생성된 파일을 검토하고 수정합니다.   

**4.Git Push**     
Jenkins 파이프라인 구동 시 원격 Git Repo에서 소스와 CI/CD파일들을 내려 받아 수행합니다.   
따라서 로컬에서 수정하면 반드시 원격 Git Repo에 푸시해야 합니다.    
프롬프트창에 아래 명령을 내립니다.   
```
push 
```

**5.Jenkins 파이프라인 작성**        
1)'새로운 Item'을 클릭   
2)프로파일명 '서비스명' 입력 후 Pipeline 카드 선택: 예) phonebill-front    
3)GitHub hook trigger for GITScm polling 체크    
4)Pipeline 설정    
- 매개변수 지정:    
  - 배포 대상 환경 'ENVIRONMENT'를 추가. 값은 dev, staging, prod 중 하나인데 실습시에는 'dev'로 지정합니다.    
  - 소스품질검사 Skip여부 'SKIP_SONARQUBE'를 추가. 값은 true 또는 false로 지정.

- Repository URL: 원격 Git Repo 주소
- Credentials: 원격 Git Repo 접속 위한 인증 Credential
- branch를 '*/main'으로 수정  
- Jenkinsfile 경로: deployment/cicd/Jenkinsfile     

**6.파이프라인 실행**    
1)기존 배포된 k8s객체 삭제     
vscode에서 터미널을 열고 아래 명령으로 모든 객체를 삭제합니다.      
```
kubectl delete -f deployment/k8s
```
2)파이프라인 실행  

3)트러블슈팅   
아래와 같이 파이프라인 실행 중 나오는 에러 메시지를 복사하여 Claude Code에 해결 요청을 합니다.   
```
파이프라인 실행 에러. 

{에러 메시지 붙여넣기}
```

로컬에서 수정 후 반드시 'push'명령으로 원격 Git 레포지토리에 푸시합니다.   
그리고 다시 파이프라인을 실행합니다.   

| [Top](#목차) |

---

##### WebhHook 설정 
Git push 시 자동으로 pipeline이 구동되게 하려면 아래와 같이 github repository에 webhook 설정을 합니다.   

1.Git 레포지토리의 Settings를 클릭    
2.좌측메뉴에서 WebHooks 클릭   
3.Webhook 정보 입력       
  - Payload URL: http://{Jenkins service의 External IP}/github-webhook/ 
    아래와 같이 구합니다. 아래 예에서는 '20.249.203.199'가 Jenkins의 External IP입니다.   
    ```
    k get svc -n jenkins
    NAME                     TYPE           CLUSTER-IP    EXTERNAL-IP
    jenkins                  LoadBalancer   10.0.106.33   20.249.203.199
    ``` 
    Payload URL 예: http://20.249.203.199/github-webhook/

    주의) Payload URL 마지막에 반드시 ‘/’를 붙여야 합니다.
  - Content-Type: application/json
  - SSL Verification: Disable
  
  ![](images/2025-09-13-19-52-29.png)

4.테스트   
  - 백엔드 프로젝트에서 아무 파일이나 수정한 후 푸시    
    ```
    git add . && git commit -m "test cicd" && git push 
    ``` 
  - 몇초 후 Jenkins 파이프라인이 구동되는것 확인    


| [Top](#목차) |

---

#### GitHub Actions를 이용한 CI/CD

##### 백엔드 서비스 
작업 단계는 아래와 같습니다.    

**0.사전작업**    
1)Jenkins로 배포한 객체 모두 삭제    
IntelliJ 터미널에서 아래 명령 수행   
```
k delete -f deployment/k8s -R 
```

2)WebHook 트리거 해제   
소스 업로드 시 Jenkins 파이프라인 구동되지 않도록 파이프라인 설정에서 해제   
파이프라인 메뉴에서 '구성'을 클릭하거나,   
![](images/2025-09-15-15-58-32.png)  

블루오션에서 '설정' 아이콘을 클릭하여 파이프라인 설정화면으로 이동합니다.   
![](images/2025-09-15-15-58-59.png)

'GitHub hook trigger for GITScm polling'을 uncheck합니다.    
![](images/2025-09-15-16-00-47.png)

**1.Repository Secrets 설정**      

GitHub Repository > Settings > Secrets and variables > Actions > Repository secrets에 다음 항목들을 등록하세요:   

![](images/2025-09-15-15-50-03.png)

1)Azure 인증 정보   
```json
AZURE_CREDENTIALS:
{
  "clientId": "5e4b5b41-7208-48b7-b821-d6d5acf50ecf",
  "clientSecret": "ldu8Q~GQEzFYU.dJX7_QsahR7n7C2xqkIM6hqbV8",
  "subscriptionId": "2513dd36-7978-48e3-9a7c-b221d4874f66",
  "tenantId": "4f0a3bfd-1156-4cce-8dc2-a049a13dba23"
}
```

2)ACR Credentials    
```bash
# ACR 자격 증명 확인 명령어   
az acr credential show --name acrdigitalgarage01
```
```
ACR_USERNAME: acrdigitalgarage01
ACR_PASSWORD: {ACR패스워드}
```

3)SonarQube 설정    
GitHub Actions 파이프라인에서 SonarQube를 접근하기 위한 정보를 등록합니다.   
```bash
# SonarQube URL 확인
kubectl get svc -n sonarqube

# SonarQube 토큰 생성 방법:
1. SonarQube 로그인 후 우측 상단 'Administrator' > My Account 클릭  
2. Security 탭 선택 후 토큰 생성  
```
```
SONAR_HOST_URL: http://{External IP}
SONAR_TOKEN: {SonarQube토큰}
```

4)Docker Hub 설정 (Rate Limit 해결)    
```
Docker Hub 패스워드 작성 방법
- DockerHub(https://hub.docker.com)에 로그인
- 우측 상단 프로필 아이콘 클릭 후 Account Settings를 선택
- 좌측메뉴에서 'Personal Access Tokens' 클릭하여 생성  
```

```
DOCKERHUB_USERNAME: {Docker Hub 사용자명}
DOCKERHUB_PASSWORD: {Docker Hub 패스워드}
```
  
**2.Repository Variables 설정**    

GitHub Repository > Settings > Secrets and variables > Actions > Variables > Repository variables에 등록:
![](images/2025-09-15-15-50-36.png)  

```
ENVIRONMENT: dev
SKIP_SONARQUBE: true
```

**3.GitHub Actions CI/CD 파일 작성**     
IntelliJ를 실행하고 Claude Code도 시작한 후 수행 하세요.   
아래와 같이 프롬프팅하여 GitHub Actions CI/CD파일들을 작성합니다.    
deployment/.github 디렉토리 하위에 파일들이 생성됩니다.    

예시)  
```
/deploy-actions-cicd-guide-back

[실행정보]
- ACR_NAME: acrdigitalgarage01
- RESOURCE_GROUP: rg-digitalgarage-01
- AKS_CLUSTER: aks-digitalgarage-01
```

deployment/.github 디렉토리 밑에 생성된 파일을 검토하고 수정합니다.   


**4.Git Push**     
GitHub Actions 파이프라인 구동 시 원격 Git Repo에서 소스와 CI/CD파일들을 내려 받아 수행합니다.   
따라서 로컬에서 수정하면 반드시 원격 Git Repo에 푸시해야 합니다.    
프롬프트창에 아래 명령을 내립니다.   
```
push 
```

**5.파이프라인 구동 확인**    
Actions 탭을 클릭하면 자동으로 파이프라인이 구동되는 것을 확인할 수 있습니다.   
![](images/2025-09-15-15-51-49.png)  

수행되고 있는 파이프라인을 클릭하면 Build -> Release -> Deploy별로 진행상태를 볼 수 있습니다.   
각 단계를 클릭하면 상세한 타스크 진행상태를 볼 수 있습니다.    
  
파이프라인 구동 시 에러가 발생하면 아래와 같이 에러메시지를 첨부하여 에러 해결을 요청합니다.   
예)
```
파이프라인 수행중 에러. 

Run # 환경별 디렉토리로 이동
error: accumulating resources: accumulation err='accumulating resources from '../../base': '/home/runner/work/phonebill/phonebill/.github/kustomize/base' must resolve to a file':
...
Error: Process completed with exit code 1.
```

| [Top](#목차) |

---

##### 프론트엔드 서비스  

**0.사전작업**    
1)Jenkins로 배포한 객체 모두 삭제    
vscode 터미널에서 아래 명령 수행   
```
k delete -f deployment/k8s
```

2)WebHook 트리거 해제   
소스 업로드 시 Jenkins 파이프라인 구동되지 않도록 파이프라인 설정에서 해제   
파이프라인 메뉴에서 '구성'을 클릭하거나, 블루오션에서 '설정' 아이콘을 클릭하여 파이프라인 설정화면으로 이동합니다.  

'GitHub hook trigger for GITScm polling'을 uncheck합니다. 

**1.Repository Secrets 설정**      

GitHub Repository > Settings > Secrets and variables > Actions > Repository secrets에 다음 항목들을 등록하세요:   

1)Azure 인증 정보   
```json
AZURE_CREDENTIALS:
{
  "clientId": "5e4b5b41-7208-48b7-b821-d6d5acf50ecf",
  "clientSecret": "ldu8Q~GQEzFYU.dJX7_QsahR7n7C2xqkIM6hqbV8",
  "subscriptionId": "2513dd36-7978-48e3-9a7c-b221d4874f66",
  "tenantId": "4f0a3bfd-1156-4cce-8dc2-a049a13dba23"
}
```

2)ACR Credentials    
```bash
# ACR 자격 증명 확인 명령어   
az acr credential show --name acrdigitalgarage01
```
```
ACR_USERNAME: acrdigitalgarage01
ACR_PASSWORD: {ACR패스워드}
```

3)SonarQube 설정    
GitHub Actions 파이프라인에서 SonarQube를 접근하기 위한 정보를 등록합니다.   
```bash
# SonarQube URL 확인
kubectl get svc -n sonarqube

# SonarQube 토큰 생성 방법:
1. SonarQube 로그인 후 우측 상단 'Administrator' > My Account 클릭  
2. Security 탭 선택 후 토큰 생성  
```
```
SONAR_HOST_URL: http://{External IP}
SONAR_TOKEN: {SonarQube토큰}
```

4)Docker Hub 설정 (Rate Limit 해결)    
```
Docker Hub 패스워드 작성 방법
- DockerHub(https://hub.docker.com)에 로그인
- 우측 상단 프로필 아이콘 클릭 후 Account Settings를 선택
- 좌측메뉴에서 'Personal Access Tokens' 클릭하여 생성  
```

```
DOCKERHUB_USERNAME: {Docker Hub 사용자명}
DOCKERHUB_PASSWORD: {Docker Hub 패스워드}
```
  
**2.Repository Variables 설정**    

GitHub Repository > Settings > Secrets and variables > Actions > Variables > Repository variables에 등록:  

```
ENVIRONMENT: dev
SKIP_SONARQUBE: true
```

**3.GitHub Actions CI/CD 파일 작성**     
vscode를 실행하고 Claude Code도 시작한 후 수행 하세요.   
아래와 같이 프롬프팅하여 GitHub Actions CI/CD파일들을 작성합니다.  
[실행정보]는 본인 프로젝트에 맞게 수정하여야 합니다.     
deployment/.github 디렉토리 하위에 파일들이 생성됩니다.    

예시)  
```
@cicd 
'프론트엔드GitHubActions파이프라인작성가이드'에 따라 GitHub Actions를 이용한 CI/CD 가이드를 작성해 주세요.   
[실행정보]
- SYSTEM_NAME: phonebill
- ACR_NAME: acrdigitalgarage01
- RESOURCE_GROUP: rg-digitalgarage-01
- AKS_CLUSTER: aks-digitalgarage-01 
```

deployment/.github 디렉토리 밑에 생성된 파일을 검토하고 수정합니다.   


**4.Git Push**     
GitHub Actions 파이프라인 구동 시 원격 Git Repo에서 소스와 CI/CD파일들을 내려 받아 수행합니다.   
따라서 로컬에서 수정하면 반드시 원격 Git Repo에 푸시해야 합니다.    
프롬프트창에 아래 명령을 내립니다.   
```
push 
```

**5.파이프라인 구동 확인**    
Actions 탭을 클릭하면 자동으로 파이프라인이 구동되는 것을 확인할 수 있습니다.   

수행되고 있는 파이프라인을 클릭하면 Build -> Release -> Deploy별로 진행상태를 볼 수 있습니다.   
각 단계를 클릭하면 상세한 타스크 진행상태를 볼 수 있습니다.    
![](images/2025-09-15-16-51-05.png)  
  
파이프라인 구동 시 에러가 발생하면 아래와 같이 에러메시지를 첨부하여 에러 해결을 요청합니다.   
예)
```
파이프라인 수행중 에러. 

Run # 환경별 디렉토리로 이동
error: accumulating resources: accumulation err='accumulating resources from '../../base': '/home/runner/work/phonebill/phonebill/.github/kustomize/base' must resolve to a file':
...
Error: Process completed with exit code 1.
```

| [Top](#목차) |

---

#### ArgoCD를 이용한 CI와 CD 분리  

작업 단계는 아래와 같습니다.    

**0.사전작업**    
1)Jenkins로 배포한 객체 모두 삭제    
IntelliJ 터미널에서 아래 명령 수행   
```
k delete -f deployment/k8s -R 
```
2)GitHub Actions workflow 수정   
기존 Workflow가 소스 푸시 시 동작하지 않도록 Disable함   
Actions탭 클릭 -> 기존 Workflow 클릭 -> 우측 메뉴에서 'Disable Workflow' 선택  

![](images/2025-09-15-20-19-28.png)

백엔드 레포지토리와 프론트엔드 레포지토리에서 모두 수행함.   

3)백엔드와 프론트엔드 레포지토리에 Secret 변수 등록    
GitHub Repository > Settings > Secrets and variables > Actions > Repository secrets에 다음 항목들을 등록하세요.        
매니페스트 레포지토리에 접근할 수 있는 인증정보를 등록.   
```
GIT_USERNAME
GIT_PASSWORD
```

**1.manifest 레포지토리 생성**    
1)원격 레포지토리 생성   
GitHub에 원격 레포티지토리를 생성합니다.   
{SYSTEM_NAME}-manifest 형식으로 작성합니다.    
예) phonebill-manifest

2)로컬 레포지토리 생성  
Window는 Window Terminal의 GitBash 터미널을 열고 Mac은 기본 터미널을 열어 작업합니다.    

```
cd ~/home/workspace
mkdir {SYSTEM_NAME}-manifest
cd {SYSTEM_NAME}-manifest
git init
git checkout -b main
git remote add origin {원격 Git Repository 주소} 
```

예) SYSTEM_NAME이 phonebill인 경우   
```
cd ~/home/workspace
mkdir phonebill-manifest
cd phonebill-manifest
git init
git checkout -b main
git remote add origin https://github.com/cna-bootcamp/phonebill-manifest 
```
  
**2.CLAUDE.md 작성**       
vscode에서 로컬 레포지토리를 오픈합니다.    
```
code . 
```

아래 내용으로 CLAUDE.md 파일을 만듭니다.   
```
# ArgoCD 가이드

[Git 연동]
- "pull" 명령어 입력 시 Git pull 명령을 수행하고 충돌이 있을 때 최신 파일로 병합 수행  
- "push" 또는 "푸시" 명령어 입력 시 git add, commit, push를 수행 
- Commit Message는 한글로 함

[URL링크 참조]
- URL링크는 WebFetch가 아닌 'curl {URL} > claude/{filename}'명령으로 저장
- 동일한 파일이 있으면 덮어 씀 
- 'claude'디렉토리가 없으면 생성하고 다운로드   
- 저장된 파일을 읽어 사용함

## 가이드 
- ArgoCD파이프라인준비가이드
  - 설명: 프론트엔드/백엔드 서비스를 ArgoCD를 이용하여 CI와 CD를 분리하는 가이드  
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/deploy/deploy-argocd-cicd.md
  - 파일명: deploy-argocd-cicd.md 

### 작업 약어 
- "@complex-flag": --seq --c7 --uc --wave-mode auto --wave-strategy systematic --delegate auto

- "@plan": --plan --think
- "@cicd": /sc:implement @devops --think @complex-flag
- "@document": /sc:document --think @scribe @complex-flag
- "@fix": /sc:troubleshoot --think @complex-flag
- "@estimate": /sc:estimate --think-hard @complex-flag
- "@improve": /sc:improve --think @complex-flag
- "@analyze": /sc:analyze --think --seq 
- "@explain": /sc:explain --think --seq --answer-only 
```

**3.매니페스트 구성 및 파이프라인 작성**     
vscode에서 Claude Code를 수행합니다.   
YOLO모드로 전환.   
```
claude-yolo
```
Claude Code 수행: View > Command Palette 수행하고 'Run Claude Code'로 실행    

아래 예시와 같이 프롬프팅 합니다.      
'[실행정보]'는 본인 프로젝트에 맞게 수정해야 합니다.   

예시) 
```
@cicd
'ArgoCD파이프라인준비가이드'에 따라 CI와 CD분리 준비 작업을 해주세요.   
[실행정보]
- SYSTEM_NAME: phonebill
- FRONTEND_SERVICE: phonebill-front
- ACR_NAME: acrdigitalgarage01
- RESOURCE_GROUP: rg-digitalgarage-01
- AKS_CLUSTER: aks-digitalgarage-01
- MANIFEST_REG: https://github.com/cna-bootcamp/phonebill-manifest.git
- JENKINS_GIT_CREDENTIALS: github-credentials-dg0500
- MANIFEST_SECRET_GIT_USERNAME: GIT_USERNAME
- MANIFEST_SECRET_GIT_PASSWORD: GIT_PASSWORD
```

수행결과 확인:  
- 매니페스트 레포지토리에 매니페스트 파일 생성     
- 백엔드/프론트엔드 Jenkins 파이프라인 스크립트 생성: deployment/cicd/Jenkinsfile_ArgoCD 
- 백엔드/프론트엔드 GitHub Actions Workflow 파일 생성: 
  - .github/workflows/backend-cicd_ArgoCD.yaml
  - .github/workflows/frontend-cicd_ArgoCD.yaml

**4.원격 레포지토리에 푸시**        
매니페스트 레포지토리 푸시: vscode의 Claude Code 창에서 'push'입력   

**5.기존 k8s객체 삭제**       
vscode GitBash 터미널을 추가하고 아래 명령을 수행합니다.    
1)백엔드 객체 삭제   
```
k delete ../phonebill/deployment/k8s -R
```

2)프론트엔드 객체 삭제
```
k delete ../phonebill-front/deployment/k8s
```
  
**6.ArgoCD 설정**    
ArgoCD에서는 아래와 같은 작업을 합니다.   
- Project 등록: ArgoCD의 애플리케이션들을 논리적으로 그룹핑한 개념. 매니페스트 레포지토리, 배포 대상 환경을 관리      
- 레포지토리 등록: 매니페스트 레포지토리 정보와 인증정보 등록   
- Application 등록: 백엔드와 프론트엔드별로 Project, 매니페스트 레포지토리와 배포 환경과의 동기화 옵션 등을 등록  

1)Project 등록   
- Settings > Projects를 클릭.  
  ![](images/2025-09-15-23-12-59.png)    
- 'NEW PROJECT' 버튼 클릭   
- 프로젝트명과 설명 입력 
  ![](images/2025-09-15-23-14-35.png)  
- SOURCE REPOSITORIES 등록: 매니페스트 레포지토리 등록      
  'EDIT'버튼 클릭 > ADD SOURCE 클릭 > 매니페스트 레포지토리의 주소를 입력하고 'SAVE'버튼을 클릭하여 저장    
  ![](images/2025-09-15-23-15-36.png)     
- DESTINATIONS 등록: 배포 환경 정보 등록  
  'EDIT'버튼 클릭 > ADD DESTINATION 클릭 > 쿠버네티스 정보를 그림과 같이 입력하고 'SAVE'버튼을 클릭하여 저장  
  ![](images/2025-09-15-23-17-54.png)   
  
2)레포지토리 등록
- Settings > Repositories 클릭   
  ![](images/2025-09-15-23-21-17.png)
- 'CONNECT REPO' 클릭  
- 레포지토리 정보 등록   
  ![](images/2025-09-15-23-23-47.png)       
  - Choose your connection method: HTTPS
  - Type: git
  - Name: 적절히 입력. 보통 레포지토리명과 동일하게 함
  - Repository URL: 매니페스트 레포지토리의 주소 
  - Username: 매니페스트 레포지토리 접근할 수 있는 유저ID
  - Password: Git Access Token (로그인 암호가 아님)
- 상단의 'CONNECT'를 눌러 저장한 후 연결상태가 'SUCCESSFUL'로 나와야 함  
  ![](images/2025-09-15-23-27-00.png)     

3)백엔드 Application 등록 
- Applications > NEW APP 클릭 
  ![](images/2025-09-15-23-29-01.png)  
- GENERAL 정보 등록 
  ![](images/2025-09-15-23-31-19.png) 
  - SYNC POLICY: 매니페스트 레포지토리와 현재 배포된 객체간 동기화 옵션
    - Prune Resources: 매니페스트 레포지토리에 정의 되지 않은 객체 삭제  
    - SELF HEALS: 매니페스트 레포지토리에 정의된대로 현재 배포된 객체를 동기화 
  - 나머지 옵션은 체크하지 않음
- SOURCE 정보 등록
  ![](images/2025-09-15-23-35-29.png)  
  Path에 동기화할 Kustomize 디렉토리를 입력   
- DESTINATION 정보 등록  
  ![](images/2025-09-15-23-37-21.png)
- Kustomize 섹션: 디폴트값 그대로 정의  

4)프론트엔드 Application 등록   
백엔드 Application 등록 참조하여 등록합니다.   

5)확인   
아래와 같이 Status가 Healthy + Synched로 나와야 합니다.   
![](images/2025-09-16-00-33-57.png)  

터미널에서 확인해 보면 매니페스트에 정의된대로 k8s객체가 생성되는 것을 확인할 수 있습니다.   
```
kubectl get po 
```

Application을 선택하고 우측 상단의 'Application Details Network'에서 3번째 아이콘을 눌러보세요.   
아래와 같이 k8s객체의 상태가 이쁘게 나옵니다.   
![](images/2025-09-16-00-38-26.png)

**7.Jenkins CI/CD 분리 테스트**           
1)백엔드 테스트    
백엔드 Jenkins 파이프라인 설정에서 Script Path를 수정합니다.    
![](images/2025-09-16-00-42-31.png)

파이프라인을 수동으로 실행하고 완료될때까지 기다립니다.       
약 3분 후 ArgoCD에서 Pod의 이미지 Tag가 변경되는것을 확인합니다.

Pod를 클릭합니다.  
![](images/2025-09-16-02-40-42.png)

image명이 변경된것을 확인합니다.  
![](images/2025-09-16-02-40-20.png)  

2)프론트엔드 테스트    
프론트엔드 Jenkins 파이프라인 설정에서 Script Path를 수정합니다.    
deployment/cicd/Jenkinsfile_ArgoCD로 수정하면 됩니다.   
파이프라인을 수동으로 실행하고 완료될때까지 기다립니다.    

약 3분 후 ArgoCD에서 Pod의 이미지 Tag가 변경되는것을 확인합니다.  

**8.GitHub Actions CI/CD 분리 테스트**          
각 로컬 레포지토리의 파일을 원격 레포지토리에 푸시 합니다.    
1)백엔드: IntelliJ의 Claude Code 창에서 'push'입력   
2)프론트엔드: vscode의 Claude Code 창에서 'push'입력   

원격 레포지토리의 Action탭에서 Workflow가 실행되는것을 확인합니다.   
Workflow 완료 후 약 3분 후 ArgoCD에서 Pod의 이미지 Tag가 변경되는것을 확인합니다.  

| [Top](#목차) |

---

## 맺음말 

![](images/2025-09-16-02-58-43.png)

🎉 여정의 완주, 그리고 새로운 시작을 축하합니다! 🎉
여러분은 서비스 기획의 첫 아이디어부터 실제 운영 가능한 시스템의 CI/CD까지, 클라우드 네이티브 어플리케이션 개발의 전체 생명주기를 완료하였습니다.  
✨ 막막한 아이디어를 구체적인 기획으로 다듬었고
✨ 복잡한 아키텍처를 설계하며 전체를 조망하는 시야를 길렀고
✨ 클라우드의 무한한 가능성을 직접 구현해보았고
✨ 컨테이너와 쿠버네티스라는 현대적 배포의 정수를 익혔고
✨ CI/CD를 통해 진정한 DevOps 철학을 체험했습니다

무엇보다 Claude와 함께 하며 AI 시대의 협업 방식을 몸소 경험한 여러분은 이미 미래의 개발자입니다.
이 과정에서 마주한 수많은 오류 메시지, 설정 파일과의 씨름, 디버깅의 밤들...   
그 모든 것이 여러분을 더 강하고 지혜로운 개발자로 만들었습니다.

이제 시작입니다.
여러분의 손끝에는 아이디어를 현실로 만들 수 있는 완전한 도구상자가 있습니다.   
세상의 어떤 문제든, 어떤 서비스든 여러분이 직접 기획하고, 설계하고, 구현하고, 세상에 선보일 수 있습니다.
앞으로 여러분이 만들어갈 서비스들이 세상을 조금 더 나은 곳으로 만들기를, 그리고 이 여정에서 얻은 경험과 자신감이 평생의 자산이 되기를 진심으로 응원합니다.


