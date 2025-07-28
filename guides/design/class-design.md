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
  - 각 서비스별 지정된 {설계 아키텍처 패턴}을 적용 
  - Clean아키텍처 적용 시 Port/Adapter라는 용어 대신 Clean 아키텍처에 맞는 용어 사용
  - '!include'는 사용하지 말고 필요한 인터페이스 직접 정의 
  - 패키지 그룹명은 생략하고 설계 아키텍처 패턴에 따른 레이어별로 그룹핑
  - <클래스관계 표시규칙>에 따라 **클래스 간의 관계를 표현**
  - 공통 컴포넌트는 클래스/인터페이스 이름만 명시 
  - 클래스 설계서 작성 
    - <클래스설계서 작성규칙>에 따라 작성  
    - 결과: design/backend/class/{service-name}.puml
  - 간단 클래스설계서 작성 
    - <간단클래스설계서 작성규칙>에 따라 작성  
    - 결과: design/backend/class/{service-name}-simple.puml
  
- 3단계: 통합 및 검증 (순차적)
  - '패키지구조표준'의 예시를 참조하여 모든 클래스와 파일이 포함된 패키지 구조도를 작성: class.md에 작성 
  - 패키지 구조도는 plantuml 스크립트가 아니라 트리구조 텍스트로 작성  
  - <API/스키마매핑표가이드>에 따라 class.md파일에 매핑표 작성 
  - 인터페이스 일치성 검증
  - 명명 규칙 통일성 확인 
  - 의존성 검증
  - 크로스 서비스 참조 검증
  - **PlantUML 스크립트 파일 검사 실행**: 'PlantUML문법검사가이드' 준용
  - 결과:  
    - design/backend/class/class.md
    - design/backend/class/class-simple.puml

<클래스설계서 작성규칙>
- 클래스의 프라퍼티와 메소드를 모두 기술할 것. 단, **Getter/Setter 메소드는 표현하지 말것** 

<간단클래스설계서 작성규칙>
- 프라퍼티: 생략 
- 메소드: '메소드명: 기능 설명'으로 하고 기능 설명은 한글로 함. 예) register: 회원등록 
- 메소드명에 생성자, Getter, Setter는 생략    

<클래스관계 표시규칙>
```
1. 일반화 (Generalization)
표현기호: "실선 + 빈 삼각형 화살표 (△)"
- 상속 관계를 나타내며, 부모클래스와 자식클래스 간의 관계
- 자식클래스가 부모클래스의 속성과 메서드를 상속받음
- 부모클래스는 반드시 Abstract Class일 필요는 없음

1. 실체화 (Realization) 
표현기호: "점선 + 빈 삼각형 화살표 (△)"
- 인터페이스와 구현 클래스 간의 관계
- 구현클래스가 인터페이스에 정의된 메서드를 실제로 구현
- 인터페이스 이름 앞에는 보통 'I'자를 붙임

1. 의존 (Dependency)
표현기호: "점선 + 일반 화살표 (→)"
- 클래스의 메서드 내에서 다른 객체를 생성하고 요청하는 관계
- 의존하는 객체와의 관계는 메서드 내에서만 유지됨
- 점선에 화살표로 표시 (관계가 오래 지속되지 않으니 점선)

1. 연관 (Association)
표현기호: "실선 + 일반 화살표 (→) + 다중성 표시 (1, n)"
- 클래스의 프로퍼티로 다른 객체를 생성하고 요청하는 관계
- 의존하는 객체와의 관계는 클래스 내에서 계속 유지됨
- 실선에 화살표와 객체간 관계 표시 (관계가 더 오래 지속되니 실선)

1. 집합 (Aggregation)
표현기호: "실선 + 빈 마름모 (◇)" + "has-a" 관계
- 전체 객체가 부분 객체를 소유하나 전체 객체가 없어져도 부분 객체는 사라지지 않는 관계
- 처음에는 집합 관계로 정의하고 결합의 강도를 고민하여 합성 관계로 바뀌는 것이 좋음
- 실선 + 빈 마름모로 표시

1. 합성 (Composition)
표현기호: "실선 + 채운 마름모 (♦)" + "owns-a" 관계  
- 전체 객체가 부분 객체를 강하게 소유하여 전체 객체가 없어지면 부분 객체도 사라져야 하는 관계
- 데이터 구조와 관련이 깊은 Entity클래스는 전체 객체의 데이터가 삭제되었을 때 부분 객체의 데이터도 삭제되어야 한다면 합성 관계로 정의함
- 실선 + 채운 마름모로 표시
```

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
- design/backend/class/{service-name}-simple.puml
- design/backend/class/class.md
- service-name은 영어로 작성 (예: profile, location, itinerary)
