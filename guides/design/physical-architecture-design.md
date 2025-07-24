# 물리 아키텍처 설계 가이드
[요청사항]
- {CLOUD} 기반의 배포 아키텍처 작성
- 설계 결과물을 참조하여 {CLOUD}의 최적의 서비스를 사용 
- "High Level 아키텍처 정의"의 내용과 일치해야 함
- MVP이므로 최소한으로 구성함 
- "백킹서비스 설치 방법"에 있는 제품을 우선적으로 사용 
- 네트워크, 보안, 운영 아키텍처는 작성하지 않음 
- 모니터링/로깅/보안과 관련된 제품/서비스는 생략함 
- 아래 제품을 우선적으로 사용
  - API Gateway: Istio나 Spring Cloud Gateway
  - Database: 클라우드 관리형 DB가 아닌 오픈 소스 DB 
  - Message Queue: 클라우드 관리형 서비스 
  - 기타: 클라우드 관리형 서비스 
- **PlantUML 스크립트 파일 생성 즉시 검사 실행**: 'PlantUML 문법 검사  가이드' 준용 
[참고자료]
- 유저스토리: design/Userstory.md
- Wireframe: design/wireframe/{화면순서번호 2자리}-{화면명}.svg
- Flow 다이어그램: design/wireframe/user-flow-diagram.svg 
- 아키텍처패턴: design/pattern/아키텍처패턴.puml
- 논리아키텍처: design/backend/logical/논리아키텍처.puml
- API 설계서: design/backend/api/*.yaml
- 외부시퀀스 설계서: design/backend/sequence/outer/{플로우명}.puml
- 내부시퀀스 설계서: design/backend/sequence/inner/{service-name}-{flow-name}.puml
- 클래스 설계서: design/backend/class/{service-name}.puml
- 데이터 설계서: design/backend/database/*.txt 
- High Level 아키텍처 정의: design/backend/physical/*.puml
- 백킹서비스 설치 방법
[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_물리아키텍처.puml

[결과파일]
- 물리아키텍처 설명: design/backend/physical/physical-architecture.md
- 물리아키텍처 다이어그램: design/backend/physical/physical-architecture.puml
