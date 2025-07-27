# 내부시퀀스설계 가이드 

[요청사항]
- **서브 에이전트를 활용한 병렬 작성 필수**
- 마이크로서비스의 모든 API를 표시할 것 
- 마이크로서비스 내부의 처리 흐름을 표시 
- **각 서비스-시나리오별로 분리하여 각각 작성**
- 각 서비스별 주요 시나리오마다 독립적인 시퀀스 설계 수행
- 서비스별 독립적인 에이전트가 각 시나리오를 동시에 작업
- **PlantUML 스크립트 파일 생성 즉시 검사 실행**: 'PlantUML 문법 검사  가이드' 준용 

[참고자료]
- 유저스토리
- UI/UX설계서
- 논리아키텍처
- API설계서
- 외부시퀀스설계서

[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_시퀀스설계서(내부).puml

[결과파일]
- design/backend/sequence/inner/{서비스명}-{시나리오}.puml
- 서비스명은 영어로 시나리오명은 한글로 작성  

[시나리오 분류 가이드]

### 시나리오 식별 방법
1. **유저스토리 기반**: 각 유저스토리(RQ-XX-000)를 기준으로 시나리오 도출
2. **API 그룹핑**: 관련된 API 엔드포인트들을 하나의 시나리오로 묶음
3. **비즈니스 기능 단위**: 하나의 완전한 비즈니스 기능을 수행하는 단위로 분류

### 시나리오 명명 규칙
- **케밥-케이스 사용**: entity-action 형태 (예: user-registration, order-processing)
- **동사형 액션**: 실제 수행하는 작업을 명확히 표현
- **일관된 용어**: 프로젝트 내에서 동일한 용어 사용

### 일반적인 시나리오 패턴

#### 데이터 관리 서비스
- **entity-management**: 엔티티 CRUD 작업 (생성/조회/수정/삭제)
- **entity-validation**: 데이터 검증 및 무결성 체크
- **entity-search**: 검색 및 필터링 기능

#### 비즈니스 로직 서비스
- **process-execution**: 핵심 비즈니스 프로세스 실행
- **calculation-processing**: 계산 및 분석 작업
- **notification-handling**: 알림 및 이벤트 처리

#### 외부 연동 서비스
- **external-integration**: 외부 API 연동
- **realtime-sync**: 실시간 데이터 동기화
- **batch-processing**: 배치 작업 처리

[작성 방법]

### 시나리오별 설계 원칙
1. **단일 책임**: 하나의 시나리오는 하나의 명확한 비즈니스 목적을 가짐
2. **완전성**: 해당 시나리오의 모든 API와 내부 처리를 포함
3. **독립성**: 각 시나리오는 독립적으로 이해 가능해야 함
4. **일관성**: 동일한 아키텍처 레이어 표현 방식 사용

### 표현 요소
- **API 레이어**: 해당 시나리오의 모든 관련 엔드포인트
- **비즈니스 레이어**: Controller → Service → Domain 내부 플로우
- **데이터 레이어**: Repository, Cache, External API 접근
- **인프라 레이어**: 메시지 큐, 이벤트, 로깅 등

### 다이어그램 구성
- **참여자(Actor)**: Controller, Service, Repository, Cache, External API
- **생명선(Lifeline)**: 각 참여자의 활동 구간
- **메시지(Message)**: 동기(→)/비동기(-->) 호출 구분
- **활성화 박스**: 처리 중인 시간 구간 표시
- **노트**: 중요한 비즈니스 로직이나 기술적 고려사항 설명