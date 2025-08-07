# TripGen Message Queue 설치계획서 - 개발환경

## 1. 개요

### 1.1 문서 목적
TripGen 서비스의 개발환경에서 비동기 메시징 시스템 구축을 위한 Azure Service Bus 설치 계획 수립

### 1.2 적용 환경
- **대상 환경**: 개발환경 (Development)
- **서비스**: Azure Service Bus Basic Tier
- **용도**: AI 일정 생성, 장소 정보 처리, 경로 계산 등 비동기 작업 처리

### 1.3 관련 문서
- 외부시퀀스설계서: `design/backend/sequence/outer/*.puml`
- 물리아키텍처: `design/backend/physical/physical-architecture-dev.md`
- 백킹서비스설치방법: `references/백킹서비스설치방법.md`

## 2. 요구사항 분석

### 2.1 비동기 통신 요구사항

#### 2.1.1 식별된 비동기 처리 플로우

```mermaid
graph TB
    subgraph "Producer Services"
        TS[Trip Service]
        AI_P[AI Service]
        LS[Location Service]
        US[User Service]
    end
    
    subgraph "Message Queues"
        Q1[ai-schedule-generation]
        Q2[ai-schedule-regeneration]
        Q3[location-search]
        Q4[route-calculation]
        Q5[ai-recommendation]
        Q6[notification]
    end
    
    subgraph "Consumer Services"
        AI_C[AI Service]
        LSC[Location Service]
        NS[Notification Service]
    end
    
    TS -->|일정 생성 요청| Q1
    TS -->|재생성 요청| Q2
    AI_P -->|장소 정보 요청| Q3
    AI_P -->|경로 계산 요청| Q4
    LS -->|AI 추천 요청| Q5
    US -->|알림 발송| Q6
    
    Q1 -->|처리| AI_C
    Q2 -->|처리| AI_C
    Q3 -->|처리| LSC
    Q4 -->|처리| LSC
    Q5 -->|처리| AI_C
    Q6 -->|처리| NS
    
    AI_C -.->|완료 이벤트| TS
    LSC -.->|캐시 저장| Redis[(Redis Cache)]
```

| 플로우 | 큐/토픽 | 메시지 타입 | 처리 시간 | 우선순위 |
|--------|----------|-------------|-----------|----------|
| AI 일정 생성 | ai-schedule-generation | `{tripId, travelData, requestId}` | 5-10초 | 높음 |
| 장소 정보 요청 | location-search | `{destination, category, radius}` | 1-3초 | 중간 |
| 경로 계산 요청 | route-calculation | `{routes: [{from, to, mode}], tripId}` | 2-5초 | 중간 |
| 일정 재생성 | ai-schedule-regeneration | `{tripId, regenerateType, dayNumber?}` | 5-10초 | 높음 |
| **AI 추천정보 요청** | **ai-recommendation** | `{placeId, userProfile, tripContext}` | 2-5초 | 중간 |
| 알림 메시지 | notification | `{userId, type, message}` | < 1초 | 낮음 |

#### 2.1.2 서비스별 역할
- **Producer Services**: 
  - Trip Service: AI 일정 생성/재생성 요청
  - AI Service: 장소 정보 및 경로 계산 요청
  - Location Service: AI 추천정보 요청
  - User Service: 알림 발송
- **Consumer Services**: 
  - AI Service: 일정 생성, 재생성, 추천정보 처리
  - Location Service: 장소 검색, 경로 계산 처리
  - Notification Service: 알림 처리
- **이벤트 발행**: 일정 생성 완료, 재생성 완료, 장소/경로 정보 완료 이벤트

### 2.2 성능 요구사항
- **처리량**: 초당 10-50 메시지
- **메시지 크기**: 평균 32KB, 최대 64KB
- **지연 시간**: < 100ms (큐 처리 시간)
- **동시 처리**: 3-5개 워커 인스턴스

### 2.3 제약사항
- **비용 최적화**: Basic Tier 사용으로 비용 최소화
- **단순 구성**: 개발 효율성을 위한 복잡도 최소화
- **개발팀 규모**: 6명 개발자 + 2명 QA

## 3. Azure Service Bus 설치 계획

### 3.1 서비스 구성

#### 3.1.1 Service Bus Namespace
```yaml
namespace_configuration:
  name: sb-tripgen-dev
  tier: Basic
  location: Korea Central
  resource_group: tripgen-dev-rg
  
  capacity:
    max_size: 1GB
    message_ttl: 14일
    
  security:
    authentication: Connection String
    encryption: Default (Microsoft-managed keys)
```

#### 3.1.2 큐 설계
| 큐 이름 | 최대 크기 | 메시지 TTL | Lock Duration | Max Delivery | 용도 |
|---------|-----------|------------|---------------|--------------|------|
| ai-schedule-generation | 256MB | 1일 | 30초 | 3회 | AI 일정 생성 요청 |
| ai-schedule-regeneration | 128MB | 1일 | 30초 | 3회 | AI 일정 재생성 요청 |
| location-search | 128MB | 1시간 | 10초 | 3회 | 장소 정보 검색 |
| route-calculation | 128MB | 1시간 | 15초 | 3회 | 경로 계산 요청 |
| ai-recommendation | 128MB | 2시간 | 20초 | 3회 | AI 추천정보 생성 |
| notification | 128MB | 6시간 | 5초 | 3회 | 알림 메시지 |
| dead-letter | 128MB | 7일 | - | - | 실패 메시지 보관 |

### 3.2 연결 설정

#### 3.2.1 연결 구성
```yaml
connection_configuration:
  authentication:
    type: Connection String
    storage: Kubernetes Secret
    secret_name: servicebus-connection
    
  connection_pool:
    enabled: false  # 개발환경 단순화
    
  retry_policy:
    type: Exponential Backoff
    max_attempts: 3
    base_delay: 1초
    max_delay: 30초
    
  timeout:
    operation: 30초
    idle: 5분
```

#### 3.2.2 서비스별 연결 정보
| 서비스 | 역할 | 접근 큐 | 권한 |
|--------|------|---------|------|
| Trip Service | Producer | ai-schedule-generation, ai-schedule-regeneration | Send |
| AI Service | Producer/Consumer | ai-schedule-generation, ai-schedule-regeneration, location-search, route-calculation, ai-recommendation | Send, Receive |
| Location Service | Producer/Consumer | location-search, route-calculation, ai-recommendation | Send, Receive |
| User Service | Producer | notification | Send |

### 3.3 보안 설정

#### 3.3.1 인증 및 권한
```yaml
security_configuration:
  authentication:
    method: Shared Access Signature (SAS)
    policies:
      - name: RootManageSharedAccessKey
        rights: [Manage, Send, Listen]
      - name: SendOnlyKey
        rights: [Send]
      - name: ListenOnlyKey
        rights: [Listen]
        
  secret_management:
    storage: Kubernetes Secrets
    rotation: Manual (개발환경)
    
  network_security:
    public_access: Enabled (개발 편의성)
    ip_filtering: Disabled
```

### 3.4 모니터링 설정

#### 3.4.1 기본 모니터링
```yaml
monitoring_configuration:
  metrics:
    enabled: true
    retention: 7일
    
  alerts:
    - name: dead-letter-messages
      condition: DeadLetterMessageCount > 10
      severity: Warning
      
    - name: queue-size-alert
      condition: ActiveMessageCount > 1000
      severity: Warning
      
  logging:
    level: Information
    destination: Azure Monitor (Basic)
```

## 4. 설치 절차

### 4.1 사전 준비사항
- [ ] Azure 구독 및 리소스 그룹 확인
- [ ] Azure CLI 설치 및 로그인
- [ ] kubectl 및 Kubernetes 클러스터 접근 권한
- [ ] 환경 변수 설정 스크립트 준비

### 4.2 설치 스크립트

#### 4.2.1 환경 변수 설정
```bash
#!/bin/bash
# 환경 변수 설정
export TEAMID=tripgen
export RESOURCE_GROUP="tripgen-dev-rg"
export LOCATION="koreacentral"
export SB_NAMESPACE="sb-tripgen-dev"

# 큐 이름 정의
export QUEUE_AI_GEN="ai-schedule-generation"
export QUEUE_AI_REGEN="ai-schedule-regeneration"
export QUEUE_LOCATION="location-search"
export QUEUE_ROUTE="route-calculation"
export QUEUE_AI_REC="ai-recommendation"
export QUEUE_NOTIFY="notification"
export QUEUE_DLQ="dead-letter"
```

#### 4.2.2 Service Bus 생성
```bash
# Namespace 생성
az servicebus namespace create \
    --name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Basic

# 큐 생성
queues=($QUEUE_AI_GEN $QUEUE_AI_REGEN $QUEUE_LOCATION $QUEUE_ROUTE $QUEUE_AI_REC $QUEUE_NOTIFY $QUEUE_DLQ)
sizes=(256 128 128 128 128 128 128)

for i in "${!queues[@]}"; do
    az servicebus queue create \
        --name ${queues[$i]} \
        --namespace-name $SB_NAMESPACE \
        --resource-group $RESOURCE_GROUP \
        --max-size ${sizes[$i]}MB \
        --default-message-time-to-live P1D \
        --lock-duration PT30S \
        --max-delivery-count 3
done

# 연결 문자열 획득
CONNECTION_STRING=$(az servicebus namespace authorization-rule keys list \
    --name RootManageSharedAccessKey \
    --namespace-name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query primaryConnectionString -o tsv)
```

#### 4.2.3 Kubernetes Secret 생성
```bash
# Secret 생성
kubectl create secret generic servicebus-connection \
    --from-literal=connection-string="$CONNECTION_STRING" \
    --namespace tripgen-dev

# 확인
kubectl get secret servicebus-connection -n tripgen-dev
```

### 4.3 검증 절차

#### 4.3.1 연결 테스트
```bash
# Service Bus 상태 확인
az servicebus namespace show \
    --name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --query "provisioningState"

# 큐 목록 확인
az servicebus queue list \
    --namespace-name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --output table
```

#### 4.3.2 메시지 송수신 테스트
```python
# test_servicebus.py
from azure.servicebus import ServiceBusClient, ServiceBusMessage
import os

connection_string = os.environ['SERVICE_BUS_CONNECTION_STRING']
queue_name = "ai-schedule-generation"

# 메시지 전송 테스트
with ServiceBusClient.from_connection_string(connection_string) as client:
    sender = client.get_queue_sender(queue_name)
    message = ServiceBusMessage("Test message")
    sender.send_messages(message)
    print("Message sent successfully")
    
    # 메시지 수신 테스트
    receiver = client.get_queue_receiver(queue_name)
    messages = receiver.receive_messages(max_message_count=1, max_wait_time=5)
    for msg in messages:
        print(f"Received: {msg}")
        receiver.complete_message(msg)
```

## 5. 운영 가이드

### 5.1 일상 운영

#### 5.1.1 모니터링 체크리스트
- [ ] 큐별 메시지 수 확인 (일 2회)
- [ ] Dead Letter Queue 메시지 확인 (일 1회)
- [ ] 연결 오류 로그 확인 (일 1회)
- [ ] 큐 크기 사용률 확인 (주 1회)

#### 5.1.2 문제 해결 가이드
| 증상 | 원인 | 해결 방법 |
|------|------|-----------|
| 메시지 처리 지연 | 워커 부족 | 워커 인스턴스 증가 |
| Dead Letter 증가 | 처리 실패 | 에러 로그 분석 및 코드 수정 |
| 연결 실패 | 네트워크 문제 | 연결 문자열 확인, 재시도 |
| 큐 가득 참 | 소비 속도 부족 | 큐 크기 증가 또는 워커 추가 |

### 5.2 백업 및 복구

#### 5.2.1 백업 전략
- **연결 정보**: Git 외부 저장소에 암호화하여 보관
- **큐 설정**: Infrastructure as Code (Terraform/ARM Template)
- **메시지 백업**: 개발환경에서는 미지원 (Basic Tier 제한)

#### 5.2.2 재해 복구
```bash
# Service Bus 재생성 스크립트
./scripts/recreate-servicebus-dev.sh

# Kubernetes Secret 재생성
kubectl delete secret servicebus-connection -n tripgen-dev
kubectl create secret generic servicebus-connection \
    --from-literal=connection-string="$NEW_CONNECTION_STRING" \
    --namespace tripgen-dev

# 서비스 재시작
kubectl rollout restart deployment -n tripgen-dev
```

## 6. 비용 분석

### 6.1 월간 예상 비용
| 항목 | 사양 | 단가 | 월 비용 |
|------|------|------|---------|
| Service Bus Basic | 1백만 작업 | $0.05/백만 | $10 |
| 데이터 전송 | 10GB | Free (같은 리전) | $0 |
| **총 비용** | | | **$10/월** |

### 6.2 비용 최적화 방안
- Message TTL 적극 활용으로 불필요한 메시지 제거
- 개발/테스트 시간 외 큐 비우기
- 프로덕션 전환 시 Premium Tier 검토

## 7. 마이그레이션 고려사항

### 7.1 운영환경 전환 시
- Basic → Premium Tier 업그레이드
- Geo-replication 설정
- Private Endpoint 구성
- Managed Identity 전환
- 고급 모니터링 설정

### 7.2 확장 계획
- 토픽/구독 패턴 도입 (Standard/Premium)
- 파티셔닝 활성화 (Premium)
- Auto-forwarding 설정
- Session 기반 메시징

## 8. 체크리스트

### 8.1 설치 전 체크리스트
- [ ] Azure 구독 권한 확인
- [ ] 리소스 그룹 생성/확인
- [ ] 네트워크 설정 확인
- [ ] 비용 승인

### 8.2 설치 후 체크리스트
- [ ] Service Bus Namespace 생성 완료
- [ ] 모든 큐 생성 완료
- [ ] Kubernetes Secret 생성 완료
- [ ] 연결 테스트 성공
- [ ] 모니터링 설정 완료
- [ ] 문서화 완료

## 9. 참고사항

### 9.1 제한사항 (Basic Tier)
- 토픽/구독 미지원
- 최대 큐 크기: 1GB
- 중복 감지 미지원
- 세션 미지원
- Geo-replication 미지원

### 9.2 모범 사례
- 멱등성 보장을 위한 메시지 ID 활용
- Exponential Backoff 재시도 정책 적용
- Dead Letter Queue 적극 활용
- 메시지 크기 최소화 (압축 고려)
- 배치 처리로 성능 최적화

## 10. 승인 및 이력

### 10.1 문서 승인
- 작성자: 한데브옵스(클라우더) / DevOps Engineer
- 검토자: 김개발(테키) / Tech Lead
- 승인자: 이여행(트래블) / Product Owner
- 작성일: 2025-08-05

### 10.2 변경 이력
| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|-----------|--------|
| 1.0 | 2025-08-05 | 최초 작성 | 한데브옵스 |