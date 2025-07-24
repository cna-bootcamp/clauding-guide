# 백킹 서비스 설치 방법
- [백킹 서비스 설치 방법](#백킹-서비스-설치-방법)
  - [1. Database 설치(VM)](#1-database-설치vm)
    - [1) Postgres](#1-postgres)
      - [1. PostgreSQL 14 저장소 추가](#1-postgresql-14-저장소-추가)
      - [2. 시스템 패키지 업데이트](#2-시스템-패키지-업데이트)
      - [3. PostgreSQL 14 설치](#3-postgresql-14-설치)
      - [4. PostgreSQL 서비스 상태 확인](#4-postgresql-서비스-상태-확인)
      - [5. PostgreSQL 설정 변경](#5-postgresql-설정-변경)
      - [6. 클라이언트 인증 설정](#6-클라이언트-인증-설정)
      - [7. PostgreSQL 서비스 재시작](#7-postgresql-서비스-재시작)
      - [8. postgres 사용자 비밀번호 설정](#8-postgres-사용자-비밀번호-설정)
      - [9. 정상설치 테스트](#9-정상설치-테스트)
      - [10. 외부 접근 허용](#10-외부-접근-허용)
      - [10. 필요한 DB 생성](#10-필요한-db-생성)
      - [11. DBeaver에서 접속](#11-dbeaver에서-접속)
      - [참고) Postgres 완전 삭제](#참고-postgres-완전-삭제)
    - [2) Redis](#2-redis)
      - [1. Ubuntu 패키지 업데이트](#1-ubuntu-패키지-업데이트)
      - [2. Redis 설치](#2-redis-설치)
      - [3. Redis 설정파일 수정](#3-redis-설정파일-수정)
      - [4. Redis 서비스 재시작](#4-redis-서비스-재시작)
      - [5. Redis 상태 확인](#5-redis-상태-확인)
      - [6. 외부 접근 허용 설정](#6-외부-접근-허용-설정)
      - [7. Redis 동작 테스트](#7-redis-동작-테스트)
  - [2. Database 설치(k8s Pod)](#2-database-설치k8s-pod)
    - [Bitnami helm registry 추가](#bitnami-helm-registry-추가)
    - [작업 디렉토리 생성](#작업-디렉토리-생성)
    - [Namespace 생성 및 이동](#namespace-생성-및-이동)
    - [1) MongoDB](#1-mongodb)
      - [작업 디렉토리 생성](#작업-디렉토리-생성-1)
      - [values.yaml 작성](#valuesyaml-작성)
      - [설치](#설치)
      - [외부 접속을 위한 service 생성](#외부-접속을-위한-service-생성)
      - [Service 객체 생성](#service-객체-생성)
      - [L/B IP 확인](#lb-ip-확인)
      - [로컬에서 접속 테스트](#로컬에서-접속-테스트)
    - [2) Postgres](#2-postgres)
      - [작업 디렉토리 생성](#작업-디렉토리-생성-2)
      - [values.yaml 작성](#valuesyaml-작성-1)
      - [namespace 생성(필요시)](#namespace-생성필요시)
      - [설치](#설치-1)
      - [외부 접속을 위한 service 생성](#외부-접속을-위한-service-생성-1)
      - [Service 객체 생성](#service-객체-생성-1)
      - [L/B IP 확인](#lb-ip-확인-1)
      - [로컬에서 접속 테스트](#로컬에서-접속-테스트-1)
    - [3) Redis](#3-redis)
      - [작업 디렉토리 생성](#작업-디렉토리-생성-3)
      - [values.yaml 작성](#valuesyaml-작성-2)
      - [설치](#설치-2)
      - [외부 접속을 위한 service 생성](#외부-접속을-위한-service-생성-2)
      - [Service 객체 생성](#service-객체-생성-2)
      - [L/B IP 확인](#lb-ip-확인-2)
      - [로컬에서 접속 테스트](#로컬에서-접속-테스트-2)
  - [3. MQ설치](#3-mq설치)
    - [※ Azure MQ 서비스 정보](#-azure-mq-서비스-정보)
    - [적합/부적합 사례](#적합부적합-사례)
    - [사전준비](#사전준비)
    - [1) Service Bus](#1-service-bus)
      - [※ 생성된 객체 삭제](#-생성된-객체-삭제)
    - [2) Event Hub](#2-event-hub)
      - [※ 생성된 객체 삭제](#-생성된-객체-삭제-1)
    - [3) EventGrid](#3-eventgrid)
      - [작업 디렉토리 생성](#작업-디렉토리-생성-4)
      - [Domain추가하기](#domain추가하기)
      - [실행파일로 전환](#실행파일로-전환)
      - [실행하여 도메인 {Team id}.4.217.249.140.nip.io 생성](#실행하여-도메인-team-id4217249140nipio-생성)
      - [웹브라우저에서 https연결 확인](#웹브라우저에서-https연결-확인)
      - [Event Grid Topic, Dead Letter 생성](#event-grid-topic-dead-letter-생성)
      - [Event Grid Subscriber 설정](#event-grid-subscriber-설정)
      - [Event Grid Subscriber 등록](#event-grid-subscriber-등록)
      - [※ EventGrid관련 객체 삭제](#-eventgrid관련-객체-삭제)
    - [4) RabbitMQ](#4-rabbitmq)
      - [작업 디렉토리 생성](#작업-디렉토리-생성-5)
      - [manifest 생성](#manifest-생성)
      - [설치](#설치-3)
      - [Admin 페이지 접속](#admin-페이지-접속)
    - [5) Kafka](#5-kafka)
      - [작업 디렉토리 생성](#작업-디렉토리-생성-6)
      - [values.yaml 작성](#valuesyaml-작성-3)
      - [설치](#설치-4)
      - [Kafka web console 파드를 실행](#kafka-web-console-파드를-실행)
      - [객체 생성](#객체-생성)
      - [L/B IP 확인](#lb-ip-확인-3)
      - [접속 테스트](#접속-테스트)
  - [4. Azure Blob Storage 설치](#4-azure-blob-storage-설치)

---

## 1. Database 설치(VM)

VM을 먼저 만드셔야 합니다. 아래 링크를 참고하세요.

**VM작성**  
https://github.com/cna-bootcamp/handson-azure/blob/main/prepare/setup-server.md#bastion-vm-%EC%83%9D%EC%84%B1

**MobaXTerm 세션 작성 및 접속**  
https://github.com/cna-bootcamp/handson-azure/blob/main/prepare/setup-server.md#mobaxterm-%EC%84%B8%EC%85%98-%EC%9E%91%EC%84%B1

### 1) Postgres

#### 1. PostgreSQL 14 저장소 추가
```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```

#### 2. 시스템 패키지 업데이트
```bash
sudo apt update
```

#### 3. PostgreSQL 14 설치
```bash
sudo apt install -y postgresql-14
```

#### 4. PostgreSQL 서비스 상태 확인
```bash
sudo systemctl status postgresql
```

결과 예시:
```
azureuser@bastion-ondal:~/stress$ sudo systemctl status postgresql
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
     Active: active (exited) since Tue 2025-01-07 10:11:52 KST; 11s ago
   Main PID: 12198 (code=exited, status=0/SUCCESS)
        CPU: 1ms

Jan 07 10:11:52 bastion-ondal systemd[1]: Starting PostgreSQL RDBMS...
Jan 07 10:11:52 bastion-ondal systemd[1]: Finished PostgreSQL RDBMS.
```

#### 5. PostgreSQL 설정 변경
```bash
sudo vi /etc/postgresql/14/main/postgresql.conf
```

주석을 풀고 아래 설정 변경:
```
# 외부 접속을 위한 설정 변경
listen_addresses = '*'
```

#### 6. 클라이언트 인증 설정
```bash
sudo vi /etc/postgresql/14/main/pg_hba.conf
```

맨 아래에 추가:
```
# IPv4 원격 접속 허용 추가 
host    all             all             0.0.0.0/0               md5
```

#### 7. PostgreSQL 서비스 재시작
```bash
sudo systemctl restart postgresql
```

#### 8. postgres 사용자 비밀번호 설정
비밀번호는 복잡하게 작성:
```bash
sudo -u postgres psql
postgres=# ALTER USER postgres PASSWORD 'Hi5Jessica!';
postgres=# \q
```

#### 9. 정상설치 테스트
정상적으로 설치되었는지 테스트하려면 다음 명령어를 사용할 수 있습니다:
```bash
psql -h localhost -U postgres -d postgres
```

#### 10. 외부 접근 허용
**포트 개방:**
```bash
sudo ufw allow 5432/tcp
```

**VM의 NSG(Network Security Group) 찾기:**
```bash
az network nsg list -o table
```

**PostgreSQL 포트(5432)에 대한 인바운드 규칙 추가:**
```bash
az network nsg rule create \
  --resource-group tiu-dgga-rg \
  --nsg-name {NSG} \
  --name Allow-PostgreSQL \
  --priority 1001 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-port-ranges 5432 \
  --protocol Tcp \
  --access Allow
```

예시:
```bash
az network nsg rule create \
  --resource-group tiu-dgga-rg \
  --nsg-name bastion-ondalNSG \
  --name Allow-PostgreSQL \
  --priority 1001 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-port-ranges 5432 \
  --protocol Tcp \
  --access Allow
```

#### 10. 필요한 DB 생성
**PostgreSQL 서버에 접속:**
```bash
sudo -u postgres psql
```

**데이터베이스 생성**  
아래는 'telecomdb' 생성 예시:
```sql
CREATE DATABASE telecomdb;
```

아래는 telecomdb를 user 'postgres'에 권한 부여하는 예시:
```sql
GRANT ALL PRIVILEGES ON DATABASE telecomdb TO postgres;
```

**PostgreSQL 접속 종료:**
```sql
\q
```

**데이터베이스 생성 확인:**
```bash
psql -h localhost -U postgres -d telecomdb
```

#### 11. DBeaver에서 접속
Database는 위에서

**VM IP 구하기:**
```bash
curl ifconfig.me
```

**DBeaver connection profile 생성:**
- Host: VM IP
- Port: 5432
- Database: postgres
- Username: postgres
- Password: Hi5Jessica!

* Connection profile에서 Database 옆에 'Show all database' 체크

#### 참고) Postgres 완전 삭제
```bash
# PostgreSQL 서비스 중지
sudo systemctl stop postgresql

# PostgreSQL 패키지와 의존성 패키지 모두 제거
sudo apt-get remove --purge postgresql*

# 설정 파일과 데이터 디렉토리 삭제
sudo rm -rf /etc/postgresql/
sudo rm -rf /var/lib/postgresql/
sudo rm -rf /var/log/postgresql/

# postgres 시스템 사용자 삭제
sudo userdel -r postgres

# 설치 저장소 제거
sudo rm /etc/apt/sources.list.d/pgdg.list
sudo rm /etc/apt/trusted.gpg.d/postgresql.gpg

# apt 캐시 정리
sudo apt update
```

### 2) Redis

Redis를 VM에 설치하는 상세한 방법을 안내해드리겠습니다:

#### 1. Ubuntu 패키지 업데이트
```bash
sudo apt update
sudo apt upgrade
```

#### 2. Redis 설치
```bash
sudo apt install redis-server
```

#### 3. Redis 설정파일 수정
```bash
sudo vi /etc/redis/redis.conf
```

주요 설정 변경사항:
```
# 외부 접속 허용을 위해 bind 주소 변경
bind 0.0.0.0

# 패스워드 설정 (보안을 위해 반드시 설정)
requirepass Hi5Jessica!

# 최대 메모리 설정 (시스템 메모리의 약 75% 권장)
maxmemory 1gb

# 메모리 정책 설정
maxmemory-policy allkeys-lru
```

#### 4. Redis 서비스 재시작
```bash
sudo systemctl restart redis-server
```

#### 5. Redis 상태 확인
```bash
sudo systemctl status redis-server
```

#### 6. 외부 접근 허용 설정
**방화벽 설정 (Redis 기본 포트 6379 오픈):**
```bash
sudo ufw allow 6379
```

**VM의 NSG(Network Security Group) 찾기:**
```bash
az network nsg list -o table
```

**Redis 포트(6379)에 대한 인바운드 규칙 추가**  
{NSG}는 본인 것으로 변경해야 합니다:
```bash
az network nsg rule create \
  --resource-group tiu-dgga-rg \
  --nsg-name {NSG} \
  --name Allow-Redis \
  --priority 1002 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-port-ranges 6379 \
  --protocol Tcp \
  --access Allow
```

#### 7. Redis 동작 테스트
```bash
redis-cli
> auth your_password
> set test "Hello Redis"
> get test
```

문제가 발생하면 로그를 확인하세요:
```bash
sudo tail -f /var/log/redis/redis-server.log
```

---

## 2. Database 설치(k8s Pod)

사전에 아래 링크를 참조하여 **AKS, ACR**을 만드세요.  
https://github.com/cna-bootcamp/handson-azure/blob/main/prepare/setup-server.md#aksacr-%EC%83%9D%EC%84%B1-%EC%82%AD%EC%A0%9C

주요 Database를 AKS에 설치하는 방법을 가이드합니다.  
Local Ubuntu 또는 Bastion VM에 로그인하여 작업하십시오.

### Bitnami helm registry 추가
```bash
helm repo ls
# 없으면 추가
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### 작업 디렉토리 생성
```bash
mkdir -p ~/install && cd ~/install
```

### Namespace 생성 및 이동
```bash
k create ns {team id}-ns
kubens {team id}-ns
```

### 1) MongoDB

#### 작업 디렉토리 생성
```bash
mkdir -p ~/install/mongodb && cd ~/install/mongodb
```

#### values.yaml 작성
실습 시에는 architecture를 'standalone'으로 지정해서 Pod를 1개만 생성하세요.

```yaml
# MongoDB 아키텍처 설정
architecture: replicaset
replicaCount: 3

# 인증 설정
auth:
  enabled: true
  rootUser: root
  rootPassword: "Hi5Jessica!"
  database: "telecomdb"
  username: "telecomuser"
  password: "Hi5Jessica!"
  replicaSetKey: "Hi5Jessica!"

# 리소스 설정
resources:
  limits:
    cpu: 1
    memory: 2Gi
  requests:
    cpu: 0.5
    memory: 1Gi

# 스토리지 설정 
persistence:
  enabled: true
  storageClass: "managed"
  size: 10Gi

# 성능 최적화 설정
extraEnvVars:
  - name: MONGODB_DISABLE_SYSTEM_LOG
    value: "false"
  - name: MONGODB_ENABLE_DIRECTORY_PER_DB
    value: "true"

# MongoDB 설정 최적화
extraFlags:
  - "--wiredTigerCacheSizeGB=2"
  - "--maxConns=100"

# 네트워크 설정
service:
  type: ClusterIP
  ports:
    mongodb: 27017

# Pod 안정성 설정
affinity: 
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: mongodb
              app.kubernetes.io/instance: mongodb
          topologyKey: kubernetes.io/hostname

# 보안 설정
containerSecurityContext:
  enabled: true
  runAsUser: 1001
  runAsNonRoot: true

# 리소스 모니터링
livenessProbe:
  enabled: true
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
  successThreshold: 1

readinessProbe:
  enabled: true
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 6
  successThreshold: 1
```

#### 설치
```bash
helm upgrade -i mongo -f values.yaml bitnami/mongodb --version 14.3.2
```

아래 명령으로 모든 pod가 실행될때까지 기다렸다가, CTRL-C로 중지:
```bash
watch kubectl get po
```

#### 외부 접속을 위한 service 생성
mongo-external.yaml 작성:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongo-external
spec:
  type: LoadBalancer
  ports:
    - name: mongodb
      port: 27017
      targetPort: 27017
  selector:
    app.kubernetes.io/component: mongodb
    app.kubernetes.io/name: mongodb
```

#### Service 객체 생성
```bash
k apply -f mongo-external.yaml
```

#### L/B IP 확인
```bash
k get svc
```

#### 로컬에서 접속 테스트
아래 사이트에서 Compass 설치:  
https://www.mongodb.com/try/download/compass

실행 후 아래와 같이 연결 문자열 입력하여 연결. IP는 위 service의 L/B IP로 바꿔야 함:
```
mongodb://root:Hi5Jessica!@20.249.187.207:27017/?directConnection=true&authSource=admin
```
![](images/2025-07-23-19-43-12.png)

![](images/2025-07-23-19-44-02.png) 

### 2) Postgres

#### 작업 디렉토리 생성
```bash
mkdir -p ~/install/postgres && cd ~/install/postgres
```

#### values.yaml 작성
실습 시에는 architecture를 'standalone'으로 지정해서 Pod를 1개만 생성하세요.

```yaml
# PostgreSQL 아키텍처 설정
architecture: replication

# 글로벌 설정
global:
  postgresql:
    auth:
      postgresPassword: "Hi5Jessica!"
      replicationPassword: "Hi5Jessica!" 
      database: "telecomdb"
      username: "telecomuser"
      password: "Hi5Jessica!"
  storageClass: "managed-premium"
  
# Primary 설정
primary:
  persistence:
    enabled: true
    storageClass: "managed-premium"
    size: 10Gi
  
  resources:
    limits:
      memory: "4Gi"
      cpu: "1"
    requests:
      memory: "2Gi"
      cpu: "0.5"
  
  # 성능 최적화 설정  
  extraEnvVars:
    - name: POSTGRESQL_SHARED_BUFFERS
      value: "1GB"
    - name: POSTGRESQL_EFFECTIVE_CACHE_SIZE  
      value: "3GB"
    - name: POSTGRESQL_MAX_CONNECTIONS
      value: "200"
    - name: POSTGRESQL_WORK_MEM
      value: "16MB"
    - name: POSTGRESQL_MAINTENANCE_WORK_MEM
      value: "256MB"

  # 고가용성 설정
  podAntiAffinityPreset: soft
  
# Secondary 설정  
readReplicas:
  replicaCount: 2
 
  persistence:
    enabled: true
    storageClass: "managed-premium"
    size: 10Gi

  resources:
    limits:
      memory: "2Gi"
      cpu: "1"
    requests:
      memory: "1Gi" 
      cpu: "0.5"

  # 성능 최적화 설정  
  extraEnvVars:
    - name: POSTGRESQL_SHARED_BUFFERS
      value: "1GB"
    - name: POSTGRESQL_EFFECTIVE_CACHE_SIZE
      value: "3GB"
    - name: POSTGRESQL_MAX_CONNECTIONS  
      value: "200"
    - name: POSTGRESQL_WORK_MEM
      value: "16MB"
    - name: POSTGRESQL_MAINTENANCE_WORK_MEM  
      value: "256MB"

  # 고가용성 설정
  podAntiAffinityPreset: soft

# 네트워크 설정
service:
  type: ClusterIP
  ports:
    postgresql: 5432

# 보안 설정
securityContext:
  enabled: true
  fsGroup: 1001
  runAsUser: 1001
```

#### namespace 생성(필요시)
```bash
k create ns {namespace}
kubens {namespace}
```

#### 설치
```bash
helm upgrade -i postgres -f values.yaml bitnami/postgresql --version 14.3.2
```

아래 명령으로 모든 pod가 실행될때까지 기다렸다가, CTRL-C로 중지:
```bash
watch kubectl get po
```

#### 외부 접속을 위한 service 생성
postgres-external.yaml 작성:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-external
spec:
  ports:
  - name: tcp-postgresql
    port: 5432
    protocol: TCP
    targetPort: tcp-postgresql
  selector:
    app.kubernetes.io/component: primary
    app.kubernetes.io/instance: postgres
    app.kubernetes.io/name: postgresql
  sessionAffinity: None
  type: LoadBalancer
```

#### Service 객체 생성
```bash
k apply -f postgres-external.yaml
```

#### L/B IP 확인
```bash
k get svc
```

#### 로컬에서 접속 테스트
DBeaver를 실행하고 Postgres용 연결 설정 파일을 만들어 테스트합니다.  
Host는 위 service 객체의 L/B IP이고, id와 pw는 values.yaml에 지정한 값을 사용합니다.
![](images/2025-07-23-19-45-30.png)

### 3) Redis

#### 작업 디렉토리 생성
```bash
mkdir -p ~/install/redis && cd ~/install/redis
```

#### values.yaml 작성
실습 시에는 architecture를 'standalone'으로 지정해서 Pod를 1개만 생성하세요.

```yaml
architecture: replication

auth:
  enabled: true
  password: "Hi5Jessica!"

master:
  persistence:
    enabled: true
    storageClass: "managed"
    size: 10Gi

  configuration: |
    maxmemory 1610612736
    maxmemory-policy allkeys-lru
    appendonly yes
    appendfsync everysec
    save 900 1 300 10 60 10000
    
  resources:
    limits:
      memory: "2Gi"
      cpu: "1"
    requests:
      memory: "1Gi"
      cpu: "0.5"
     
replica:
  replicaCount: 2
  persistence:
    enabled: true
    storageClass: "managed"
    size: 10Gi
  configuration: |
    maxmemory 1610612736
    maxmemory-policy allkeys-lru   
  resources:
    limits:
      memory: "2Gi" 
      cpu: "1"
    requests:
      memory: "1Gi"
      cpu: "0.5"

sentinel:
  enabled: true
  quorum: 2
 
service:
  type: ClusterIP
  ports:
    redis: 6379

podAntiAffinityPreset: soft

securityContext:
  enabled: true
  fsGroup: 1001
  runAsUser: 1001
```

#### 설치
```bash
helm upgrade -i redis -f values.yaml bitnami/redis --version 18.4.0
```

아래 명령으로 모든 pod가 실행될때까지 기다렸다가, CTRL-C로 중지:
```bash
watch kubectl get po
```

#### 외부 접속을 위한 service 생성
redis-external.yaml 작성:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-external
spec:
  ports:
  - name: tcp-redis
    port: 6379
    protocol: TCP
    targetPort: redis
  - name: tcp-sentinel
    port: 26379
    protocol: TCP
    targetPort: redis-sentinel
  publishNotReadyAddresses: true
  selector:
    app.kubernetes.io/instance: redis
    app.kubernetes.io/name: redis
  sessionAffinity: None
  type: LoadBalancer
```

#### Service 객체 생성
```bash
k apply -f redis-external.yaml
```

#### L/B IP 확인
```bash
k get svc
```

#### 로컬에서 접속 테스트
아래 사이트에서 redis insight를 다운로드하여 설치합니다:  
https://redis.io/insight/

아래와 같이 셋팅하고 연결 테스트를 합니다.  
IP는 위에서 생성한 L/B IP이고, 암호는 values.yaml에 지정한 값입니다:
```
redis://:Password@20.249.200.253:6379
```
![](images/2025-07-23-19-46-00.png) 

---

## 3. MQ설치

### ※ Azure MQ 서비스 정보

| 비교 요소 | Service Bus | Event Hubs(Kafka기반) | Event Grid |
|----------|-------------|----------------------|------------|
| 주요 용도 | 엔터프라이즈 메시징 | 빅데이터 스트리밍 | 이벤트 라우팅 |
| Consumer 수 | 1:1 또는 경쟁 소비자 | 파티션당 1개 Consumer Group | 1:N(무제한) |
| 최대 메시지 크기 | 100MB (Premium) | 1MB | 1MB |
| 순서 보장 | 완벽한 FIFO | 파티션 내 보장 | 미보장 |
| 중복 전달 | Exactly-once<br>중복 전달 없음 | At-least-once<br>중복 전달 가능 | At-least-once<br>중복 전달 가능 |
| 처리량 | 중 | 상 | 중 |
| 지연 시간 | 낮음 (~ms) | 매우 낮음 (< ms) | 매우 낮음 (< ms) |
| 메시지 필터링 | 지원 | 미지원 | 지원 |
| 부하 분산 | 내장 | 파티션 기반 | 자동 |
| 상대적 비용 | 상 | 중 | 하 |
| 적합 사례 | • 금융 거래<br>• 주문 처리<br>• 재고 관리 | • IoT 데이터<br>• 실시간 분석<br>• 로그 수집 | • 이벤트 브로드캐스팅(1:N)<br>• 서버리스 아키텍처<br>• 서비스 통합 |
| 부적합 사례 | • 대용량 스트리밍<br>• 브로드캐스팅<br>• 실시간 모니터링 | • 정확한 순서 필요<br>• 개별 메시지 처리<br>• 메시지 필터링 | • 대용량 스트리밍<br>• 순서 보장 필요<br>• 장기 재시도 필요 |

### 적합/부적합 사례

| MQ | 적합 | 부적합 |
|----|------|--------|
| Service Bus | ✓ 순서가 중요하고 중복되면 안 되는 경우<br>&nbsp;&nbsp;&nbsp;(예: 은행 입출금)<br>✓ 안전하게 처리해야 하는 경우<br>&nbsp;&nbsp;&nbsp;(예: 쇼핑몰 주문/결제)<br>✓ 처리상태를 추적해야 하는 경우<br>&nbsp;&nbsp;&nbsp;(예: 택배 배송상태)<br>✓ 실패하면 다시 시도해야 하는 중요한 업무 | ✗ 실시간 영상/데이터를 처리하는 경우<br>&nbsp;&nbsp;&nbsp;(예: 유튜브)<br>✗ 여러 사람에게 동시에 보내야 하는 경우<br>&nbsp;&nbsp;&nbsp;(예: 카톡)<br>✗ 초당 수천 건 이상 처리해야 하는 경우 |
| Event Hub | ✓ 스마트폰/IoT 기기의 실시간 데이터 수집<br>✓ 서버/앱의 로그를 실시간으로 수집하는 경우<br>✓ 실시간 차트/그래프를 그려야 하는 경우<br>✓ 초당 수천~수만 건을 빠르게 처리해야 하는 경우 | ✗ 송금처럼 순서가 중요한 거래<br>✗ 택배처럼 개별 메시지를 추적해야 하는 경우<br>✗ 특정 메시지만 골라서 처리해야 하는 경우 |
| Event Grid | ✓ 여러 시스템에 동시에 알림/푸시<br>✓ 마이크로서비스 간 1:N 이벤트 전달 | ✗ 대용량 파일/데이터 전송<br>✗ 순서대로 처리해야 하는 경우<br>✗ 실패한 메시지를 다시 처리해야 하는 경우<br>✗ 복잡한 조건으로 메시지를 분류 |

### 사전준비
- TEAM ID 정하기
- Resource Group 확인: `az group list -o table`로 확인
- Location: 위 리소스 그룹 확인 시 같이 확인

### 1) Service Bus

TEAMID, Topic명(usage, notify)을 적절히 변경:

```bash
export TEAMID=unicorn
export RESOURCE_GROUP="tiu-dgga-rg"
export LOCATION="koreacentral"
export SB_NAMESPACE="sb-${NAME}"
export DEADLETTER_TOPIC="deadletter-topic"
export SB_TOPIC1="usage"
export SB_TOPIC2="notify"
export SB_SUB1="sync-sub"
export SB_SUB2="notification-sub"
export MAX_RETRY=3

# Namespace 생성
if ! az servicebus namespace show --name $SB_NAMESPACE -g $RESOURCE_GROUP &>/dev/null; then
   az servicebus namespace create \
       --name $SB_NAMESPACE \
       --resource-group $RESOURCE_GROUP \
       --location $LOCATION \
       --sku Standard
   check_error "Service Bus Namespace 생성 실패"
fi

# Topic 생성
for topic in $SB_TOPIC1 $SB_TOPIC2; do
   if ! az servicebus topic show --name $topic --namespace $SB_NAMESPACE -g $RESOURCE_GROUP &>/dev/null; then
       az servicebus topic create \
           --name $topic \
           --namespace $SB_NAMESPACE \
           --resource-group $RESOURCE_GROUP
       check_error "Topic $topic 생성 실패"
   fi
done

# Dead Letter Queue용 Topic 생성
az servicebus topic create \
    --name $DEADLETTER_TOPIC \
    --namespace $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP

# Subscription 생성
az servicebus topic subscription create \
   --name $SB_SUB1 \
   --namespace $SB_NAMESPACE \
   --resource-group $RESOURCE_GROUP \
   --topic-name $SB_TOPIC1
   --forward-deadlettered-messages-to $DEADLETTER_TOPIC \
   --enable-dead-lettering-on-message-expiration true \
   --max-delivery-count $MAX_RETRY

az servicebus topic subscription create \
   --name $SB_SUB2 \
   --namespace $SB_NAMESPACE \
   --resource-group $RESOURCE_GROUP \
   --topic-name $SB_TOPIC1
   --forward-deadlettered-messages-to $DEADLETTER_TOPIC \
   --enable-dead-lettering-on-message-expiration true \
   --max-delivery-count $MAX_RETRY

# Connection String 가져오기
SB_CONNECTION_STRING=$(az servicebus namespace authorization-rule keys list \
   --name RootManageSharedAccessKey \
   --namespace $SB_NAMESPACE \
   --resource-group $RESOURCE_GROUP \
   --query primaryConnectionString -o tsv)

# display result
echo "connection string => $SB_CONNECTION_STRING"
echo "Topic1 => $SB_TOPIC1"
echo "Topic2 => $SB_TOPIC2"
echo "DEAD LETTER Topic => $DEADLETTER_TOPIC"
echo "Sub1 => $SB_SUB1"
echo "Sub22 => $SB_SUB2"
```

#### ※ 생성된 객체 삭제
```bash
# Subscription 삭제
az servicebus topic subscription delete \
    --name $SB_SUB1 \
    --namespace-name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --topic-name $SB_TOPIC1 \
    2>/dev/null || true

az servicebus topic subscription delete \
    --name $SB_SUB2 \
    --namespace-name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    --topic-name $SB_TOPIC2 \
    2>/dev/null || true

# Topic 삭제
az servicebus topic delete \
    --name $SB_TOPIC1 \
    --namespace-name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    2>/dev/null || true

az servicebus topic delete \
    --name $SB_TOPIC2 \
    --namespace-name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    2>/dev/null || true

az servicebus topic delete \
    --name $DEADLETTER_TOPIC \
    --namespace-name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    2>/dev/null || true

# Namespace 삭제
az servicebus namespace delete \
    --name $SB_NAMESPACE \
    --resource-group $RESOURCE_GROUP \
    2>/dev/null || true
```

### 2) Event Hub

TEAMID, STORAGEID, EVENTHUB_NS, EVENTHUB_NAME을 적절히 변경.  
STORAGEID은 전세계 Azure cloud에서 유일해야 함.

```bash
export TEAMID=unicorn
export ROOT_PROJECT=pubsub
export RESOURCE_GROUP=tiu-dgga-rg
export LOCATION=koreacentral
export STORAGEID=${TEAMID}storage${ROOT_PROJECT}
export EVENTHUB_NS=${TEAMID}-ns-${ROOT_PROJECT}
export EVENTHUB_NAME=${TEAMID}-name-${ROOT_PROJECT}
export BLOB_CONTAINER=${TEAMID}-checkpoints-${ROOT_PROJECT}

# Storage Account 존재 체크
az storage account show \
   --name $STORAGEID \
   --resource-group $RESOURCE_GROUP \
   --query name \
   --output tsv

# Storage Account 없으면 생성
az storage account create \
--name ${STORAGEID} \
--resource-group ${RESOURCE_GROUP} \
--location ${LOCATION} \
--sku Standard_LRS \
--only-show-errors

# Get Storage connection string
STORAGE_CONNECTION=$(az storage account show-connection-string \
--name ${STORAGEID} \
--resource-group ${RESOURCE_GROUP} \
--query connectionString \
--output tsv)

# Create container
az storage container create \
--name ${BLOB_CONTAINER} \
--connection-string "${STORAGE_CONNECTION}"

# Event Hubs setup
az eventhubs namespace create \
--name ${EVENTHUB_NS} \
--resource-group ${RESOURCE_GROUP} \
--location ${LOCATION} \
--sku Basic

#EventHub 생성: partition수는 Pod수와 동일하게 함
az eventhubs eventhub create \
--name ${EVENTHUB_NAME} \
--namespace-name ${EVENTHUB_NS} \
--resource-group ${RESOURCE_GROUP} \
--partition-count 1 \
--cleanup-policy Delete \
--retention-time 24

# Get connection strings
EVENTHUB_CONNECTION=$(az eventhubs namespace authorization-rule keys list \
--resource-group ${RESOURCE_GROUP} \
--namespace-name ${EVENTHUB_NS} \
--name RootManageSharedAccessKey \
--query primaryConnectionString -o tsv)

# Save connection strings to files
echo "STORAGE_CONNECTION => $STORAGE_CONNECTION"
echo "EVENTHUB_CONNECTION => $EVENTHUB_CONNECTION"
```

#### ※ 생성된 객체 삭제
```bash
STORAGE_CONNECTION=$(az storage account show-connection-string \
--name ${STORAGEID} \
--resource-group ${RESOURCE_GROUP} \
--query connectionString \
--output tsv)

# Event Hub 삭제
az eventhubs eventhub delete \
  --name ${EVENTHUB_NAME} \
  --namespace-name ${EVENTHUB_NS} \
  --resource-group ${RESOURCE_GROUP}

# Event Hub Namespace 삭제
az eventhubs namespace delete \
  --name ${EVENTHUB_NS} \
  --resource-group ${RESOURCE_GROUP}

# Blob Container 삭제 
az storage container delete \
  --name ${BLOB_CONTAINER} \
  --connection-string "${STORAGE_CONNECTION}"

# Storage Account 삭제
az storage account delete \
  --name ${STORAGEID} \
  --resource-group ${RESOURCE_GROUP} \
  --yes
```

### 3) EventGrid

#### 작업 디렉토리 생성
```bash
mkdir -p ~/install/eventgrid && cd ~/install/eventgrid
```

#### Domain추가하기
아래 내용으로 shell 생성. 파일명은 domain.sh:

```bash
#!/bin/bash

if [ $# -ne 1 ]; then
   echo "Usage: $0 TEAMID"
   echo "Example: $0 unicorn"
   exit 1
fi

TEAMID=$1
DOMAIN_SUFFIX="4.217.249.140.nip.io"
DOMAIN="${TEAMID}.${DOMAIN_SUFFIX}"
NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"

echo "Creating certificate for ${DOMAIN}..."
sudo certbot --nginx -d $DOMAIN

CONFIG_FILE="${NGINX_SITES_AVAILABLE}/${TEAMID}"
echo "Creating Nginx configuration for ${DOMAIN}..."

sudo bash -c "cat > ${CONFIG_FILE}" <<'EOL'
server {
   listen 443 ssl;
   server_name DOMAIN_PLACEHOLDER;
   ssl_certificate /etc/letsencrypt/live/DOMAIN_PLACEHOLDER/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/DOMAIN_PLACEHOLDER/privkey.pem;
   ssl_protocols TLSv1.2 TLSv1.3;
   ssl_ciphers HIGH:!aNULL:!MD5;
   location / {
       #proxy_pass http://20.214.113.85:80;
       proxy_ssl_verify off;
       proxy_buffer_size 64k;
       proxy_buffers 4 64k;
       proxy_busy_buffers_size 64k;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       proxy_read_timeout 60s;
       proxy_connect_timeout 60s;
       proxy_send_timeout 60s;
   }
}
EOL

sudo sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN}/g" "${CONFIG_FILE}"
sudo ln -sf ${CONFIG_FILE} ${NGINX_SITES_ENABLED}/${TEAMID}

echo "Reloading Nginx..."
sudo systemctl reload nginx
echo "Configuration complete for ${DOMAIN}"
```

#### 실행파일로 전환
```bash
chmod +x domain.sh
```

#### 실행하여 도메인 {Team id}.4.217.249.140.nip.io 생성
```bash
./domain.sh unicorn
```

#### 웹브라우저에서 https연결 확인
```
https://unicorn.4.217.249.140.nip.io/
```

#### Event Grid Topic, Dead Letter 생성
TEAMID, STORAGEID, EG_TOPIC, EG_SUB, DEAD_LETTER는 적절히 수정  
STORAGEID은 전세계 Azure cloud에서 유일해야 함.

```bash
export TEAMID=unicorn
export ROOT_PROJECT=pubsub
export RESOURCE_GROUP=tiu-dgga-rg
export LOCATION=koreacentral
export STORAGEID=${TEAMID}storage${ROOT_PROJECT}

export EG_TOPIC="${TEAMID}-topic-${ROOT_PROJECT}"
export EG_SUB="${TEAMID}-sub-${ROOT_PROJECT}"
export DEAD_LETTER="${TEAMID}deadletter${ROOT_PROJECT}"
export PROXY_IP="4.217.249.140"

# Event Grid Topic 생성
az eventgrid topic create \
   --name $EG_TOPIC \
   --resource-group $RESOURCE_GROUP \
   --location $LOCATION \
   --output none

# Storage Account가 있는지 체크
az storage account show \
   --name $STORAGEID \
   --resource-group $RESOURCE_GROUP \
   --query name \
   --output tsv

# Storage Account 없으면 생성 
az storage account create \
   --name $STORAGEID \
   --resource-group $RESOURCE_GROUP \
   --location $LOCATION \
   --sku Standard_LRS

# Get Storage connection string
STORAGE_CONNECTION=$(az storage account show-connection-string \
--name ${STORAGEID} \
--resource-group ${RESOURCE_GROUP} \
--query connectionString \
--output tsv)

# deadletter 컨테이너 존재 여부 확인
az storage container exists \
   --name $DEAD_LETTER \
   --connection-string "${STORAGE_CONNECTION}" \
   --query "exists" \
   -o tsv

# deadletter 컨테이너 없으면 생성
az storage container create \
   --name $DEAD_LETTER \
   --connection-string "${STORAGE_CONNECTION}" \
   --output none
```

#### Event Grid Subscriber 설정
Nginx proxy에서 proxy_pass를 Subscriber 애플리케이션으로 변경해야 함:

```bash
sudo vi /etc/nginx/sites-available/{team id}
```
![](images/2025-07-23-19-46-53.png)


변경후 nginx 재시작:
```bash
sudo nginx -t
sudo systemctl restart nginx
```

#### Event Grid Subscriber 등록
SUB_ENDPOINT를 맞게 수정하고 실행:

```bash
# Event Grid Subscriber 설정
export SUB_ENDPOINT="https://${TEAMID}.${PROXY_IP}.nip.io/api/…"

# 기존 subscription 확인
az eventgrid event-subscription show \
--name $EG_SUB \
--source-resource-id $(az eventgrid topic show --name $EG_TOPIC -g $RESOURCE_GROUP --query "id" -o tsv) \
--query "provisioningState" -o tsv

# subscription 없으면 생성
storage_id=$(az storage account show \
	--name $STORAGEID \
	--resource-group $RESOURCE_GROUP \
	--query id \
	--output tsv)
	
az eventgrid event-subscription create \
	--name $EG_SUB \
	--source-resource-id $(az eventgrid topic show --name $EG_TOPIC -g $RESOURCE_GROUP --query "id" -o tsv) \
	--endpoint $SUB_ENDPOINT \
	--endpoint-type webhook \
	--included-event-types UsageExceeded UsageAlert \
	--max-delivery-attempts 3 \
	--event-ttl 1440 \
	--deadletter-endpoint "${storage_id}/blobServices/default/containers/${DEAD_LETTER}" \
	--output none
```

#### ※ EventGrid관련 객체 삭제
```bash
# Event Grid Subscription 삭제
az eventgrid event-subscription delete \
  --name $EG_SUB \
  --source-resource-id $(az eventgrid topic show --name $EG_TOPIC -g $RESOURCE_GROUP --query "id" -o tsv)

# Event Grid Topic 삭제  
az eventgrid topic delete \
  --name $EG_TOPIC \
  --resource-group $RESOURCE_GROUP

# Blob Container 삭제
az storage container delete \
  --name $DEAD_LETTER \
  --connection-string "${STORAGE_CONNECTION}"

# Storage Account 삭제
az storage account delete \
  --name $STORAGEID \
  --resource-group $RESOURCE_GROUP \
  --yes
```

### 4) RabbitMQ

#### 작업 디렉토리 생성
```bash
mkdir -p ~/install/rabbitmq && cd ~/install/rabbitmq
```

#### manifest 생성
deploy.yaml로 생성:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: rabbitmq
  labels:
    app: rabbitmq
spec:
  serviceName: rabbitmq
  selector:
    matchLabels:
      app: rabbitmq
  replicas: 1
  template:
    metadata:
      name: rabbitmq
      labels:
        app: rabbitmq
    spec:
      serviceAccountName: default
      containers:
      - name: rabbitmq
        image: rabbitmq:management
        imagePullPolicy: IfNotPresent
        env:
        - name: RABBITMQ_DEFAULT_USER
          value: admin
        - name: RABBITMQ_DEFAULT_PASS
          value: P@ssw0rd$
        ports:
        - name: containerport
          containerPort: 5672
        - name: consoleport
          containerPort: 15672
        resources:
          requests:
            cpu: 128m
            memory: 128Mi
          limits:
            cpu: 1024m
            memory: 1024Mi
---
apiVersion: v1
kind: Service
metadata:
  name: rabbitmq
spec:
  type: LoadBalancer
  selector:
    app: rabbitmq
  ports:
  - name: port1
    port: 5672
    targetPort: 5672
  - name: port2
    port: 15672
    targetPort: 15672
```

#### 설치
```bash
k apply -f deploy.yaml
```

#### Admin 페이지 접속
L/B IP 확인하여 `http://{rabbit mq service L/B IP}:15672`로 접속.  
ID/PW는 deploy.yaml에 지정한 값으로 로그인.
![](images/2025-07-23-19-47-17.png) 

### 5) Kafka

#### 작업 디렉토리 생성
```bash
mkdir -p ~/install/kafka && cd ~/install/kafka
```

#### values.yaml 작성
```yaml
# values.yaml
global:
 storageClass: "managed"

auth:
  clientProtocol: plaintext
  interBrokerProtocol: plaintext
  sasl:
    enabled: false
  tls:
    enabled: false

listeners:
  client:
    protocol: PLAINTEXT
    
kraft:
 enabled: true

controller:
 replicaCount: 1
 heapOpts: "-Xmx1g -Xms1g"
 persistence:
   enabled: true
   size: 10Gi
 resources:
   limits:
     memory: 2Gi
     cpu: 1
   requests:
     memory: 1Gi
     cpu: 1

broker:
 replicaCount: 3
 heapOpts: "-Xmx1g -Xms1g"
 persistence:
   enabled: true
   size: 10Gi
 resources:
   limits:
     memory: 2Gi
     cpu: 1
   requests:
     memory: 1Gi
     cpu: 1

deleteTopicEnable: true
autoCreateTopicsEnable: false

offsets:
 topic:
   replication:
     factor: 3
   segment:
     bytes: 1073741824
```

#### 설치
```bash
helm upgrade -i kafka -f values.yaml bitnami/kafka --version 29.3.14
```

아래 명령으로 모든 pod가 실행될때까지 기다렸다가, CTRL-C로 중지:
```bash
watch kubectl get po
```

#### Kafka web console 파드를 실행
kafka-ui.yaml 작성:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: kafka-ui
 labels:
   app: kafka-ui
spec:
 replicas: 1
 selector:
   matchLabels:
     app: kafka-ui
 template:
   metadata:
     labels:
       app: kafka-ui
   spec:
     containers:
       - name: kafka-ui
         image: provectuslabs/kafka-ui:latest
         env:
           - name: KAFKA_CLUSTERS_0_NAME 
             value: "k8s-kafka"
           - name: KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS
             value: "kafka:9092"
           - name: KAFKA_CLUSTERS_0_PROPERTIES_SECURITY_PROTOCOL
             value: "PLAINTEXT"
           - name: KAFKA_CLUSTERS_0_PROPERTIES_SASL_ENABLED
             value: "false"
         ports:
           - containerPort: 8080
             name: http
         resources:
           limits:
             memory: "1Gi"
             cpu: "500m"
           requests:
             memory: "512Mi"
             cpu: "250m"
---
apiVersion: v1
kind: Service
metadata:
 name: kafka-ui
 labels:
   app: kafka-ui
spec:
 type: LoadBalancer
 ports:
   - port: 8080
     targetPort: http
     protocol: TCP
     name: http
 selector:
   app: kafka-ui
```

#### 객체 생성
```bash
k apply -f kafka-ui.yaml
```

#### L/B IP 확인
```bash
k get svc kafka-ui
```

#### 접속 테스트
웹브라우저에서 web console 접근:
```
http://{kafka-ui service L/B IP}:8080
```

![](images/2025-07-23-19-47-51.png)

---

## 4. Azure Blob Storage 설치

RESOURCE_GROUP, LOCATION을 확인하고 틀리면 바꾸세요.
```bash
az group list -o table
```

USERID, SYSTEM, CONTAINERS를 본인 서비스에 맞게 수정합니다.

```bash
#!/bin/bash

RESOURCE_GROUP="ictcoe-edu"
LOCATION="koreacentral"

USERID="unicorn"
SYSTEM="cms"
NAME="${USERID}-${SYSTEM}"
STORAGE_ACCOUNT_NAME="${USERID}${SYSTEM}storage"

# 생성할 컨테이너 목록 정의
CONTAINERS=("marketing-materials" "user-guides" "documents" "images" "videos")

# 로그 함수 정의
log() {
    echo "[INFO] $1"
}

# 에러 체크 함수 정의
check_error() {
    if [ $? -ne 0 ]; then
        echo "[ERROR] $1"
        exit 1
    fi
}
   
# Storage 계정 존재 확인
log "Storage 계정 확인 중..."
az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP &>/dev/null
if [ $? -ne 0 ]; then
    log "Storage 계정 생성 중..."
    az storage account create \
        --name $STORAGE_ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --sku Standard_LRS \
        --kind StorageV2
    check_error "Storage 계정 생성 실패"
else
    log "기존 Storage 계정 사용"
fi

# Azure CLI를 사용하여 CORS 설정
log "CORS 설정 중..."
az storage cors clear --account-name $STORAGE_ACCOUNT_NAME --services b
check_error "CORS 초기화 실패"

# 새 CORS 규칙 추가
az storage cors add --account-name $STORAGE_ACCOUNT_NAME \
    --services b \
    --origins "*" \
    --methods "GET,HEAD,PUT,POST,DELETE,OPTIONS" \
    --allowed-headers "*" \
    --exposed-headers "*" \
    --max-age 3600
check_error "CORS 규칙 추가 실패"

# 연결 문자열 가져오기
log "Storage 연결 문자열 가져오는 중..."
STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
    --name $STORAGE_ACCOUNT_NAME \
    --resource-group $RESOURCE_GROUP \
    --query connectionString \
    --output tsv)
   
if [ $? -ne 0 ]; then
    echo "[ERROR] Storage 연결 문자열 가져오기 실패"
    exit 1
fi

# 지정된 컨테이너 생성
log "Blob Storage 컨테이너 생성 중..."
for CONTAINER in "${CONTAINERS[@]}"; do
    log "컨테이너 '$CONTAINER' 생성 중..."
    az storage container create \
        --name "$CONTAINER" \
        --connection-string "$STORAGE_CONNECTION_STRING" \
        --public-access off 2>/dev/null || true
    
    if [ $? -eq 0 ]; then
        log "컨테이너 '$CONTAINER' 생성 완료"
    else
        log "컨테이너 '$CONTAINER'가 이미 존재하거나 생성 중 오류 발생"
    fi
done

log "Azure Storage 설정 완료"
```

아래와 같이 Azure 포탈에서 확인합니다.  
STORAGE_ACCOUNT_NAME에 해당하는 Storage Account 객체 찾기

![](images/2025-07-23-19-48-16.png)
![](images/2025-07-23-19-48-23.png)


위 컨테이너에 수동으로 파일을 올릴 수 있습니다.
