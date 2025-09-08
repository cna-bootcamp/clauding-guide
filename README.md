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
/design-logical
```

| [Top](#목차) |

---

#### 3.외부 시퀀스 설계  
각 서비스 사이, 서비스와 외부시스템 사이의 인터페이스를 외부 시퀀스로 설계합니다.   
결과는 '/design/backend/outer' 디렉토리에 생성됩니다.  
```
/design-seq-outer
```

| [Top](#목차) |

---

#### 4.내부 시퀀스 설계
각 서비스 내부의 처리 흐름을 내부 시퀀스로 설계합니다.   
결과는 '/design/backend/inner' 디렉토리에 생성됩니다.   
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
/design-api
```

설계서 리뷰와 수정이 끝나면 시퀀스설계서와의 일관성 검사를 요청합니다.  
```
@analyze as @archi @back @front --think 외부시퀀스설계서와 내부시퀀스설계서의 설계 결과와 일관성 검사를 해주세요.
```

| [Top](#목차) |

---

#### 6.클래스 설계
각 서비스의 클래스 설계를 합니다.
아래 예제와 같이 설계를 위한 정보를 프롬프트에 제공합니다. 
결과는 'design/backend/class' 디렉토리에 생성됩니다.   
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
/design-data
```

| [Top](#목차) |

---

#### 8.High Level 아키텍처 정의서 작성
지금까지 설계를 바탕으로 상위 수준의 종합적인 아키텍처 정의서를 작성합니다.    
'CLOUD' 항목에 사용할 클라우드플랫폼 제공자를 Azure, AWS, Google과 같이 입력합니다.   
결과는 'design/high-level-architecture.md'에 생성됩니다.   
예시)
```
/design-physical
- CLOUD: Azure
```

| [Top](#목차) |

---

#### 9.물리 아키텍처 설계
클라우드 플랫폼에 배포하기 위한 물리 아키텍처를 설계합니다.   
'CLOUD' 항목에 사용할 클라우드플랫폼 제공자를 Azure, AWS, Google과 같이 입력합니다.   
결과는 'design/backend/physical' 디렉토리에 생성됩니다.    
물리 아키텍처는 개발환경과 운영환경으로 나누어 설계됩니다. 

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
/develop-db-guide
```
2)데이터베이스 설치 수행    
데이터베이스를 계획서에 따라 설치합니다.   
'[설치정보]' 섹션에 설치정보를 제공해줘야 합니다.   
설치결과 레포트가 'develop/database/exec' 디렉토리에 생성됩니다.   

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
/develop-db-remove
```

**2.MQ 설치**    
1)설치계획서 작성    
Message Queue 설치계획서 작성을 요청합니다.    
결과는 'develop/mq/mq-plan-{대상환경}.md' 파일로 생성됩니다.   

```
/develop-mq-guide
```

2)MQ설치    
Message Queue 설치를 요청합니다.   
'[설치정보]' 섹션에 설치정보를 제공해줘야 합니다.   
결과는 'develop/mq/mq-exec-{대상환경}.md' 파일로 생성됩니다.   

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
/develop-mq-remove
```


| [Top](#목차) |

---

#### 백엔드 개발/테스트
 
**1.초안개발**        
설계 결과를 참조하여 모든 백엔드서비스를 개발 요청합니다.    
간단한 기능은 제대로 개발하나 복잡한 기능은 TODO로 남겨놓는 경우도 많습니다.  
```
/develop-dev-backend
```

개발가이드에따라 컴파일까지는 수행하고 오류가 있으면 해결할 겁니다.   
AI가 서버를 실행하려고 하면 ESC를 눌러 중단시키십시오.    

**2.실행 프로파일 작성**    
서비스를 실행하기 위한 실행 프로파일을 작성 요청합니다.    
각 서비스에 생성된 application.yml을 분석하여 환경변수까지 등록된 IntelliJ의 서비스 실행 프로파일이 작성됩니다.       
결과는 {service}/.run/{service}.run.xml로 생성됩니다.    

```
/develop-make-run-profile
```

등록이 되면 서비스탭에 나타납니다.    
![](images/2025-08-07-09-23-54.png)  
먼저 실행구성을 클릭하고 'Gradle'이나 'Maven' 등 빌드툴을 선택해야 표시됩니다.   
![](images/2025-08-07-09-24-30.png)    

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
에러가 나면 AI에게 로그를 분석하여 에러를 해결하도록 요청합니다.    

예제)  
```
user-service 실행 시 에러가 발생합니다.   
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
로그인API는 사용자 등록이 먼저 되어야 하므로 사용자 등록을 요청합니다.    
다른 API는 이 단계는 불필요합니다.   
```
user-service를 위한 db pod를 찾아 아래 사용자를 등록해 주세요.  
- id: trip01
- name: 트립01
- pw: P@ssw0rd$
```

1)Swagger페이지 접속 및 설정   
'http://localhost:{서비스별 포트}/swagger-ui.html'으로 접속합니다.   
로그인 API를 수행합니다.   
![](images/2025-09-01-17-57-51.png)   


2)에러 발생 시 API명령을 제공하여 에러 수정 요청   

![](images/2025-09-01-17-58-20.png)  

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
- 'claude'디렉토리가 없으면 생성하고 다운로드   
- 저장된 파일을 읽어 사용함

## 산출물 디렉토리 
- 유저스토리: design/userstory.md
- 프로토타입: design/prototype/*
- API명세서: design/api/*.json
- UI/UX설계서: design/frontend/uiux-design.md
- 스타일가이드: design/frontend/style-guide.md
- 정보아키텍처: design/frontend/ia.md
- API매핑설계서: design/frontend/api-mapping.md

## 가이드 
- 프론트엔드설계가이드
  - 설명: 프론트엔드 설계 방법 안내 
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/design/frontend-design.md
  - 파일명: frontend-design.md
- 프론트엔드개발가이드
  - 설명: 프론트엔드 개발 가이드 
  - URL: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/develop/dev-frontend.md
  - 파일명: dev-frontend.md   

## 작업약어
- "@design-front": /sc:design --persona-front --think --seq --c7 --uc --wave-mode auto --wave-strategy systematic --delegate auto
- "@dev-front": /sc:implement --persona-front --think --seq --c7 --uc --wave-mode auto --wave-strategy systematic --delegate auto
- "@plan": --plan --think

## Lessons Learned
**프론트엔드 개발 절차**:
- 개발가이드의 "6. 각 페이지별 구현" 단계에서는 빌드 및 에러 해결까지만 수행
- 개발서버(`npm run dev`) 실행은 항상 사용자가 직접 수행
- 개발자는 빌드(`npm run build`) 성공까지만 확인하고 서버 실행을 사용자에게 요청
- 개발자가 임의로 서버를 실행하고 테스트하지 않고 사용자 확인 후 진행

**프로토타입 분석 및 테스트**:
- 프로토타입 HTML 파일은 반드시 Playwright MCP를 사용하여 모바일 화면(375x812)에서 확인
- 프로토타입의 모든 인터랙션과 액션을 실제로 클릭하여 동작 확인 필요
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
예시)
```
대시보드 화면을 개발합시다.   
1. 유저스토리: UFR-TRIP-010
2. 프로토타입: 02-대시보드.html. '프로토타입 분석 및 테스트'대로 분석 
3. API: 제공한 API 실행 명령을 이용하여 요청/응답 데이터 구조를 분석하여 API 연동 개발 
4) 상태별 여행목록 구하기: 
tripStatus: planning, ongoing, completed
curl -X 'GET' \
  'http://localhost:8083/api/v1/trips?tripStatus=planning&sort=latest&page=1&size=3' \
  -H 'accept: */*' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2YTAxOTBjYi1jZWIxLTQxYTMtODYwMy1mMGZmY2QzMWIxODEiLCJpYXQiOjE3NTY0OTIxMjYsImV4cCI6MTc1NjU3ODUyNiwidHlwZSI6ImFjY2VzcyIsInVzZXJuYW1lIjoiaGlvbmRhbCIsImF1dGhvcml0eSI6IlVTRVIifQ.v-c7A_GyxoB_6Xro4G0kY874XWFhNh5FYXLWIEv_Izg'
1) 사용자 기본정보 구하기
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

| [Top](#목차) |

---

### 컨테이너로 배포하기

#### 컨테이너 이미지 빌드 
**1.백엔드 컨테이너 이미지 빌드**        
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
/deploy-build-image-front
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
실행이 완료되면 프롬프트에 '푸시'라고 입력하여 원격 Git Repo에 푸시합니다.   
  
2)컨테이너 실행     
웹브라우저에서 실행가이드를 오픈하여 안내대로 아래 작업을 수행합니다.    
- 이미지를 ACR에 푸시할 수 있도록 이미지 태깅
- ACR로그인 및 이미지 푸시  
- VM 접속
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
/deploy-run-container-guide-front
[실행정보]
- 시스템명: tripgen
- ACR명: acrdigitalgarage01
- VM
  - KEY파일: ~/home/bastion-dg0500
  - USERID: azureuser
  - IP: 4.230.5.6
```
실행이 완료되면 프롬프트에 '푸시'라고 입력하여 원격 Git Repo에 푸시합니다.   
  
2)컨테이너 실행     
웹브라우저에서 실행가이드를 오픈하여 안내대로 아래 작업을 수행합니다.    
- 이미지를 ACR에 푸시할 수 있도록 이미지 태깅
- ACR로그인 및 이미지 푸시  
- VM 접속
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

```
/deploy-k8s-guide-front
[실행정보]
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
