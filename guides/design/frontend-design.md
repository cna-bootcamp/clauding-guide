# 프론트엔드설계가이드 

[요청사항]
- <설계원칙>을 준용하여 설계
- <설계순서>에 따라 설계
- [결과파일] 안내에 따라 파일 작성

[가이드]
<설계원칙>
- 기술스택: TypeScript 5.5 + React 18.3 + Vite 5.4
- 프로토타입과 동일하게 설계  
- 각 백엔드서비스 API명세서와 반드시 일치
- 모바일, 태블릿, 웹 화면 크기에 맞게 반응형으로 디자인  

<설계순서>
- 준비:
  - 프로토타입 분석 및 이해  
  - "[백엔드시스템]"섹션의 정보를 이용하여 API명세서를 'desing/frontend/api'에 다운로드하여 분석 및 이해
  - "[요구사항]" 섹션을 읽어 화면 요구사항 이해

- 설계:
  - 1. **UI/UX 설계**
    - 1.1 UI프레임워크 선택: MUI, Ant Design, Chakra UI, Mantine, React Bootstrap 등    
    - 1.2 화면목록 정의
    - 1.3 화면 간 사용자 플로우 정의 
    - 1.4 화면별 상세 설계: 
      - 1.4.1 상세기능
      - 1.4.2 UI 구성요소
      - 1.4.3 인터랙션
    - 1.5 화면간 전환 및 네비게이션 
    - 1.6 반응형 설계 전략 
    - 1.7 접근성 보장 방안 
    - 1.8 성능 최적화 방안 

  - 2. **스타일가이드 작성**: 
    API명세서 분석 결과와 선택한 UI프레임워크 특성을 반영
    - 2.1 브랜드 아이덴티티: 디자인 컨셉 등 
    - 2.2 디자인 원칙  
    - 2.3 컬러 시스템 
    - 2.4 타이포그래피
    - 2.5 간격 시스템
    - 2.6 컴포넌트 스타일 
    - 2.7 반응형 브레이크포인트
    - 2.8 대상 서비스 특화 컴포넌트  
    - 2.9 인터랙션 패턴

  - 3. **정보 아키텍처 설계**
    - 3.1 사이트맵: 페이지 구조 및 네비게이션 흐름
    - 3.2 프로젝트 구조 설계: 패키지와 파일까지 설계

  - 4. **API매핑설계서**
    - 4.1 API경로 매핑  
      public/runtime-env.js파일을 읽어 API그룹과 '"[백엔드시스템]"섹션에 정의된 각 서비스별 HOST를 지정       
      예시)
      ```
      window.__runtime_config__ = { 
        API_GROUP: "/api/${version:v1}",
        USER_HOST: "http://localhost:8081",
        ORDER_HOST: "http://localhost:8082"
      }
      ```

    - 4.2 **API와 화면 상세기능 매칭**: '1.4.1 상세기능'과 API 매핑   
      - 화면, 기능, 백엔드 서비스, API경로, 요청데이터 구조, 응답데이터 구조 명시    
      - API 요청데이타와 API 응답데이터 예시 

[참고자료]
- 프로토타입: ../{시스템}/design/uiux/prototype/*
- API명세서: design/frontend/api/*.json

[결과파일]
- UI/UX설계서: design/frontend/uiux-design.md
- 스타일가이드: design/frontend/style-guide.md
- 정보아키텍처: design/frontend/ia.md
- API매핑설계서: design/frontend/api-mapping.md


