# API 설계 가이드

[요청사항]
- OpenAPI 3.0 스펙을 사용하여 API 설계
- 각 서비스별로 별도의 YAML 파일 생성
- 유저스토리 ID를 x-user-story 확장 필드에 명시
- 작성된 YAML의 문법 및 구조 검증 수행

[검증 방법]
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

[작성 방법]
- **공통 설계 원칙 참조**: [common-principles.md](common-principles.md)
- 서브 에이전트를 활용한 병렬 작성 권장
- 의존성 분석 및 병렬 처리 전략 적용
- 의존성 그룹별로 에이전트를 할당하여 동시 작업

[파일 구조]
```
design/backend/api/
├── {service-name}-api.yaml      # 각 마이크로서비스별 API 명세
└── ...                          # 추가 서비스들

예시:
├── profile-service-api.yaml     # 프로파일 서비스 API
├── order-service-api.yaml       # 주문 서비스 API
└── payment-service-api.yaml     # 결제 서비스 API
```

[설계 원칙]
- 각 서비스 API는 독립적으로 완전한 명세를 포함
- 공통 스키마는 각 서비스에서 필요에 따라 직접 정의
- 서비스 간 의존성을 최소화하여 독립 배포 가능
- 중복되는 스키마가 많아질 경우에만 공통 파일 도입 검토

[파일명 규칙]
- 서비스명은 kebab-case로 작성
- 파일명 형식: {service-name}-api.yaml
- 서비스명은 유저스토리의 '서비스' 항목을 영문으로 변환하여 사용

[작성 형식]
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

[참고자료]
- 유저스토리: Userstory.md
- 화면설계: design/wireframe 폴더의 화면설계 
- 아키텍처패턴: design/pattern/아키텍처패턴.txt
- 논리아키텍처: design/backend/논리아키텍처.txt
- OpenAPI 스펙: https://swagger.io/specification/

[예시]
- swagger api yaml: https://cna-bootcamp.github.io/clauding-guide/samples/sample_swagger_api.yaml
- API 설계서: https://cna-bootcamp.github.io/clauding-guide/samples/sample_API%20설계서.txt

[결과파일]
- design/backend/api/*.yaml (OpenAPI 형식)
- design/backend/api/API설계서.txt (CSV 형식)
- 각 파일 작성 후 다음 단계 수행:
  1. swagger-cli validate 실행하여 검증
  2. openapi-to-csv 실행하여 CSV 생성

## CSV 생성 방법

### 📁 openapi-to-csv 도구 사용

이 프로젝트에는 전용 OpenAPI to CSV 변환 도구가 포함되어 있습니다.

**위치**: `guides/tools/openapi-to-csv/`

### 🚀 설치 및 사용법

1. **의존성 설치**:
   ```bash
   cd guides/tools/openapi-to-csv
   npm install
   ```

2. **전역 설치** (선택사항):
   ```bash
   # 전역 설치 시 어디서든 사용 가능
   cd guides/tools/openapi-to-csv
   npm install -g .
   ```

3. **CSV 생성 실행**:
   ```bash
   # 방법 1: 전역 설치 후
   openapi-to-csv -d design/backend/api -o design/backend/api/API설계서.txt
   
   # 방법 2: 직접 실행
   node guides/tools/openapi-to-csv/openapi-to-csv.js -d design/backend/api -o design/backend/api/API설계서.txt
   
   # 방법 3: npm script 사용
   cd guides/tools/openapi-to-csv
   npm start -- -d ../../../design/backend/api -o ../../../design/backend/api/API설계서.txt
   ```

4. **사용 옵션**:
   ```bash
   openapi-to-csv [옵션]
   
   옵션:
     -d, --directory <dir>   입력 디렉토리 (기본: .)
     -o, --output <file>     출력 파일명 (기본: API설계서.txt)
     -h, --help             도움말 표시
     --version              버전 정보
   ```

### 📊 생성 결과
- **출력 파일**: design/backend/api/API설계서.txt
- **형식**: 파이프(|)로 구분된 CSV
- **Excel 활용**: 구분자를 파이프(|)로 설정하여 열기

### ✅ 검증 기능
도구에 포함된 기능:
- OpenAPI 3.0 스펙 유효성 검사
- 누락된 필드 자동 감지
- 한국어 서비스명 자동 매핑
- 에러 발생 시 상세 메시지 제공

## CSV 형식 설명

- 구분자: 파이프(|) 사용
- 헤더 순서 (17개 컬럼):
  ```
  서비스명|마이크로서비스 이름|유저스토리 ID|유저스토리 제목|Controller 이름|API 목적|API Method|API 그룹 Path|API Path|Path 변수|Query 변수|Request DTO 이름|Request DTO 배열 여부|Request DTO 구조|Response DTO 이름|Response DTO 배열 여부|Response DTO 구조
  ```
- 컬럼 설명:
  - 서비스명: 유저스토리의 서비스명
  - 마이크로서비스 이름: 파일명에서 추출 (예: profile-service-api)
  - 유저스토리 ID: x-user-story 값 (예: RQ-PROF-001)
  - 유저스토리 제목: API의 summary
  - Controller 이름: x-controller 값
  - API 목적: API의 description 또는 summary
  - API Method: GET, POST, PUT, DELETE 등
  - API 그룹 Path: 서버 URL (예: /api/v1/profiles)
  - API Path: 엔드포인트 경로 (예: /members/{memberId})
  - Path 변수: 경로 변수 타입과 이름 (예: string memberId)
  - Query 변수: 쿼리 파라미터 타입과 이름 (예: string date, number page)
  - Request DTO 이름: 요청 body의 스키마명
  - Request DTO 배열 여부: true/false
  - Request DTO 구조: 필드명:타입 형식 (예: name:string, age:number)
  - Response DTO 이름: 응답 body의 스키마명
  - Response DTO 배열 여부: true/false
  - Response DTO 구조: 필드명:타입 형식

## CSV 예시

```
서비스명|마이크로서비스 이름|유저스토리 ID|유저스토리 제목|Controller 이름|API 목적|API Method|API 그룹 Path|API Path|Path 변수|Query 변수|Request DTO 이름|Request DTO 배열 여부|Request DTO 구조|Response DTO 이름|Response DTO 배열 여부|Response DTO 구조
프로파일 서비스|profile-service-api|RQ-PROF-001|여행 멤버 등록|ProfileController|멤버를 생성합니다|POST|/api/v1/profiles|/members|||MemberCreateRequest|false|name:string, age:number, healthStatus:string, preferences:array|MemberResponse|false|memberId:string, name:string, age:number, createdAt:string
프로파일 서비스|profile-service-api|RQ-PROF-001|멤버 목록 조회|ProfileController|모든 멤버를 조회합니다|GET|/api/v1/profiles|/members||number page, number size||false||MemberResponse|true|memberId:string, name:string, age:number, createdAt:string
```