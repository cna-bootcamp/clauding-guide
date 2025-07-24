# 논리 아키텍처 설계 가이드

[요청사항]
- 참고자료를 기준으로 작성 
- 사용자 관점의 컴포넌트 다이어그램 작성
- Context Map 스타일로 서비스 내부 구조는 생략하고 서비스 간 관계에 집중
- 사용자 Flow를 note로 정리하고 처리순서별 번호 부여
- 클라이언트에서 API Gateway로는 단일 연결선으로 표현
- 서비스별 색상 구분으로 시각적 명확성 확보
- 서비스 간 의존성을 명확히 표현 (동기/비동기, 필수/선택적)
- **PlantUML 스크립트 파일 생성 즉시 검사 실행**: 'PlantUML 문법 검사  가이드' 준용 
[의존성 표현 방법]
- 실선 화살표(→): 동기적 의존성 (필수)
- 비동기 화살표(->>): 비동기 의존성 (fire-and-forget)
- 점선 화살표(-->): 선택적 의존성 또는 느슨한 결합
- 양방향 화살표(↔): 상호 의존성
- 의존성 레이블에 목적 명시 (예: "멤버 정보 조회")

[통신 전략]
- **동기 통신**: 즉시 응답이 필요한 단순 조회
- **캐시 우선**: 자주 사용되는 데이터는 캐시에서 직접 읽기
- **비동기 처리**: 외부 API 다중 호출 등 장시간 작업

[참고자료]
- 유저스토리: design/userstory.md
- UI/UX 설계서: design/uiux/uiux.md
- 아키텍처패턴: design/pattern/아키텍처패턴.puml

[예시]
- 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/samples/sample_논리아키텍처.puml

[결과파일]
- 논리아키텍처 설명: design/backend/logical/logical-architecture.md
- 논리아키텍처 다이어그램: design/backend/logical/logical-architecture.puml

