# 물리 아키텍처 설계서 - 개발환경

## 1. 개요

### 1.1 설계 목적
- AI 기반 여행 일정 생성 서비스의 **개발환경** 물리 아키텍처 설계
- MVP 단계의 빠른 개발과 검증을 위한 최소 구성
- 비용 효율성과 개발 편의성 우선

### 1.2 설계 원칙
- **MVP 우선**: 빠른 개발과 검증을 위한 최소 구성
- **비용 최적화**: Spot Instances, Local Storage 활용
- **개발 편의성**: 복잡한 설정 최소화, 빠른 배포
- **단순성**: 운영 복잡도 최소화

### 1.3 참조 아키텍처
- 마스터 아키텍처: design/backend/physical/physical-architecture.md
- HighLevel아키텍처정의서: design/high-level-architecture.md
- 논리아키텍처: design/backend/logical/logical-architecture.md
- 배포아키텍처: design/backend/deployment/deployment-architecture-dev.md

## 2. 개발환경 아키텍처 개요

### 2.1 환경 특성
- **목적**: 빠른 개발과 검증
- **사용자**: 개발팀 (5명)
- **가용성**: 95% (월 36시간 다운타임 허용)
- **확장성**: 제한적 (고정 리소스)
- **보안**: 기본 보안 (복잡한 보안 설정 최소화)

### 2.2 전체 아키텍처

📄 **[개발환경 물리 아키텍처 다이어그램](./physical-architecture-dev.mmd)**

**주요 구성 요소:**
- NGINX Ingress Controller → AKS 기본 클러스터
- 애플리케이션 Pod: User, Trip, AI, Location Service
- 백킹서비스 Pod: PostgreSQL (Local Storage), Redis (Memory Only)
- Azure Service Bus Basic Tier 연결

## 3. 컴퓨팅 아키텍처

### 3.1 Azure Kubernetes Service (AKS) 구성

#### 3.1.1 클러스터 설정

| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| Kubernetes 버전 | 1.29 | 안정화된 최신 버전 |
| 서비스 계층 | Basic | 비용 최적화 |
| Network Plugin | Azure CNI | Azure 네이티브 네트워킹 |
| Network Policy | Kubernetes Network Policies | 기본 Pod 통신 제어 |
| Ingress Controller | NGINX Ingress Controller | 오픈소스 Ingress |
| DNS | CoreDNS | 클러스터 DNS |

#### 3.1.2 노드 풀 구성

| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| VM 크기 | Standard_B2s | 2 vCPU, 4GB RAM |
| 노드 수 | 2 | 고정 노드 수 |
| 자동 스케일링 | Disabled | 비용 절약을 위한 고정 크기 |
| 최대 Pod 수 | 30 | 노드당 최대 Pod |
| 가용 영역 | Zone-1 | 단일 영역 (비용 절약) |
| 가격 정책 | Spot Instance | 70% 비용 절약 |

### 3.2 서비스별 리소스 할당

#### 3.2.1 애플리케이션 서비스
| 서비스 | CPU Requests | Memory Requests | CPU Limits | Memory Limits | Replicas |
|--------|--------------|-----------------|------------|---------------|----------|
| User Service | 50m | 128Mi | 200m | 256Mi | 1 |
| Trip Service | 100m | 256Mi | 500m | 512Mi | 1 |
| AI Service | 200m | 512Mi | 1000m | 1Gi | 1 |
| Location Service | 50m | 128Mi | 200m | 256Mi | 1 |

#### 3.2.2 백킹 서비스
| 서비스 | CPU Requests | Memory Requests | CPU Limits | Memory Limits | Storage |
|--------|--------------|-----------------|------------|---------------|---------|
| PostgreSQL | 500m | 1Gi | 1000m | 2Gi | 20GB (hostPath) |
| Redis | 100m | 256Mi | 500m | 1Gi | Memory Only |

## 4. 네트워크 아키텍처

### 4.1 네트워크 구성

#### 4.1.1 네트워크 토폴로지

📄 **[개발환경 네트워크 다이어그램](./network-dev.mmd)**


#### 4.1.2 네트워크 보안

**기본 Network Policy:**
| 정책 유형 | 설정 | 설명 |
|-----------|------|---------|
| Default Policy | ALLOW_ALL_NAMESPACES | 개발 편의성을 위한 허용적 정책 |
| Complexity Level | Basic | 단순한 보안 구성 |

**Database 접근 제한:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 허용 대상 | Application Tier Pods | tier: application 레이블 |
| 프로토콜 | TCP | 데이터베이스 연결 |
| 포트 | 5432 | PostgreSQL 기본 포트 |

### 4.2 서비스 디스커버리

| 서비스 | 내부 주소 | 포트 | 용도 |
|--------|-----------|------|------|
| User Service | user-service.{namespace-name}.svc.cluster.local | 8080 | 사용자 관리 API |
| Trip Service | trip-service.{namespace-name}.svc.cluster.local | 8080 | 여행 계획 API |
| AI Service | ai-service.{namespace-name}.svc.cluster.local | 8080 | AI 일정 생성 API |
| Location Service | location-service.{namespace-name}.svc.cluster.local | 8080 | 위치 정보 API |
| PostgreSQL | postgresql.{namespace-name}.svc.cluster.local | 5432 | 메인 데이터베이스 |
| Redis | redis.{namespace-name}.svc.cluster.local | 6379 | 캐시 서버 |

## 5. 데이터 아키텍처

### 5.1 데이터베이스 구성

#### 5.1.1 PostgreSQL Pod 구성

**기본 설정:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 이미지 | bitnami/postgresql:16 | 안정화된 PostgreSQL 16 |
| CPU 요청 | 500m | 기본 CPU 할당 |
| Memory 요청 | 1Gi | 기본 메모리 할당 |
| CPU 제한 | 1000m | 최대 CPU 사용량 |
| Memory 제한 | 2Gi | 최대 메모리 사용량 |

**스토리지 설정:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 스토리지 타입 | hostPath | 로컬 스토리지 (비용 절약) |
| 스토리지 크기 | 20Gi | 개발용 충분한 용량 |
| 마운트 경로 | /data/postgresql | 데이터 저장 경로 |

**데이터베이스 설정:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 최대 연결 수 | 100 | 동시 연결 제한 |
| Shared Buffers | 256MB | 공유 버퍼 크기 |
| Effective Cache Size | 1GB | 효과적 캐시 크기 |
| 백업 전략 | 수동 백업 | 주 1회 수동 실행 |

#### 5.1.2 Redis Pod 구성

**기본 설정:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 이미지 | bitnami/redis:7.2 | 최신 안정 Redis 버전 |
| CPU 요청 | 100m | 기본 CPU 할당 |
| Memory 요청 | 256Mi | 기본 메모리 할당 |
| CPU 제한 | 500m | 최대 CPU 사용량 |
| Memory 제한 | 1Gi | 최대 메모리 사용량 |

**Redis 설정:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 데이터 지속성 | Disabled | 개발용, 재시작 시 데이터 손실 허용 |
| 최대 메모리 | 512MB | 메모리 사용 제한 |
| 메모리 정책 | allkeys-lru | LRU 방식 캐시 제거 |

### 5.2 데이터 관리 전략

#### 5.2.1 데이터 초기화

**데이터 초기화 시스템 개요:**
- 개발환경에서 즉시 테스트 가능한 데이터 셋 자동 구성
- Kubernetes Job 기반의 초기화 프로세스
- PostgreSQL Pod와 연계된 자동화된 데이터베이스 설정

##### 5.2.1.1 쿠버네티스 매니페스트 구조

```
k8s/data-init/
├── 01-configmap-init-scripts.yaml      # 초기화 SQL 스크립트
├── 02-configmap-sample-data.yaml       # 샘플 데이터 JSON
├── 03-secret-db-init-credentials.yaml  # 초기화용 DB 인증 정보
├── 04-job-database-init.yaml           # 데이터베이스 초기화 Job
├── 05-job-sample-data-load.yaml        # 샘플 데이터 로딩 Job
└── 06-service-monitor.yaml             # 초기화 상태 모니터링
```

##### 5.2.1.2 실행 프로세스

**단계별 초기화 흐름:**

```bash
# 1. 전체 초기화 실행
kubectl apply -f k8s/data-init/

# 2. 개별 초기화 단계 (필요시)
kubectl apply -f k8s/data-init/01-configmap-init-scripts.yaml
kubectl apply -f k8s/data-init/04-job-database-init.yaml
```

**Job 실행 순서:**
1. **Database Schema Job** (database-schema-init)
   - 테이블 스키마 생성
   - 인덱스 및 제약조건 설정
   - 기본 권한 설정

2. **Sample Data Job** (sample-data-load)
   - 테스트 사용자 데이터 삽입
   - 샘플 여행지 정보 로딩
   - AI 서비스 테스트 데이터 생성

3. **Validation Job** (data-validation)
   - 데이터 무결성 검증
   - 연결 테스트 수행

##### 5.2.1.3 초기화 데이터 상세 구성

**테스트 사용자 데이터:**
| 사용자 ID | 이름 | 권한 | 용도 | 샘플 여행 수 |
|-----------|------|------|------|-------------|
| admin | 관리자 | ADMIN | 전체 기능 테스트 | 5개 |
| testuser1 | 일반사용자1 | USER | 기본 기능 테스트 | 3개 |
| testuser2 | 일반사용자2 | USER | 다중 사용자 테스트 | 2개 |
| poweruser | 파워사용자 | POWER_USER | 고급 기능 테스트 | 7개 |

**샘플 여행지 데이터:**
| 지역 | 도시 수 | 관광지 수 | 카테고리 | 좌표 정확도 |
|------|---------|-----------|----------|-------------|
| 서울 | 25개 구 | 150개 | 문화/쇼핑/음식 | GPS 정확 |
| 부산 | 16개 구 | 80개 | 해양/문화/음식 | GPS 정확 |
| 제주 | 2개 시 | 100개 | 자연/레저/문화 | GPS 정확 |
| 해외 | 10개 도시 | 200개 | 종합 | GPS 정확 |

**AI 서비스 테스트 데이터:**
| 데이터 유형 | 샘플 수 | 용도 | 복잡도 |
|------------|---------|------|---------|
| 사용자 선호도 프로필 | 50개 | AI 추천 테스트 | 다양함 |
| 기존 여행 일정 템플릿 | 30개 | 일정 생성 학습 | 1-7일 |
| 리뷰 및 평점 데이터 | 500개 | 추천 시스템 훈련 | 1-5점 |
| 계절별 여행 패턴 | 12개월 | 시즌 추천 | 월별 |

##### 5.2.1.4 Job 실행 설정

**Database Schema Init Job:**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: database-schema-init
spec:
  backoffLimit: 3
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: postgres-client
        image: bitnami/postgresql:16
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
        env:
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-init-secret
              key: password
        command: ["/bin/bash"]
        args: 
        - -c
        - |
          echo "Starting database schema initialization..."
          psql -h postgresql.tripgen-dev.svc.cluster.local -U postgres -d tripgen -f /scripts/schema.sql
          echo "Schema initialization completed."
        volumeMounts:
        - name: init-scripts
          mountPath: /scripts
      volumes:
      - name: init-scripts
        configMap:
          name: database-init-scripts
```

**Sample Data Load Job:**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: sample-data-load
spec:
  backoffLimit: 3
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: data-loader
        image: bitnami/postgresql:16
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 512Mi
        env:
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-init-secret
              key: password
        command: ["/bin/bash"]
        args:
        - -c
        - |
          echo "Loading sample data..."
          psql -h postgresql.tripgen-dev.svc.cluster.local -U postgres -d tripgen -f /data/users.sql
          psql -h postgresql.tripgen-dev.svc.cluster.local -U postgres -d tripgen -f /data/locations.sql
          psql -h postgresql.tripgen-dev.svc.cluster.local -U postgres -d tripgen -f /data/ai-test-data.sql
          echo "Sample data loading completed."
        volumeMounts:
        - name: sample-data
          mountPath: /data
      volumes:
      - name: sample-data
        configMap:
          name: sample-data-scripts
```

##### 5.2.1.5 초기화 상태 모니터링

**초기화 상태 확인:**
```bash
# Job 실행 상태 확인
kubectl get jobs -n tripgen-dev

# Job 로그 확인
kubectl logs job/database-schema-init -n tripgen-dev
kubectl logs job/sample-data-load -n tripgen-dev

# 데이터 초기화 검증
kubectl exec -it postgresql-0 -n tripgen-dev -- psql -U postgres -d tripgen -c "SELECT COUNT(*) FROM users;"
```

**자동 검증 스크립트:**
```bash
#!/bin/bash
# data-validation.sh

echo "=== 데이터 초기화 검증 시작 ==="

# 1. 사용자 데이터 검증
USER_COUNT=$(kubectl exec postgresql-0 -n tripgen-dev -- psql -U postgres -d tripgen -t -c "SELECT COUNT(*) FROM users;")
echo "사용자 데이터: $USER_COUNT개"

# 2. 여행지 데이터 검증
LOCATION_COUNT=$(kubectl exec postgresql-0 -n tripgen-dev -- psql -U postgres -d tripgen -t -c "SELECT COUNT(*) FROM locations;")
echo "여행지 데이터: $LOCATION_COUNT개"

# 3. AI 테스트 데이터 검증
AI_DATA_COUNT=$(kubectl exec postgresql-0 -n tripgen-dev -- psql -U postgres -d tripgen -t -c "SELECT COUNT(*) FROM user_preferences;")
echo "AI 테스트 데이터: $AI_DATA_COUNT개"

echo "=== 검증 완료 ==="
```

##### 5.2.1.6 에러 처리 및 재시도 로직

**실패 시 대응 방안:**
| 실패 유형 | 원인 | 해결방안 | 재시도 정책 |
|-----------|------|----------|-------------|
| Job Timeout | 리소스 부족 | CPU/Memory 할당 증가 | 3회 재시도 |
| Connection Failed | PostgreSQL 미준비 | initContainer로 대기 로직 추가 | 5분 간격 재시도 |
| SQL Error | 스키마 충돌 | DROP/CREATE 스크립트 추가 | 수동 재시작 |
| Data Corruption | 불완전한 데이터 로딩 | 트랜잭션 단위 처리 | 전체 재실행 |

**재시도 및 복구 스크립트:**
```bash
# 초기화 실패시 정리 및 재실행
kubectl delete job database-schema-init sample-data-load -n tripgen-dev
kubectl exec postgresql-0 -n tripgen-dev -- psql -U postgres -d tripgen -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public;"
kubectl apply -f k8s/data-init/
```

#### 5.2.2 백업 전략

| 서비스 | 백업 방법 | 주기 | 보존 전략 | 참고사항 |
|--------|----------|------|-----------|----------|
| PostgreSQL | kubectl exec + pg_dump | 수동 (필요 시) | 로컬 파일 저장 | 개발용 데이터 수동 관리 |
| Redis | 없음 | - | 메모리 전용 | 재시작 시 캐시 재구성 |

## 6. 메시징 아키텍처

### 6.1 Azure Service Bus 구성

#### 6.1.1 Basic Tier 설정

**Service Bus 전체 설정:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 서비스 계층 | Basic | 비용 최적화 계층 |
| 네임스페이스 | sb-tripgen-dev | 개발환경 전용 |
| 최대 큐 크기 | 1GB | 전체 큐 사이즈 제한 |
| 메시지 TTL | 14일 | 메시지 생존 기간 |

**큐 별 설정:**
| 큐 이름 | 최대 크기 | 중복 감지 | 용도 |
|--------|----------|----------|------|
| ai-schedule-generation | 256MB | Disabled | AI 일정 생성 요청 |
| location-search | 256MB | Disabled | 위치 검색 요청 |
| notification | 256MB | Disabled | 알림 메시지 |

#### 6.1.2 연결 설정

| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 인증 방식 | Azure Managed Identity | 운영환경 대비 보안 강화 |
| 연결 풀링 | Disabled | 개발환경 단순 구성 |
| 재시도 정책 | Basic | 기본 재시도 설정 |

## 7. 보안 아키텍처

### 7.1 개발환경 보안 정책

#### 7.1.1 기본 보안 설정

**보안 계층 설정:**
| 계층 | 설정 | 수준 | 설명 |
|------|------|------|----------|
| 전체 복잡도 | Basic | 기본 | 개발 편의성 우선 |
| 인증 | JWT | 기본 | 개발용 고정 시크릿 |
| 인증 검증 | API Gateway | 단순 | Gateway 레벨만 검증 |
| 인가 | Role-based | 기본 | 단순한 역할 기반 |
| 내부 암호화 | Disabled | 없음 | 개발환경 단순화 |
| 외부 암호화 | HTTPS | Ingress | Ingress 레벨 HTTPS만 |

#### 7.1.2 시크릿 관리

**시크릿 관리 전략:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 관리 방식 | Kubernetes Secrets | 기본 K8s 에 내장된 방식 |
| 순환 정책 | 수동 | 개발환경 단순 관리 |
| 저장소 | etcd | 클러스터 기본 저장소 |

**관리 대상 시크릿:**
| 시크릿 이름 | 용도 | 순환 주기 |
|-------------|------|----------|
| database_password | PostgreSQL 접근 | 수동 |
| redis_password | Redis 접근 | 수동 |
| jwt_secret | JWT 토큰 서명 | 수동 |
| openai_api_key | OpenAI API 접근 | 수동 |

### 7.2 Network Policies

#### 7.2.1 기본 정책

**Network Policy 설정:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| Policy 이름 | dev-basic-policy | 개발환경 기본 정책 |
| API 버전 | networking.k8s.io/v1 | Kubernetes Network Policy v1 |
| Pod 선택자 | {} (전체) | 모든 Pod에 적용 |
| 정책 유형 | Ingress, Egress | 인바운드/아웃바운드 모두 제어 |
| Ingress 규칙 | {} (전체 허용) | 개발환경 편의상 모든 인바운드 허용 |
| Egress 규칙 | {} (전체 허용) | 모든 아웃바운드 허용 |

## 8. 모니터링 및 로깅

### 8.1 기본 모니터링

#### 8.1.1 Kubernetes 기본 모니터링

**모니터링 스택:**
| 구성요소 | 상태 | 설명 |
|-----------|------|----------|
| Metrics Server | Enabled | 기본 리소스 메트릭 수집 |
| Kubernetes Dashboard | Enabled | 개발용 대시보드 |

**기본 알림 설정:**
| 알림 유형 | 임계값 | 설명 |
|-----------|----------|----------|
| Pod Crash Loop | 5회 이상 | Pod 재시작 반복 감지 |
| Node Not Ready | 5분 이상 | 노드 비정상 상태 감지 |
| High Memory Usage | 90% 이상 | 메모리 사용량 과다 감지 |

#### 8.1.2 애플리케이션 모니터링

**헬스체크 설정:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| Health Check Path | /actuator/health | Spring Boot Actuator 엔드포인트 |
| 체크 주기 | 30초 | 상태 확인 간격 |
| 타임아웃 | 5초 | 응답 대기 시간 |

**수집 메트릭:**
| 메트릭 유형 | 도구 | 용도 |
|-----------|------|------|
| JVM Metrics | Micrometer | 자바 가상머신 성능 |
| HTTP Request Metrics | Micrometer | API 요청 통계 |
| Database Connection Pool | Micrometer | DB 연결 풀 상태 |

### 8.2 로깅

#### 8.2.1 로그 수집

**로그 수집 설정:**
| 설정 항목 | 값 | 설명 |
|-----------|----|---------|
| 수집 방식 | kubectl logs | Kubernetes 기본 로그 명령어 |
| 저장 방식 | 로컬 파일 시스템 | 노드 로컬 스토리지 |
| 보존 기간 | 7일 | 개발환경 단기 보존 |

**로그 레벨 설정:**
| 로거 유형 | 레벨 | 설명 |
|-----------|------|----------|
| Root Logger | INFO | 전체 시스템 기본 레벨 |
| Application Logger | DEBUG | 개발용 상세 로그 |
| Database Logger | WARN | 데이터베이스 주요 이벤트만 |

## 9. 배포 관련 컴포넌트

| 컴포넌트 유형 | 컴포넌트 | 설명 |
|--------------|----------|------|
| Container Registry | Azure Container Registry (Basic) | 개발용 이미지 저장소 (tripgendev.azurecr.io) |
| CI | GitHub Actions | 지속적 통합 파이프라인 |
| CD | ArgoCD | GitOps 패턴 지속적 배포, 자동 배포 |
| 패키지 관리 | Helm | Kubernetes 패키지 관리 도구 |
| 환경별 설정 | values-dev.yaml | 개발환경 Helm 설정 파일 |
| 서비스 계정 | AKS Service Account | ArgoCD 접근 권한 관리 |

## 10. 비용 최적화

### 10.1 개발환경 비용 구조

#### 10.1.1 주요 비용 요소
| 구성요소 | 사양 | 월간 예상 비용 (USD) | 절약 방안 |
|----------|------|---------------------|-----------|
| AKS 노드 | Standard_B2s × 2 | $120 | Spot Instance |
| PostgreSQL | Pod 기반 | $0 | 로컬 스토리지 |
| Redis | Pod 기반 | $0 | 메모리 전용 |
| Service Bus | Basic | $10 | 최소 구성 |
| Load Balancer | Basic | $20 | 단일 인스턴스 |
| **총합** | | **$150** | |

#### 10.1.2 비용 절약 전략

**컴퓨팅 비용 절약:**
| 절약 방안 | 절약률 | 설명 |
|-----------|----------|----------|
| Spot Instances 사용 | 70% | 예비 인스턴스 활용 |
| 비업무시간 자동 종료 | 반적 | 스케줄링 기반 종료 |
| 리소스 최적화 | 20-30% | requests/limits 정밀 설정 |

**스토리지 비용 절약:**
| 절약 방안 | 절약률 | 설명 |
|-----------|----------|----------|
| hostPath 사용 | 100% | Managed Disk 대비 완전 절약 |
| emptyDir 활용 | 100% | 임시 데이터 지역 저장소 |

**네트워킹 비용 절약:**
| 절약 방안 | 절약률 | 설명 |
|-----------|----------|----------|
| 단일 Load Balancer | 50% | 하나의 로드밸런서로 다중 서비스 |
| ClusterIP 활용 | 100% | 내부 통신 비용 없음 |

## 11. 개발환경 운영 가이드

### 11.1 일상 운영

#### 11.1.1 환경 시작/종료
```bash
# 환경 시작
kubectl scale deployment --replicas=1 --all

# 환경 종료 (야간/주말)
kubectl scale deployment --replicas=0 --all
# PostgreSQL은 유지 (데이터 보존)
```

#### 11.1.2 데이터 관리
```bash
# 테스트 데이터 초기화
kubectl apply -f k8s/data-init/

# 개발 데이터 백업
kubectl exec postgresql-0 -- pg_dump tripgen > backup.sql

# 데이터 복원
kubectl exec -i postgresql-0 -- psql tripgen < backup.sql
```

### 11.2 트러블슈팅

#### 11.2.1 일반적인 문제 해결

| 문제 유형 | 원인 | 해결방안 | 예방법 |
|-----------|------|----------|----------|
| Pod Pending | 리소스 부족 | 노드 스케일 업 또는 리소스 조정 | 리소스 모니터링 강화 |
| Database Connection Failed | PostgreSQL Pod 재시작 | Pod 상태 확인 및 재시작 | Health Check 강화 |
| Out of Memory | 메모리 한계 초과 | limits 조정 또는 불필요한 Pod 종료 | 메모리 사용량 모니터링 |

## 12. 개발환경 특성 요약

**핵심 설계 원칙**: 빠른 개발 > 비용 효율 > 단순성 > 실험성  
**주요 제약사항**: 95% 가용성, 제한적 확장성, 기본 보안 수준

이 개발환경은 **빠른 MVP 개발과 검증**에 최적화되어 있습니다.