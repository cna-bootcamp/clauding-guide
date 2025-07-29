# 물리아키텍처설계가이드

[요청사항]
- <작성원칙>을 준용하여 설계
- <작성순서>에 따라 설계
- [결과파일] 안내에 따라 파일 작성   

[가이드]
<작성원칙>

<작성순서>
- 준비:
  - 유저스토리, 아키텍처패턴, 논리아키텍처, API설계서, 외부시퀀스설계서, 내부시퀀스설계서, 클래스설계서, 데이터설계서 분석 및 이해
- 실행: 

- 검토: 
  - <작성원칙> 준수 검토
  - 스쿼드 팀원 리뷰: 누락 및 개선 사항 검토
  - 수정 사항 선택 및 반영  
---
- {CLOUD} 기반의 배포 아키텍처 작성
- 설계 결과물을 참조하여 {CLOUD}의 최적의 서비스를 사용 
- "HighLevel아키텍처정의서"의 내용과 일치해야 함
- MVP이므로 최소한으로 구성함 
- "백킹서비스 설치 방법"에 있는 제품을 우선적으로 사용 
- 네트워크, 보안, 운영 아키텍처는 작성하지 않음 
- 모니터링/로깅/보안과 관련된 제품/서비스는 생략함 
- 아래 제품을 우선적으로 사용
  - API Gateway: Istio나 Spring Cloud Gateway
  - Database: 클라우드 관리형 DB가 아닌 오픈 소스 DB 
  - Message Queue: 클라우드 관리형 서비스 
  - 기타: 클라우드 관리형 서비스 
- Mermaid 파일로 작성   
- 완료 후 mermaid 스크립트 테스트 방법 안내 
  - https://mermaid.live/edit 에 접근 
  - 스크립트 내용을 붙여넣어 확인  
[참고자료]
- 유저스토리
- UI/UX설계서
- 논리아키텍처
- API설계서
- 외부시퀀스설계서
- 내부시퀀스설계서
- 클래스설계서
- 데이터설계서
- HighLevel아키텍처정의서
- 백킹서비스 설치 방법
[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_물리아키텍처.mmd

[결과파일]
- 물리아키텍처 설명: design/backend/physical/physical-architecture.md
- 물리아키텍처 다이어그램: design/backend/physical/physical-architecture.mmd
