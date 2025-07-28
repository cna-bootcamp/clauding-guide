# 클래스설계가이드 

[요청사항]
- <작성원칙>을 준용하여 설계
- <작성순서>에 따라 설계
- [결과파일] 안내에 따라 파일 작성   

[가이드]
<작성원칙>
- **유저스토리와 매칭**되어야 함. **불필요한 추가 설계 금지**
- API설계서와 일관성 있게 설계 
  - API 엔드포인트 일관성: Controller 클래스의 메소드는 **API 설계서에 정의한 엔드포인트만 생성**. 단, 필요한 Private 메소드는 추가
  - API 스키마 일관성: DTO는 API 스키마와 일치해야 함 
- 외부시퀀스설계서/내부시퀀스설계서의 플로우와 일치하도록 설계    

<작성순서>
- **서브 에이전트를 활용한 병렬 작성 필수**
- **3단계 하이브리드 접근법 적용**
- 1단계: 공통 컴포넌트 설계 (순차적)
  - 공통 클래스와 인터페이스 설계  
  - 결과: design/backend/class/common-base.puml

- 2단계: 서비스별 병렬 설계 (병렬 실행)
  - 병렬 처리 기준에 따라 검토하여 서브 에이젼트를 생성하여 병렬 실행 
    - 서비스 간 의존성이 없는 경우: 모든 서비스 동시 실행
    - 의존성이 있는 경우: 의존성 그룹별로 묶어서 실행
      - 예: A→B 의존 시, A 완료 후 B 실행
      - 독립 서비스 C,D는 A,B와 병렬 실행
  - 1단계 공통 컴포넌트 참조
  - 클래스의 프라퍼티와 메소드를 모두 기술할 것. 단, **Getter/Setter 메소드는 표현하지 말것** 
  - **클래스 간의 관계를 표현**: Generalization, Realization, Dependency, Association, Aggregation, Composition
  - 각 서비스별 지정된 {설계 아키텍처 패턴}을 적용
  - Clean아키텍처 적용 시 Port/Adapter라는 용어 대신 Clean 아키텍처에 맞는 용어 사용
  - '!include'는 사용하지 말고 필요한 인터페이스 직접 정의 
  - 공통 컴포넌트는 클래스/인터페이스 이름만 명시  
  - 결과: 
    - design/backend/class/{service-name}.puml
    - design/backend/class/{service-name}-simple.puml

- 3단계: 통합 및 검증 (순차적)
  - 클래스설계서(요약) 작성 
    - 모든 서비스의 클래스, 인터페이스, DTO 등 모든 설계요소를 표현 
    - 프라퍼티와 메소드는 모두 생략하고 설계요소 이름만 명시  
    - **클래스 간의 관계를 표현**: Generalization, Realization, Dependency, Association, Aggregation, Composition
    - 결과: design/backend/class/class-simple.puml
  - '패키지구조표준'의 예시를 참조하여 모든 클래스와 파일이 포함된 패키지 구조도를 작성: class.md에 작성 
  - 패키지 구조도는 plantuml 스크립트가 아니라 트리구조 텍스트로 작성  
  - <API/스키마매핑표가이드>에 따라 class.md파일에 매핑표 작성 
  - 인터페이스 일치성 검증
  - 명명 규칙 통일성 확인
  - 의존성 검증
  - 크로스 서비스 참조 검증
  - **PlantUML 스크립트 파일 검사 실행**: 'PlantUML문법검사가이드' 준용

<API/스키마매핑표가이드>
- **API매핑표**
아래 예제와 같은 구성으로 작성 
```
## API 엔드포인트 매핑표 
| HTTP Method | Path | Controller Method | API Title |
|-------------|------|-------------------|-----------|
| POST | /register | registerUser() | 회원가입 |
| POST | /login | loginUser() | 로그인 |
| POST | /logout | logoutUser() | 로그아웃 |
| GET | /profile | getProfile() | 프로필 조회 |
| PUT | /profile | updateProfile() | 프로필 수정 |
| POST | /profile/avatar | uploadAvatar() | 프로필 이미지 업로드 |
| PUT | /profile/password | changePassword() | 비밀번호 변경 |
| GET | /check/username/{username} | checkUsername() | 아이디 중복 확인 |
| GET | /check/email/{email} | checkEmail() | 이메일 중복 확인 |
```

- **스키마매핑표**
아래 예제와 같은 구성으로 작성 
```
## API 스키마 매핑표  
| API Schema | DTO Class | 용도 |
|------------|-----------|------|
| RegisterRequest | RegisterRequest | 회원가입 요청 |
| RegisterResponse | RegisterResponse | 회원가입 응답 |
| LoginRequest | LoginRequest | 로그인 요청 |
| LoginResponse | LoginResponse | 로그인 응답 |
| UserProfile | UserProfile | 사용자 프로필 |
| UpdateProfileRequest | UpdateProfileRequest | 프로필 수정 요청 |
| ChangePasswordRequest | ChangePasswordRequest | 비밀번호 변경 요청 |
| - | AvatarUploadResponse | 아바타 업로드 응답 |
| - | UsernameCheckResponse | 아이디 중복 확인 응답 |
| - | EmailCheckResponse | 이메일 중복 확인 응답 |
```

[참고자료]
- 유저스토리
- API설계서
- 외부시퀀스설계서
- 내부시퀀스설계서
- 패키지구조표준
- PlantUML문법검사가이드

[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_시퀀스설계서.puml
  
[결과파일]
- design/backend/class/common-base.puml
- design/backend/class/{service-name}.puml
- design/backend/class/class.md
- design/backend/class/class-simple.puml
- service-name은 영어로 작성 (예: profile, location, itinerary)
