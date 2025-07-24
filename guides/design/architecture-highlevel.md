# High Level 아키텍처 정의 가이드

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
- 백엔드 기술스택은 각 마이크로서비스별로 정의
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
- 결과는 'High Level 아키텍처 정의서.md'에 작성하고 별도의 다른 파일은 생성하지 말것
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
