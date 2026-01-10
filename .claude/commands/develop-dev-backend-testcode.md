---
description: 백엔드 테스트 코드 작성
command: "/develop-dev-backend-testcode"
---

@dev-backend
'백엔드테스트코드작성가이드'에 따라 테스트 코드를 작성해 주세요.

프롬프트에 '[개발정보]'항목이 없으면 수행을 중단하고 아래 안내 메시지를 표시해 주세요.
E2E테스트는 '테스트대상'을 지정하지 않아도 됩니다.

---
## 안내 메시지

백엔드 테스트 코드 작성을 위해 아래 형식으로 개발정보를 입력해 주세요.

**입력 형식:**
```
/develop-dev-backend-testcode

[개발정보]
- 서비스: {서비스명}
- 테스트유형: {단위테스트|통합테스트|E2E테스트}
- 테스트대상: {테스트할 클래스 또는 기능} (E2E테스트 시 생략 가능)
```

**예시 1 - 단위테스트:**
```
/develop-dev-backend-testcode

[개발정보]
- 서비스: user-service
- 테스트유형: 단위테스트
- 테스트대상: UserService 클래스
```

**예시 2 - E2E테스트:**
```
/develop-dev-backend-testcode

[개발정보]
- 서비스: user-service
- 테스트유형: E2E테스트
```

