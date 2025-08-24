# 프론트엔드설계가이드 

[요청사항]
- <설계원칙>을 준용하여 설계
- <설계순서>에 따라 설계
- [결과파일] 안내에 따라 파일 작성

[가이드]
<설계원칙>
- 기술스택: TypeScript 5.5 + React 18.3 + Vite 5.4
- 각 백엔드서비스 API명세서와 반드시 일치
- *모바일 화면 크기에 맞게 "넓이"와 "높이"를 최적화*
- *이미지 크기는 화면에 맞게 적절하게 조정*
- 프로토타입은 참고용이므로 백엔드 API명세서 분석결과에 따라 재설계

<설계순서>
- 준비:
  - 프로토타입을 **웹브라우저에 열어** 화면구성과 사용자 플로우 이해 
  - API명세서 분석 및 이해: "[백엔드서비스]"섹션의 정보를 이용하여 '../{시스템}/design/backend/api/spec'폴더에 다운로드하여 분석 및 이해
  - **{마이크로서비스}의 소스 분석 및 이해**
- 설계:
  <병렬처리> 안내에 따라 병렬 수행 가능한 설계는 동시 수행
  - 1단계: UI/UX 설계
    - **요구사항 반영**  
      - 각 화면에 Back 아이콘 버튼과 화면 타이틀 표시
      - 하단 네비게이션 바 아이콘화: 홈, 새여행, 주변장소검색, 여행보기
    - **UI프레임워크 선택**: MUI(Material-UI), Ant Design, Chakra UI, Mantine, React Bootstrap 등
    - **UI/UX설계**: 
      - 기존 'UI/UX설계서'를 참고하여 프로토타입이 아닌 정식 프론트엔드 UI/UX설계 
      - API명세서 분석 결과와 선택한 UI프레임워크 특성을 반영
      - 구성
        - 프로토타입 화면 목록 정의
        - 화면 간 사용자 플로우 정의 
        - 화면별 상세 설계: UI구성요소를 필드 수준으로 상세하게 설계 
    - **스타일가이드 작성**: 
      - 기존 '스타일가이드'를 참고하여 프로토타입이 아닌 정식 프론트엔드 스타일가이드 작성
      - API명세서 분석 결과와 선택한 UI프레임워크 특성을 반영
      - 구성
        - 브랜드 아이덴티티
        - 디자인 원칙
        - 컬러시스템
        - 타이포그래피
        - 간격시스템
        - 컴포넌트 스타일
        - 반응형 브레이크포인트
        - 대상 서비스 특화 컴포넌트
        - 인터랙션 패턴
  - 2단계: 정보 아키텍처 설계
    - **사이트맵 작성**: 페이지 구조 및 네비게이션 흐름
    - **라우팅 구조 설계**: URL 패턴 및 동적 라우팅 정의
    - **상태 관리 계획**: 전역/로컬 상태 분류 및 관리 전략
    - **데이터 흐름 설계**: 컴포넌트 간 데이터 전달 방식

  - 3단계: 프로젝트 구조 설계
    프로젝트 구조 예시 
    ```
    src/
    ├── components/          # 범용 UI 컴포넌트
    │   ├── ui/              # 기본 UI 요소 (Button, Input 등)
    │   ├── layout/          # 레이아웃 컴포넌트
    │   └── common/          # 공통 컴포넌트
    ├── features/            # 비즈니스 로직별 모듈
    │   ├── auth/           # 인증 관련
    │   │   ├── components/
    │   │   ├── hooks/
    │   │   ├── services/
    │   │   ├── store/
    │   │   ├── types/
    │   │   └── index.ts
    │   ├── trip-search/    # 여행 검색
    │   ├── trip-detail/    # 여행 상세
    │   ├── itinerary/      # 일정 관리
    │   ├── booking/        # 예약 관리
    │   └── user/           # 사용자 관리
    ├── pages/              # 라우팅 페이지
    ├── hooks/              # 공통 커스텀 훅
    ├── services/           # 공통 API 서비스
    ├── store/              # 전역 상태 관리
    ├── utils/              # 유틸리티 함수
    ├── types/              # 공통 타입 정의
    ├── constants/          # 상수 관리
    ├── config/             # 설정 파일
    ├── lib/                # 외부 라이브러리 설정
    ├── styles/             # 글로벌 스타일
    ├── assets/             # 정적 리소스
    │   ├── images/
    │   ├── icons/
    │   └── fonts/
    └── __tests__/          # 테스트 파일
        ├── __mocks__/
        ├── utils/
        └── setup.ts
    ```
  - 4단계: 컴포넌트 설계 
    - **컴포넌트 트리 구조**: 계층적 컴포넌트 관계도
    - **Props 인터페이스 정의**: TypeScript 타입 명세
    - **컴포넌트 분류**:
      - Presentational Components: UI 표현 전용
      - Container Components: 비즈니스 로직 포함
      - Page Components: 라우팅 단위
    - **재사용성 고려**: 공통 컴포넌트 추출
  - 5단계: 상태관리 설계
    - **상태 관리 도구 선택**: Context API, Redux Toolkit, Zustand, Jotai
    - **상태 구조 설계**:
      예시)
      ```typescript
      interface AppState {
        user: UserState;
        trips: TripState;
        ui: UIState;
      }
      ```
    - **액션 및 리듀서 정의**: 상태 변경 로직
    - **비동기 처리 전략**: Redux-Saga, RTK Query, React Query
  - 6단계: API 통신 레이어 설계
    - **API 클라이언트 설정**: Axios 인터셉터, 에러 핸들링
    - **타입 세이프 API 호출**:
      예시)
      ```typescript
      interface ApiResponse<T> {
        data: T;
        status: number;
        message?: string;
      }
      ```
    - 백엔드API경로 정보: public/runtime-env.js파일에 생성함
      ```
      window.__runtime_config__ = { 
        GATEWAY_HOST: 'http://${gateway_host:localhost}', 
        API_GROUP: "/api/${version:v1}"
      }
      ```

    - **인증 처리**: JWT 토큰 관리, 자동 갱신
    - **에러 바운더리**: 전역 에러 처리 전략
  - 7단계: 라우팅 설계 
    - **라우터 구성**: React Router v6 설정
    - **보호된 라우트**: 인증 기반 접근 제어
    - **레이지 로딩**: 페이지를 필요할 때만 다운로드하기 위한 코드 스플리팅 전략
    - **네비게이션 가드**: 페이지를 떠나거나 이동할 때 조건을 확인하기 위한 전환 제어  
  - 8단계: 성능 최적화 계획
    - **번들 최적화**: Vite 설정, 청크 분할
    - **렌더링 최적화**:
      - React.memo, useMemo, useCallback 활용
      - 가상 스크롤링 (대량 데이터)
      - 이미지 레이지 로딩
    - **캐싱 전략**: React Query 캐시 정책
    - **Web Vitals 목표**: 
      - LCP(Large Contentful Paint): 가장 큰 콘텐츠가 화면에 나타나는 시간 2.5s 이하
      - FID(First Input Delay): 사용자 클릭에 대한 반응 시간 100ms 이하
      - CLS(Cumulative Layout Shift): 화면 밀림 현상 비율 10% 이하 
  
- 검토:
  - <설계원칙> 준수 검토
  - 스쿼드 팀원 리뷰: 누락 및 개선 사항 검토
  - 수정 사항 선택 및 반영

<병렬처리>
- **의존성 분석 선행**: 병렬 처리 전 반드시 의존성 파악
- **순차 처리 필요시**: 무리한 병렬화보다는 안전한 순차 처리
- **검증 단계 필수**: 병렬 처리 후 통합 검증

[참고자료]
- 유저스토리: ../{시스템}/design/userstory.md
- UI/UX설계서: ../{시스템}/design/uiux/uiux.md
- 스타일가이드: ../{시스템}/design/uiux/style-guide.md
- 프로토타입: ../{시스템}/design/uiux/prototype/*
- API명세서: ../{시스템}/design/backend/api/spec/*

[결과파일]
- 프론트엔드설계서: ../{시스템}/design/frontend/frontend-design.md

