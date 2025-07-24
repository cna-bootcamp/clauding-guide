# 아키텍처 설계 가이드

## 논리 아키텍처 설계 가이드

[요청사항]
- 참고자료를 기준으로 작성 
- 사용자 관점의 컴포넌트 다이어그램 작성
- Context Map 스타일로 서비스 내부 구조는 생략하고 서비스 간 관계에 집중
- 사용자 Flow를 note로 정리하고 처리순서별 번호 부여
- 클라이언트에서 API Gateway로는 단일 연결선으로 표현
- 서비스별 색상 구분으로 시각적 명확성 확보
- 서비스 간 의존성을 명확히 표현 (동기/비동기, 필수/선택적)
- **PlantUML 스크립트 파일 생성 즉시 검사 실행**: 'PlantUML 문법 검사  가이드' 준용 
[의존성 표현 방법]
- 실선 화살표(→): 동기적 의존성 (필수)
- 비동기 화살표(->>): 비동기 의존성 (fire-and-forget)
- 점선 화살표(-->): 선택적 의존성 또는 느슨한 결합
- 양방향 화살표(↔): 상호 의존성
- 의존성 레이블에 목적 명시 (예: "멤버 정보 조회")

[통신 전략]
- **동기 통신**: 즉시 응답이 필요한 단순 조회
- **캐시 우선**: 자주 사용되는 데이터는 캐시에서 직접 읽기
- **비동기 처리**: 외부 API 다중 호출 등 장시간 작업

[참고자료]
- 유저스토리: design/Userstory.md
- 화면설계: design/wireframe 폴더의 화면설계 
- 아키텍처패턴: design/pattern/아키텍처패턴.puml

[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_논리아키텍처.puml

[결과파일]
- design/backend/논리아키텍처.puml

## High Level 아키텍처 정의 가이드
[요청사항]
- 참고자료의 모든 설계 결과물을 참조하여 "High Level 아키텍처 정의서"를 작성
- 설계결과로 부터 정의할 수 있는 항목만 작성하고 추측하여 작성하지 말것   
- 단, 아래 섹션은 설계 결과에 없어도 설계 결과와 우수사례를 기반으로 작성
  - 6.1 개발 언어 및 프레임워크 선정
  - 6.4 개발 가이드라인
  - 7.2 인프라스트럭처 구성
  - 7.2.2 네트워크 구성
  - 7.2.3 보안 구성
  - 8.3 백킹 서비스 (Backing Services)
  - 9.1 AI API 통합 전략
  - 10. 개발 운영 (DevOps)
  - 11. 보안 아키텍처
  - 12. 품질 속성 구현 전략
- 백엔드 기술스택은 각 마이크로서비스마다 정의
- 기술스택 버전은 GA된 최신 버전 사용
- 서비스별 아키텍처 패턴은 클래스 설계 결과와 일치해야 함 
- MVP이므로 최소한으로 구성함 
- 백킹서비스 설치 가이드에 있는 제품을 우선적으로 사용 
- 모니터링/로깅/보안과 관련된 제품/서비스는 생략함 
- 아래 제품을 우선적으로 사용
  - API Gateway: Istio나 Spring Cloud Gateway
  - Database: 클라우드 관리형 DB가 아닌 오픈 소스 DB 
  - Message Queue: 클라우드 관리형 서비스 
  - 기타: 클라우드 관리형 서비스 
- AI API 모델은 최신 모델 선택 
-  
[참고자료]
- 유저스토리: design/Userstory.md
- 화면설계: design/wireframe 폴더의 화면설계 
- 아키텍처패턴: design/pattern/아키텍처패턴.puml
- 논리아키텍처: design/backend/논리아키텍처.puml
- API 설계서: design/backend/api/*.yaml
- 외부시퀀스 설계서: design/backend/sequence/outer/{플로우명}.puml
- 내부시퀀스 설계서: design/backend/sequence/inner/{service-name}-{flow-name}.puml
- 클래스 설계서: design/backend/class/{service-name}.puml
- 데이터 설계서: design/backend/database/*
- High Level 아키텍처 정의서 템플릿
- 백킹서비스 설치 가이드
[결과파일]
- design/High Level 아키텍처 정의서.md

## 물리 아키텍처 설계 가이드
[요청사항]
- {CLOUD} 기반의 배포 아키텍처 작성
- 설계 결과물을 참조하여 {CLOUD}의 최적의 서비스를 사용 
- MVP이므로 최소한으로 구성함 
- 백킹서비스 설치 가이드에 있는 제품을 우선적으로 사용 
- 네트워크, 보안, 운영 아키텍처는 작성하지 않음 
- 모니터링/로깅/보안과 관련된 제품/서비스는 생략함 
- 아래 제품을 우선적으로 사용
  - API Gateway: Istio나 Spring Cloud Gateway
  - Database: 클라우드 관리형 DB가 아닌 오픈 소스 DB 
  - Message Queue: 클라우드 관리형 서비스 
  - 기타: 클라우드 관리형 서비스 
- **PlantUML 스크립트 파일 생성 즉시 검사 실행**: 'PlantUML 문법 검사  가이드' 준용 
[참고자료]
- 유저스토리: Userstory.md
- 화면설계: design/wireframe 폴더의 화면설계 
- 아키텍처패턴: design/pattern/아키텍처패턴.puml
- 논리아키텍처: design/backend/논리아키텍처.puml
- API 설계서: design/backend/api/*.yaml
- 외부시퀀스 설계서: design/backend/sequence/outer/{플로우명}.puml
- 내부시퀀스 설계서: design/backend/sequence/inner/{service-name}-{flow-name}.puml
- 클래스 설계서: design/backend/class/{service-name}.puml
- 데이터 설계서: design/backend/database/*.txt 
- 백킹서비스 설치 가이드
[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_물리아키텍처.puml

[결과파일]
- design/backend/system/ 폴더에 생성 