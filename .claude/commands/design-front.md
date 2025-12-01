---
description: 프론트엔드 설계
---

@plan as @front
'프론트엔드설계가이드'를 준용하여 **프론트엔드설계서**를 작성해 주세요.
프롬프트에 '[백엔드시스템]'항목이 없으면 수행을 중단하고 안내 메시지를 표시합니다.
{안내메시지}
'[백엔드시스템]' 섹션에 아래 예와 같은 정보를 제공해 주십시오.
[백엔드시스템]
- 시스템: tripgen
- 마이크로서비스: user-service, location-service, trip-service, ai-service
- API문서
  - user service: http://localhost:8081/v3/api-docs
  - location service: http://localhost:8082/v3/api-docs
  - trip service: http://localhost:8083/v3/api-docs
  - ai service: http://localhost:8084/v3/api-docs
[요구사항]
- 각 화면에 Back 아이콘 버튼과 화면 타이틀 표시
- 하단 네비게이션 바 아이콘화: 홈, 새여행, 주변장소검색, 여행보기
