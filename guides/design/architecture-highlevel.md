# High Level 아키텍처 정의 가이드

[요청사항]
- 참고자료의 모든 설계 결과물을 참조하여 "High Level 아키텍처 정의서"를 작성
- MVP이므로 최소한으로 구성함 
- "백킹서비스 설치 방법"에 있는 제품을 우선적으로 사용 
- 모니터링/로깅/보안과 관련된 제품/서비스는 생략함 
- 아래 제품을 우선적으로 사용
  - API Gateway: Istio나 Spring Cloud Gateway
  - Database: 클라우드 관리형 DB가 아닌 오픈 소스 DB 
  - Message Queue: 클라우드 관리형 서비스 
  - 기타: 클라우드 관리형 서비스 
- 섹션별 지침
  - '6.1 개발 언어 및 프레임워크 선정': 핵심서비스는 Spring Boot사용. 언어와 프레임워크는 최신버전 사용
  - '6.2 서비스별 아키텍처 패턴': 패키지 구조 결과(design/backend/class/package-structure.md)와 일치
  - '9.1.1 AI 서비스/모델 매핑': 최신 모델 버전 사용  
  - '16.3 관련 문서': 참고자료의 문서명과 파일 경로 명시 
- 개발언어, 개발 프레임워크, AI모델은 '제품별 버전 가이드"를 참조하여 GA된 최신 버전 사용
- 결과는 'High Level 아키텍처 정의서.md'에 작성하고 별도의 다른 파일은 생성하지 말것
[참고자료]
- 유저스토리: design/userstory.md
- UI/UX 설계서: design/uiux/uiux.md
- 아키텍처패턴: design/pattern/아키텍처패턴.puml
- 논리아키텍처 설명: design/backend/logical/logical-architecture.md
- 논리아키텍처 다이어그램: design/backend/logical/logical-architecture.puml
- API 설계서: design/backend/api/*.yaml
- 외부시퀀스 설계서: design/backend/sequence/outer/{플로우명}.puml
- 내부시퀀스 설계서: design/backend/sequence/inner/{service-name}-{flow-name}.puml
- 클래스 설계서: design/backend/class/{service-name}.puml
- 데이터 설계서: design/backend/database/*
- High Level 아키텍처 정의서 템플릿
- 백킹서비스 설치 방법
- 제품별 버전 가이드  
[결과파일]
- design/High Level 아키텍처 정의서.md
