# 캐시 데이터베이스 설계서

## 데이터설계 요약

| 항목 | 내용 |
|------|------|
| 캐시 시스템 | Redis 7.x |
| 분리 방식 | Redis database 번호 (0~15) |
| 총 database 사용 | 4개 (DB 0~3) |
| Key Naming | `{domain}:{entity}:{id}` 형식 |

---

## 1. 개요

### 1.1 설계 목적
통신요금 관리 서비스의 마이크로서비스 아키텍처에서 각 서비스별 캐시 영역을 논리적으로 분리하여 데이터 격리와 효율적인 캐시 관리를 구현합니다.

### 1.2 설계 원칙
- **논리적 분리 방식**: Redis database 번호(0~15)를 사용하여 서비스별 캐시 영역 분리
- **공통 캐시 분리**: 여러 서비스가 공유하는 데이터는 별도의 공통 Redis database에 저장
- **격리 원칙**: 각 서비스는 자신에게 할당된 database만 접근하며, 타 서비스 database 직접 참조 금지

---

## 2. Redis Database 할당표

| Database | 서비스 | 용도 | 비고 |
|:--------:|--------|------|------|
| **DB 0** | 공통 영역 | 세션, 인증 토큰, 공유 설정 | Auth 서비스 주로 사용 |
| **DB 1** | Bill-Inquiry | 요금정보 캐시, 고객정보 캐시 | 요금조회 서비스 전용 |
| **DB 2** | Product-Change | 상품정보 캐시, 고객상품정보 캐시 | 상품변경 서비스 전용 |
| **DB 3** | KOS-Mock | Mock 데이터 캐시 | 개발/테스트 환경 전용 |
| **DB 4~14** | 예비 | 향후 서비스 확장용 | 미사용 |
| **DB 15** | 예비 | 긴급 백업/마이그레이션 | 미사용 |

---

## 3. 서비스별 캐시 설계

### 3.1 Auth 서비스 (DB 0)

#### 캐시 대상
| 캐시 키 패턴 | 설명 | TTL | 데이터 타입 |
|--------------|------|-----|-------------|
| `auth:session:{userId}` | 사용자 세션 정보 | 30분 | Hash |
| `auth:token:{sessionId}` | JWT 토큰 정보 | 24시간 | String |
| `auth:refresh:{userId}` | 리프레시 토큰 | 7일 | String |
| `auth:permissions:{userId}` | 사용자 권한 목록 | 1시간 | Set |
| `auth:failed:{userId}` | 로그인 실패 횟수 | 30분 | String |
| `auth:locked:{userId}` | 계정 잠금 상태 | 30분 | String |

#### 캐시 무효화 정책
- 로그아웃 시: `auth:session:{userId}`, `auth:token:{sessionId}` 삭제
- 권한 변경 시: `auth:permissions:{userId}` 삭제
- 계정 잠금/해제 시: `auth:locked:{userId}` 갱신

#### 설정 예시
```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      database: 0
```

---

### 3.2 Bill-Inquiry 서비스 (DB 1)

#### 캐시 대상
| 캐시 키 패턴 | 설명 | TTL | 데이터 타입 |
|--------------|------|-----|-------------|
| `bill:info:{lineNumber}:{inquiryMonth}` | 요금정보 | 4시간 | Hash |
| `bill:customer:{userId}` | 고객 기본정보 | 1시간 | Hash |
| `bill:available:months` | 조회 가능 월 목록 | 24시간 | List |
| `bill:history:{requestId}` | 요금조회 요청 상태 | 1시간 | Hash |

#### 캐시 무효화 정책
- 요금조회 완료 시: 해당 회선/월 캐시 갱신
- 고객정보 변경 시: `bill:customer:{userId}` 삭제

#### 설정 예시
```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      database: 1
```

---

### 3.3 Product-Change 서비스 (DB 2)

#### 캐시 대상
| 캐시 키 패턴 | 설명 | TTL | 데이터 타입 |
|--------------|------|-----|-------------|
| `product:customer:{lineNumber}` | 고객 상품정보 | 4시간 | Hash |
| `product:info:{productCode}` | 상품 정보 | 2시간 | Hash |
| `product:available:{operatorCode}` | 변경 가능 상품 목록 | 24시간 | List |
| `product:status:{lineNumber}` | 회선 상태 | 30분 | String |
| `product:history:{requestId}` | 상품변경 요청 상태 | 1시간 | Hash |

#### 캐시 무효화 정책
- 상품변경 완료 시: `product:customer:{lineNumber}`, `product:status:{lineNumber}` 삭제
- 상품정보 변경 시: `product:info:{productCode}` 삭제

#### 설정 예시
```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      database: 2
```

---

### 3.4 KOS-Mock 서비스 (DB 3)

#### 캐시 대상
| 캐시 키 패턴 | 설명 | TTL | 데이터 타입 |
|--------------|------|-----|-------------|
| `kos:customer:{lineNumber}` | Mock 고객정보 | 무제한 | Hash |
| `kos:product:{productCode}` | Mock 상품정보 | 무제한 | Hash |
| `kos:bill:{lineNumber}:{month}` | Mock 요금정보 | 무제한 | Hash |
| `kos:scenario:{scenarioId}` | Mock 시나리오 설정 | 무제한 | Hash |

#### 설정 예시
```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      database: 3
```

---

## 4. Key Naming Convention

### 4.1 명명 규칙
```
{서비스약어}:{엔티티}:{식별자}
```

### 4.2 서비스 약어
| 서비스 | 약어 |
|--------|------|
| Auth | `auth` |
| Bill-Inquiry | `bill` |
| Product-Change | `product` |
| KOS-Mock | `kos` |

### 4.3 예시
```
auth:session:user001          # Auth 서비스 세션 정보
bill:info:01012345678:2025-01 # Bill 서비스 요금 정보
product:customer:01012345678  # Product 서비스 고객 정보
kos:scenario:delay_500ms      # KOS Mock 시나리오
```

---

## 5. 주의사항

### 5.1 Redis Cluster 모드 사용 시
- Redis Cluster 모드에서는 **database 0만 사용 가능**
- Cluster 사용 시 Key Prefix 방식으로 전환 필요
  ```
  {auth}:session:user001
  {bill}:info:01012345678:2025-01
  {product}:customer:01012345678
  ```

### 5.2 공통 영역 데이터 접근
- 공통 영역(DB 0) 데이터가 필요한 경우에만 해당 database 접근 허용
- 공통 영역 데이터 변경 시 영향도 분석 필수

### 5.3 격리 원칙 준수
- 각 서비스는 자신에게 할당된 database만 접근
- 타 서비스 database 직접 참조 금지
- 서비스 간 데이터 공유가 필요한 경우 API 호출 또는 이벤트 기반 동기화 사용

---

## 6. 관련 문서

- **Auth 서비스 데이터 설계서**: [auth.md](./auth.md)
- **Bill-Inquiry 서비스 데이터 설계서**: [bill-inquiry.md](./bill-inquiry.md)
- **Product-Change 서비스 데이터 설계서**: [product-change.md](./product-change.md)
- **클래스 설계서**: [../class/package-structure.md](../class/package-structure.md)

---

**작성일**: 2025-12-26
**작성자**: 백엔더 (이개발)
