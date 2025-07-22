# OpenAPI 도구 가이드

## 📁 openapi-to-csv 변환기

OpenAPI 3.0 YAML 파일을 CSV 형식으로 변환하는 전용 도구입니다.

### 🎯 목적
- OpenAPI 명세를 Excel에서 쉽게 볼 수 있는 형태로 변환
- API 설계서를 체계적으로 문서화
- 17개 컬럼의 상세한 API 정보 제공

### 📂 파일 구조
```
guides/tools/openapi-to-csv/
├── openapi-to-csv.js    # 메인 변환 스크립트
├── package.json         # npm 패키지 설정
└── README.md            # (선택적) 도구 설명서
```

### 🚀 설치

1. **의존성 설치**:
   ```bash
   cd guides/tools/openapi-to-csv
   npm install
   ```

2. **전역 설치** (어디서든 사용하려면):
   ```bash
   cd guides/tools/openapi-to-csv
   npm install -g .
   ```

### 💻 사용법

#### 기본 사용
```bash
# 전역 설치 후
openapi-to-csv -d design/backend/api -o design/backend/API설계서.txt

# 직접 실행
node guides/tools/openapi-to-csv/openapi-to-csv.js -d design/backend/api -o design/backend/API설계서.txt
```

#### 옵션
| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `-d, --directory` | OpenAPI YAML 파일들이 있는 디렉토리 | `.` |
| `-o, --output` | 출력 CSV 파일 경로 | `API설계서.txt` |
| `-h, --help` | 도움말 표시 | - |
| `--version` | 버전 정보 | - |

#### 예시
```bash
# 기본 사용
openapi-to-csv -d ./api -o ./api-spec.csv

# 상대 경로 사용
openapi-to-csv -d design/backend/api -o design/backend/API설계서.txt

# 현재 디렉토리의 YAML 파일들 처리
openapi-to-csv -o ./output.csv
```

### 📊 출력 형식

#### CSV 헤더 (17개 컬럼)
```
서비스명|마이크로서비스 이름|유저스토리 ID|유저스토리 제목|Controller 이름|API 목적|API Method|API 그룹 Path|API Path|Path 변수|Query 변수|Request DTO 이름|Request DTO 배열 여부|Request DTO 구조|Response DTO 이름|Response DTO 배열 여부|Response DTO 구조
```

#### 컬럼 설명
| 컬럼 | 설명 | 예시 |
|------|------|------|
| 서비스명 | 한국어 서비스명 | `프로파일 서비스` |
| 마이크로서비스 이름 | 파일명 기반 서비스명 | `profile-service-api` |
| 유저스토리 ID | x-user-story 확장 필드 값 | `RQ-PROF-001` |
| 유저스토리 제목 | API summary | `여행 멤버 등록` |
| Controller 이름 | x-controller 확장 필드 값 | `ProfileController` |
| API 목적 | description 또는 summary | `멤버를 생성합니다` |
| API Method | HTTP 메서드 | `POST` |
| API 그룹 Path | 서버 URL | `/api/v1/profiles` |
| API Path | 엔드포인트 경로 | `/members/{memberId}` |
| Path 변수 | 경로 변수들 | `string memberId` |
| Query 변수 | 쿼리 파라미터들 | `string date, number page` |
| Request DTO 이름 | 요청 스키마명 | `MemberCreateRequest` |
| Request DTO 배열 여부 | 배열 타입 여부 | `true/false` |
| Request DTO 구조 | 필드:타입 구조 | `name:string, age:number` |
| Response DTO 이름 | 응답 스키마명 | `MemberResponse` |
| Response DTO 배열 여부 | 배열 타입 여부 | `true/false` |
| Response DTO 구조 | 필드:타입 구조 | `memberId:string, name:string` |

### ✅ 검증 기능

도구에 포함된 자동 검증:
- **YAML 구문 검사**: 잘못된 YAML 형식 감지
- **OpenAPI 스펙 준수**: 3.0 스펙 위반사항 확인
- **필수 필드 검사**: summary, operationId 등 누락 확인
- **스키마 참조 검증**: $ref 참조 유효성 검사

### 🔧 고급 기능

#### 1. 서비스명 자동 매핑
```javascript
const serviceNameMap = {
    'profile-service': '프로파일 서비스',
    'itinerary-service': '일정 서비스', 
    'location-service': '장소 서비스'
};
```

#### 2. 데이터 타입 자동 분석
- 중첩 객체 구조 분석
- 배열 타입 자동 감지
- 스키마 참조($ref) 해석

#### 3. 특수 문자 처리
- 파이프(|) 문자를 전각 문자(｜)로 자동 치환
- CSV 형식 오류 방지

### 🐛 문제 해결

#### 자주 발생하는 오류

1. **파일을 찾을 수 없음**
   ```
   ❌ 입력 디렉토리를 찾을 수 없습니다: ./api
   ```
   **해결**: 올바른 디렉토리 경로 확인

2. **YAML 파일 없음**
   ```
   ❌ ./api에서 YAML 파일을 찾을 수 없습니다.
   ```
   **해결**: `.yaml` 또는 `.yml` 확장자 파일 확인

3. **YAML 구문 오류**
   ```
   오류: profile-service-api.yaml 처리 중 오류 발생: bad indentation
   ```
   **해결**: YAML 들여쓰기 및 구문 검사

4. **의존성 오류**
   ```
   Error: Cannot find module 'js-yaml'
   ```
   **해결**: `npm install` 실행

#### 디버깅 모드
```bash
# 자세한 로그 출력
DEBUG=1 openapi-to-csv -d ./api -o ./output.csv

# 또는 Node.js 직접 실행
node --inspect guides/tools/openapi-to-csv/openapi-to-csv.js
```

### 📈 성능 정보
- **처리 속도**: 파일당 평균 100ms
- **메모리 사용량**: 50MB 미만 (일반적인 API 명세)
- **지원 파일 수**: 제한 없음 (메모리 허용 범위 내)

### 🔗 연관 도구
- **swagger-cli**: OpenAPI 검증 도구
- **swagger-ui**: API 문서 시각화
- **openapi-generator**: 코드 생성 도구

---

💡 **Tip**: Excel에서 CSV 파일을 열 때는 구분자를 파이프(|)로 설정하세요!