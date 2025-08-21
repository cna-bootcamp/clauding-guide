@plan as @front
Frontend 개발을 위한 설계서를 작성해 주세요.
[요청사항]
-
[참고문서]

[응답]
tripgen-front/ 디렉토리 하위에 마크다운 파일로 작성

---
# 프론트엔드설계가이드

[요청사항]
- <설계원칙>을 준용하여 설계
- <설계순서>에 따라 설계
- [결과파일] 안내에 따라 파일 작성
[가이드]
<설계원칙>
- 각 백엔드서비스 API 스펙과 반드시 일치
- 참고문서의 설계서와 백엔드 코드가 일치하지 않으면 백엔드 코드 준용 
- *모바일 화면 크기에 맞게 "넓이"와 "높이"를 최적화*
- *이미지 크기는 화면에 맞게 적절하게 조정*
- 개발언어: TypeScript 5.5
- 프레임워크: React 18.3 + Vite 5.4
- 각 화면 상단 좌측에 이전화면으로 돌아가는 Back 아이콘 버튼과 화면 타이틀 표시
- login 외 다른 api는 login API에서 받은 JWT토큰을 'Authorization' 헤더에 추가해야 함
- 백엔드API경로 정보: public/runtime-env.js파일로 생성함
  ```
  window.__runtime_config__ = { 
    GATEWAY_HOST: 'http://${gateway_host:localhost}', 
    API_GROUP: "/api/${version:v1}"
  }
  ```

<설계순서>
- 준비:
  - 유저스토리, UI/UX설계서, 스타일가이드 분석 및 이해
  - 프로토타입을 웹브라우저에 열어 화면구성과 사용자 플로우 이해 
  - 각 백엔드 서비스 Swagger Page를 curl로 열어 분석 및 이해
    - user service: http://localhost:8081/v3/api-docs 
    - location service: http://localhost:8082/v3/api-docs
    - trip service: http://localhost:8083/v3/api-docs
    - ai service: http://localhost:8084/v3/api-docs
- 설계:
  - 프로젝트 구조 , 프로젝트 실행 방법을 먼저 제시
- 프로젝트 구조에 대한 확인을 받고 각 파일 소스 개발 시작
- 각 파일 소스는 분리하지 말고 **단일 코드블록**으로 제공
- App.js, App.css, index.js, index.css, index.html, package.json, .gitignore, manifest.json도 누락하지 말고 보여줄 것

  - <병렬처리> 안내에 따라 동시 수행
  - <파일작성안내>에 따라 작성
  - <검증방법>에 따라 작성된 YAML의 문법 및 구조 검증 수행
- 검토:
  - <작성원칙> 준수 검토
  - 스쿼드 팀원 리뷰: 누락 및 개선 사항 검토
  - 수정 사항 선택 및 반영

<API선정원칙>
- 유저스토리와 매칭 되어야 함. 불필요한 추가 설계 금지
  (유저스토리 ID를 x-user-story 확장 필드에 명시)
- '외부시퀀스설계서'/'내부시퀀스설계서'와 일관성 있게 선정

<파일작성안내>
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

<병렬처리>
- **의존성 분석 선행**: 병렬 처리 전 반드시 의존성 파악
- **순차 처리 필요시**: 무리한 병렬화보다는 안전한 순차 처리
- **검증 단계 필수**: 병렬 처리 후 통합 검증

<검증방법>
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
- swagger api yaml: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample-swagger-api.yaml
- API설계서: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample-API%20설계서.md

[결과파일]
- 각 서비스별로 별도의 YAML 파일 생성
- design/backend/api/*.yaml (OpenAPI 형식)
