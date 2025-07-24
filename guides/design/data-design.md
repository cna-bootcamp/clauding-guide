# 데이터 설계 가이드 

[요청사항]
- 클래스설계서의 각 서비스별 entity와 일치해야 함
- 각 서비스마다 데이터베이스를 분리하여야 함
- 마이크로서비스 원칙에 따른 데이터 독립성 보장
- 클래스 설계서의 각 서비스별 entity와 일치해야 함
- ERD는 별도 파일로 작성
- ERD의 plantuml script 문법 검사를 수행 
- 캐시 사용 시 캐시DB설계를 별도로 작성 
- 데이터설계 요약 파일을 별도로 작성 
- **PlantUML 스크립트 파일 생성 즉시 검사 실행**: 'PlantUML 문법 검사  가이드' 준용  
[작성 방법]
- **서브 에이전트를 활용한 병렬 작성 권장**
- **서비스별 독립 데이터베이스 설계**
- **데이터 격리 원칙 준수**

### 병렬 처리 전략
```
Agent 1~N: 각 서비스별 데이터베이스 설계
  - 서비스별 독립적인 스키마 설계
  - Entity 클래스와 1:1 매핑
  - 서비스 간 데이터 공유 금지
  - FK 관계는 서비스 내부에서만 설정
```

### 데이터 독립성 원칙
- **데이터 소유권**: 각 서비스가 자신의 데이터 완전 소유
- **크로스 서비스 조인 금지**: 서비스 간 DB 조인 불가
- **이벤트 기반 동기화**: 필요시 이벤트/메시지로 데이터 동기화
- **캐시 활용**: 타 서비스 데이터는 캐시로만 참조 

[참고자료]
- 유저스토리: design/Userstory.md 
- 아키텍처패턴: design/pattern/아키텍처패턴.puml
- 논리아키텍처 설명: design/backend/logical/logical-architecture.md
- 논리아키텍처 다이어그램: design/backend/logical/logical-architecture.puml
- API 설계서: design/backend/api/*.yaml
- 외부시퀀스 설계서: design/backend/sequence/outer/{플로우명}.puml
- 내부시퀀스 설계서: design/backend/sequence/inner/{service-name}-{flow-name}.puml
- 클래스 설계서: design/backend/class/{service-name}.puml

[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_데이터설계서.puml

[결과파일]
- 데이터설계서: design/backend/database/{서비스명}.md
- ERD: design/backend/database/{서비스명}-erd.puml
- 캐시DB 설계: design/backend/database/cache.md
- 데이터설계 요약: design/backend/database/database-design-summary.md
- 서비스명은 영어로 작성 