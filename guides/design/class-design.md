# 클래스설계가이드 
  
[요청사항]
- <작성원칙>을 준용하여 설계
- <작성순서>에 따라 설계
- [결과파일] 안내에 따라 파일 작성   
  
[가이드]  
<작성원칙>
- **유저스토리와 매칭**되어야 함. **불필요한 추가 설계 금지**
- API설계서와 일관성 있게 설계. Controller에 API를 누락하지 말고 모두 설계 
  - Controller 클래스는 API로 정의하지 않은 메소드 생성 안함. 단, 필요한 Private 메소드는 추가함  
  - {service-name}-simple.puml파일에 Note로 Controller 클래스 메소드와 API 매핑표 작성: {Methond}: {API Path} {API 제목}  
    예) login: /login 로그인 
- 내부시퀀스설계서와 일관성 있게 설계   
- 각 서비스별 지정된 {설계 아키텍처 패턴}을 적용
- Clean아키텍처 적용 시 Port/Adapter라는 용어 대신 Clean 아키텍처에 맞는 용어 사용
- 클래스의 프라퍼티와 메소드를 모두 기술할 것. 단 "Getter/Setter 메소드"는 작성하지 않음    
- 클래스 간의 관계를 표현: Generalization, Realization, Dependency, Association, Aggregation, Composition
- **마이크로서비스 아키텍처 기반 설계**    
     
<작성순서>   
- 1단계: 공통 컴포넌트 설계 (순차적)
  - 결과: design/backend/class/common-base.puml

- 2단계: 서비스별 병렬 설계 (병렬 실행)
  - 1단계 공통 컴포넌트 참조
  - '!include'는 사용하지 말고 필요한 인터페이스 직접 정의
  - 클래스 설계 후 프라퍼티와 메소드를 생략한 간단한 클래스설계서도 추가로 작성
  - 결과: 
    - design/backend/class/{service-name}.puml
    - design/backend/class/{service-name}-simple.puml

  - 병렬 처리 기준
    - 서비스 간 의존성이 없는 경우: 모든 서비스 동시 실행
    - 의존성이 있는 경우: 의존성 그룹별로 묶어서 실행
      - 예: A→B 의존 시, A 완료 후 B 실행
      - 독립 서비스 C,D는 A,B와 병렬 실행

- 3단계: 통합 및 검증 (순차적)
  - '패키지구조표준'의 예시를 참조하여 모든 클래스와 파일이 포함된 패키지 구조도를 작성 
    (plantuml 스크립트가 아니라 트리구조 텍스트로 작성)   
  - 인터페이스 일치성 검증
  - 명명 규칙 통일성 확인
  - 의존성 검증
  - 크로스 서비스 참조 검증
  - **PlantUML 스크립트 파일 검사 실행**: 'PlantUML문법검사가이드' 준용
  
[참고자료]
- 유저스토리
- API설계서
- 내부시퀀스설계서
- 패키지구조표준
- PlantUML문법검사가이드
  
[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample-클래스설계서.puml
   
[결과파일]
- 패키지 구조도: design/backend/class/package-structure.md
- 클래스설계서: 
  - design/backend/class/common-base.puml
  - design/backend/class/{service-name}.puml
- 클래스설계서(요약): design/backend/class/{service-name}-simple.puml
- service-name은 영어로 작성 (예: profile, location, itinerary)
