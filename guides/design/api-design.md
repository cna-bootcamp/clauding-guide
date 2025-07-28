# API설계가이드

[요청사항]
- <작성 원칙> 준용 
- <API 선정 원칙>에 따라 API 선정 
- <파일 작성 안내>에 따라 작성 
- <병렬처리> 안내에 따라 동시 수행 
- <검증방법>에 따라 작성된 YAML의 문법 및 구조 검증 수행
- [결과파일]안내에 따라 파일 작성 
- 최종 완료 후 API 확인 방법 안내 
  - https://editor.swagger.io/ 접근  
  - 생성된 swagger yaml파일을 붙여서 확인 및 테스트  

[가이드]
<작성 원칙>
- 각 서비스 API는 독립적으로 완전한 명세를 포함
- 공통 스키마는 각 서비스에서 필요에 따라 직접 정의
- 서비스 간 의존성을 최소화하여 독립 배포 가능
- 중복되는 스키마가 많아질 경우에만 공통 파일 도입 검토

<API 선정 원칙>
- 유저스토리와 매칭 되어야 함. 불필요한 추가 설계 금지  
  (유저스토리 ID를 x-user-story 확장 필드에 명시)
- '외부시퀀스설계서'/'내부시퀀스설계서'와 일관성 있게 선정 

<파일 작성 안내>
- OpenAPI 3.0 스펙 준용 
- **servers 섹션 필수화**
  - 모든 OpenAPI 명세에 servers 섹션 포함
  - SwaggerHub Mock URL을 첫 번째 옵션으로 배치
- **example 데이터 권장**
  - 스키마에 example을 추가하여 Swagger UI에서 테스트 할 수 있게함 
- **테스트 시나리오 포함**
  - 각 API 엔드포인트별 테스트 케이스 정의
  - 성공/실패 케이스 모두 포함
- 작성 형식
  - YAML 형식의 OpenAPI 3.0 명세
  - 각 API별 필수 항목:
    - summary: API 목적 설명
    - operationId: 고유 식별자
    - x-user-story: 유저스토리 ID
    - x-controller: 담당 컨트롤러
    - tags: API 그룹 분류
    - requestBody/responses: 상세 스키마
  - 각 서비스 파일에 필요한 모든 스키마 포함:
    - components/schemas: 요청/응답 모델
    - components/parameters: 공통 파라미터
    - components/responses: 공통 응답
    - components/securitySchemes: 인증 방식

<파일 구조>
```
design/backend/api/
├── {service-name}-api.yaml      # 각 마이크로서비스별 API 명세
└── ...                          # 추가 서비스들

예시:
├── profile-service-api.yaml     # 프로파일 서비스 API
├── order-service-api.yaml       # 주문 서비스 API
└── payment-service-api.yaml     # 결제 서비스 API
```

- 파일명 규칙
  - 서비스명은 kebab-case로 작성
  - 파일명 형식: {service-name}-api.yaml
  - 서비스명은 유저스토리의 '서비스' 항목을 영문으로 변환하여 사용

<병렬 처리>
- **의존성 분석 선행**: 병렬 처리 전 반드시 의존성 파악
- **순차 처리 필요시**: 무리한 병렬화보다는 안전한 순차 처리
- **검증 단계 필수**: 병렬 처리 후 통합 검증

<검증 방법>
- swagger-cli를 사용한 자동 검증 수행
- 검증 명령어: `swagger-cli validate {파일명}`
- swagger-cli가 없을 경우 자동 설치:
  ```bash
  # swagger-cli 설치 확인 및 자동 설치
  command -v swagger-cli >/dev/null 2>&1 || npm install -g @apidevtools/swagger-cli
  
  # 검증 실행
  swagger-cli validate design/backend/api/*.yaml
  ```
- 검증 항목:
  - OpenAPI 3.0 스펙 준수
  - YAML 구문 오류
  - 스키마 참조 유효성
  - 필수 필드 존재 여부

[참고자료]
- 유저스토리
- 외부시퀀스설계서
- 내부시퀀스설계서
- OpenAPI 스펙: https://swagger.io/specification/

[예시]
- swagger api yaml: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_swagger_api.yaml
- API설계서: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_API%20설계서.md

[결과파일]
- 각 서비스별로 별도의 YAML 파일 생성 
- design/backend/api/*.yaml (OpenAPI 형식)