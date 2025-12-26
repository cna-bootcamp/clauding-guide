# 데이터설계가이드 

[요청사항]
- <작성원칙>을 준용하여 설계
- <작성순서>에 따라 설계
- [결과파일] 안내에 따라 파일 작성   
  
[가이드]    
<작성원칙>  
- **클래스설계서의 각 서비스별 Entity정의와 일치**해야 함. **불필요한 추가 설계 금지**
- <데이터독립성원칙>에 따라 각 서비스마다 데이터베이스를 분리
  
<작성순서>
- 준비:
  - 클래스설계서 분석 및 이해
- 실행:
  - <병렬처리>안내에 따라 각 서비스별 병렬 수행 
  - 데이터설계서 작성
    - 캐시 사용 시 캐시DB 설계 포함
    - 시작 부분에 '데이터설계 요약' 제공 
    - 결과: {service-name}.md 
  - ERD 작성
    - 결과: {service-name}-erd.puml
    - **PlantUML 스크립트 파일 생성 즉시 검사 실행**: 'PlantUML 문법 검사  가이드' 준용  
  - 데이터베이스 스키마 스크립트 작성 
    - 실행 가능한 SQL 스크립트 작성
    - 결과: {service-name}-schema.psql
- 검토: 
  - <작성원칙> 준수 검토
  - 스쿼드 팀원 리뷰: 누락 및 개선 사항 검토
  - 수정 사항 선택 및 반영  
  
<병렬처리>
Agent 1~N: 각 서비스별 데이터베이스 설계
  - 서비스별 독립적인 스키마 설계
  - Entity 클래스와 1:1 매핑
  - 서비스 간 데이터 공유 금지
  - FK 관계는 서비스 내부에서만 설정
  
<데이터독립성원칙>
- **데이터 소유권**: 각 서비스가 자신의 데이터 완전 소유
- **크로스 서비스 조인 금지**: 서비스 간 DB 조인 불가
- **이벤트 기반 동기화**: 필요시 이벤트/메시지로 데이터 동기화
- **캐시 활용**: 타 서비스 데이터는 캐시로만 참조 
  
[참고자료]
- 클래스설계서
  
[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample-데이터설계서.puml
  
[결과파일]
- design/backend/database/{service-name}.md
- design/backend/database/{service-name}-erd.puml
- design/backend/database/{service-name}-schema.psql
- service-name은 영어로 작성 
  