# 물리아키텍처설계가이드

[요청사항]
- <작성원칙>을 준용하여 설계
- <작성순서>에 따라 설계
- [결과파일] 안내에 따라 파일 작성   
- 완료 후 mermaid 스크립트 테스트 방법 안내 
  - https://mermaid.live/edit 에 접근 
  - 스크립트 내용을 붙여넣어 확인  

[가이드]
<작성원칙>
- {CLOUD} 기반의 물리 아키텍처 설계
- 'HighLevel아키텍처정의서'와 일치해야 함 
- "백킹서비스설치방법"에 있는 제품을 우선적으로 사용 
<작성순서>
- 준비:
  - 아키텍처패턴, 논리아키텍처, 외부시퀀스설계서, 데이터설계서, HighLevel아키텍처정의서 분석 및 이해
- 실행:
  - 물리아키텍처 설계서 작성: physical-architecture.md
    - 최적화된 운영환경의 물리 아키텍처 설계
    - 추가로 MVP로 빠르게 개발할 수 있는 개발환경 물리아키텍처도 설계 
      - 사용자 → Ingress → 서비스 → 데이터베이스 플로우만 표시
      - 클라우드 서비스는 최소한으로만 포함
      - 부가 설명은 문서에만 기록, 다이어그램에서 제거
      - 네트워크, 보안, 운영, CI/CD 관련 아키텍처는 생략  
      - 모니터링/로깅/보안과 관련된 제품/서비스 생략함
      - 제품/서비스 구성 
        - Application Gateway: Kubernetes Ingress 
        - Database: "백킹서비스설치방법"에 있는 오픈소스 DB사용. Kubernetes에 Pod로 배포  
        - Message Queue: "백킹서비스설치방법"에 있는 {CLOUD}에서 제공하는 제품
  - 물리아키텍처 다이어그램 작성: 
    - Mermaid 형식으로 작성 
    - 결과
      - 개발환경: physical-architecture-dev.mmd
      - 운영환경: physical-architecture-prod.mmd
- 검토: 
  - <작성원칙> 준수 검토
  - 스쿼드 팀원 리뷰: 누락 및 개선 사항 검토
  - 수정 사항 선택 및 반영  

[참고자료]
- 아키텍처패턴
- 논리아키텍처
- 외부시퀀스설계서
- 데이터설계서
- HighLevel아키텍처정의서
[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_물리아키텍처.mmd

[결과파일]
- design/backend/physical/physical-architecture.md
- design/backend/physical/physical-architecture-dev.mmd
- design/backend/physical/physical-architecture-prod.mmd
