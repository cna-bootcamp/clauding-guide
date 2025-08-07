# User Service 개발환경 데이터베이스 설치 가이드

## 개요

User Service는 사용자 인증, 인가 및 프로필 관리를 담당하는 서비스입니다. PostgreSQL 14를 사용하여 사용자 정보와 인증 관련 데이터를 안전하게 관리합니다.

### 주요 기능
- 사용자 계정 관리 (가입, 로그인, 프로필)
- 계정 보안 (비밀번호 암호화, 계정 잠금)
- 세션 관리
- 로그인 시도 추적

## 사전 요구사항

### 필수 소프트웨어
- Docker Desktop
- kubectl
- 최소 2GB 여유 디스크 공간
- 최소 1GB 여유 메모리

### 확인 명령어
```bash
# Docker 상태 확인
docker --version
docker-compose --version

# Kubernetes 상태 확인
kubectl version --client
kubectl cluster-info
```

## 설치 절차

### 1단계: 네임스페이스 생성

```bash
# 개발 네임스페이스 생성
kubectl create namespace tripgen-dev

# 네임스페이스 확인
kubectl get namespaces
```

### 2단계: Kubernetes 매니페스트 파일 생성

#### user-db-configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-db-config
  namespace: tripgen-dev
data:
  POSTGRES_DB: "tripgen_user_db"
  POSTGRES_USER: "tripgen_user"
  POSTGRES_SCHEMA: "tripgen_user"
  PGDATA: "/var/lib/postgresql/data/pgdata"
```

#### user-db-secret.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: user-db-secret
  namespace: tripgen-dev
type: Opaque
data:
  # Base64 인코딩된 값 (실제 운영시 변경 필요)
  POSTGRES_PASSWORD: dHJpcGdlbl91c2VyXzEyMw==  # tripgen_user_123
```

#### user-db-pvc.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: user-db-pvc
  namespace: tripgen-dev
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  # 개발환경에서는 hostPath 사용
  storageClassName: managed
```

#### user-db-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-db
  namespace: tripgen-dev
  labels:
    app: user-db
    component: database
    service: user-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-db
  template:
    metadata:
      labels:
        app: user-db
        component: database
        service: user-service
    spec:
      containers:
      - name: postgres
        image: postgres:14-alpine
        ports:
        - containerPort: 5432
          name: postgres
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: user-db-secret
              key: POSTGRES_PASSWORD
        envFrom:
        - configMapRef:
            name: user-db-config
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        - name: init-sql
          mountPath: /docker-entrypoint-initdb.d
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - exec pg_isready -U tripgen_user -d tripgen_user_db -h 127.0.0.1 -p 5432
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 6
        readinessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - exec pg_isready -U tripgen_user -d tripgen_user_db -h 127.0.0.1 -p 5432
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: user-db-pvc
      - name: init-sql
        configMap:
          name: user-db-init-sql
      restartPolicy: Always
```

#### user-db-service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: user-db-service
  namespace: tripgen-dev
  labels:
    app: user-db
    component: database
    service: user-service
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
    protocol: TCP
    name: postgres
  selector:
    app: user-db
```

### 3단계: 초기화 SQL 스크립트 준비

#### user-db-init-configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-db-init-sql
  namespace: tripgen-dev
data:
  01-init-database.sql: |
    -- Database and Schema Creation
    CREATE SCHEMA IF NOT EXISTS tripgen_user;
    SET search_path TO tripgen_user;
    
    -- UUID Extension
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    
  02-create-tables.sql: |
    -- Set search path
    SET search_path TO tripgen_user;
    
    -- users 테이블 생성
    CREATE TABLE users (
        id                  BIGSERIAL PRIMARY KEY,
        user_id            VARCHAR(36) UNIQUE NOT NULL DEFAULT uuid_generate_v4()::text,
        username           VARCHAR(50) UNIQUE NOT NULL,
        password           VARCHAR(255) NOT NULL,
        name               VARCHAR(100) NOT NULL,
        email              VARCHAR(255) UNIQUE NOT NULL,
        phone              VARCHAR(20),
        avatar_url         VARCHAR(500),
        status             VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
        login_attempts     INTEGER NOT NULL DEFAULT 0,
        locked_until       TIMESTAMP WITH TIME ZONE,
        last_login_at      TIMESTAMP WITH TIME ZONE,
        created_by         VARCHAR(36),
        updated_by         VARCHAR(36),
        created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        
        -- 제약조건
        CONSTRAINT chk_users_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'LOCKED', 'DELETED')),
        CONSTRAINT chk_users_login_attempts CHECK (login_attempts >= 0 AND login_attempts <= 10),
        CONSTRAINT chk_users_username_length CHECK (LENGTH(username) >= 5 AND LENGTH(username) <= 50),
        CONSTRAINT chk_users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
        CONSTRAINT chk_users_name_length CHECK (LENGTH(name) >= 2 AND LENGTH(name) <= 100),
        CONSTRAINT chk_users_phone_format CHECK (phone IS NULL OR phone ~* '^[\+]?[0-9\-\s\(\)]+$')
    );
    
  03-create-indexes.sql: |
    -- Set search path
    SET search_path TO tripgen_user;
    
    -- 인덱스 생성
    CREATE UNIQUE INDEX idx_users_user_id ON users(user_id);
    CREATE UNIQUE INDEX idx_users_username ON users(username);
    CREATE UNIQUE INDEX idx_users_email ON users(email);
    CREATE INDEX idx_users_status ON users(status);
    CREATE INDEX idx_users_locked_until ON users(locked_until) WHERE locked_until IS NOT NULL;
    CREATE INDEX idx_users_last_login_at ON users(last_login_at);
    CREATE INDEX idx_users_created_at ON users(created_at);
    CREATE INDEX idx_users_active_users ON users(id) WHERE status = 'ACTIVE';
    
  04-create-functions.sql: |
    -- Set search path
    SET search_path TO tripgen_user;
    
    -- 자동 갱신 트리거 함수
    CREATE OR REPLACE FUNCTION update_users_updated_at()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    
    -- 계정 잠금 해제 트리거 함수
    CREATE OR REPLACE FUNCTION check_account_unlock()
    RETURNS TRIGGER AS $$
    BEGIN
        -- 계정 잠금 시간이 지났으면 자동 해제
        IF NEW.locked_until IS NOT NULL AND NEW.locked_until <= CURRENT_TIMESTAMP THEN
            NEW.locked_until = NULL;
            NEW.login_attempts = 0;
            NEW.status = 'ACTIVE';
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    
  05-create-triggers.sql: |
    -- Set search path
    SET search_path TO tripgen_user;
    
    -- 트리거 생성
    CREATE TRIGGER trg_users_updated_at
        BEFORE UPDATE ON users
        FOR EACH ROW
        EXECUTE FUNCTION update_users_updated_at();
    
  06-insert-sample-data.sql: |
    -- Set search path
    SET search_path TO tripgen_user;
    
    -- 기본 데이터 삽입 (관리자 계정)
    INSERT INTO users (
        username, 
        password, 
        name, 
        email, 
        status,
        created_by,
        updated_by
    ) VALUES (
        'admin',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6hsJXWgdWi', -- admin123
        '시스템 관리자',
        'admin@tripgen.com',
        'ACTIVE',
        uuid_generate_v4()::text,
        uuid_generate_v4()::text
    );
    
    -- 테스트 사용자 계정
    INSERT INTO users (
        username, 
        password, 
        name, 
        email, 
        status,
        created_by,
        updated_by
    ) VALUES (
        'testuser',
        '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj6hsJXWgdWi', -- admin123
        '테스트 사용자',
        'test@tripgen.com',
        'ACTIVE',
        uuid_generate_v4()::text,
        uuid_generate_v4()::text
    );
    
  99-comments-and-analyze.sql: |
    -- Set search path
    SET search_path TO tripgen_user;
    
    -- 테이블 코멘트
    COMMENT ON TABLE users IS '사용자 정보 및 인증 관리 테이블';
    COMMENT ON COLUMN users.user_id IS '외부 서비스에서 참조하는 비즈니스 키 (UUID)';
    COMMENT ON COLUMN users.username IS '로그인용 사용자 아이디 (5자 이상)';
    COMMENT ON COLUMN users.password IS 'BCrypt 암호화된 비밀번호';
    COMMENT ON COLUMN users.name IS '사용자 실명 (2자 이상)';
    COMMENT ON COLUMN users.email IS '이메일 주소 (중복 불가)';
    COMMENT ON COLUMN users.phone IS '휴대폰 번호 (선택사항)';
    COMMENT ON COLUMN users.status IS '계정 상태 (ACTIVE/INACTIVE/SUSPENDED/LOCKED/DELETED)';
    COMMENT ON COLUMN users.login_attempts IS '연속 로그인 실패 횟수 (최대 10회)';
    COMMENT ON COLUMN users.locked_until IS '계정 잠금 해제 시간';
    
    -- 성능 통계 수집
    ANALYZE users;
```

### 4단계: 리소스 배포

```bash
# 1. ConfigMap과 Secret 생성
kubectl apply -f user-db-configmap.yaml
kubectl apply -f user-db-secret.yaml
kubectl apply -f user-db-init-configmap.yaml

# 2. PVC 생성
kubectl apply -f user-db-pvc.yaml

# 3. Deployment와 Service 생성
kubectl apply -f user-db-deployment.yaml
kubectl apply -f user-db-service.yaml

# 4. 배포 상태 확인
kubectl get all -n tripgen-dev -l app=user-db
```

## 데이터베이스 초기화

### 초기화 확인

```bash
# Pod 상태 확인
kubectl get pods -n tripgen-dev -l app=user-db

# Pod 로그 확인
kubectl logs -n tripgen-dev -l app=user-db

# 데이터베이스 접속 테스트
kubectl exec -it -n tripgen-dev deployment/user-db -- psql -U tripgen_user -d tripgen_user_db
```

### 수동 초기화 (필요시)

```bash
# Pod 내부 접속
kubectl exec -it -n tripgen-dev deployment/user-db -- bash

# 데이터베이스 접속
psql -U tripgen_user -d tripgen_user_db

# 스키마 확인
\dt tripgen_user.*

# 샘플 데이터 확인
SET search_path TO tripgen_user;
SELECT user_id, username, name, email, status FROM users;
```

## 연결 테스트

### 1. 포트 포워딩 설정

```bash
# 로컬에서 데이터베이스 접근
kubectl port-forward -n tripgen-dev service/user-db-service 5432:5432
```

### 2. 외부 클라이언트 연결

```bash
# psql 클라이언트 연결
psql -h localhost -p 5432 -U tripgen_user -d tripgen_user_db

# 연결 정보
# Host: localhost
# Port: 5432
# Database: tripgen_user_db
# Username: tripgen_user
# Password: tripgen_user_123
# Schema: tripgen_user
```

### 3. 애플리케이션 연결 설정

#### Spring Boot application.yml
```yaml
spring:
  datasource:
    url: jdbc:postgresql://user-db-service.tripgen-dev.svc.cluster.local:5432/tripgen_user_db
    username: tripgen_user
    password: tripgen_user_123
    driver-class-name: org.postgresql.Driver
  jpa:
    database-platform: org.hibernate.dialect.PostgreSQLDialect
    properties:
      hibernate:
        default_schema: tripgen_user
```

## 문제 해결

### 일반적인 문제

#### 1. Pod이 시작되지 않는 경우

```bash
# 이벤트 확인
kubectl describe pod -n tripgen-dev -l app=user-db

# 리소스 상태 확인
kubectl get events -n tripgen-dev --sort-by='.lastTimestamp'
```

#### 2. 데이터베이스 연결 실패

```bash
# 서비스 엔드포인트 확인
kubectl get endpoints -n tripgen-dev user-db-service

# 네트워크 정책 확인
kubectl get netpol -n tripgen-dev
```

#### 3. 초기화 스크립트 실행 실패

```bash
# ConfigMap 내용 확인
kubectl describe configmap -n tripgen-dev user-db-init-sql

# Pod 내부에서 스크립트 수동 실행
kubectl exec -it -n tripgen-dev deployment/user-db -- bash
psql -U tripgen_user -d tripgen_user_db -f /docker-entrypoint-initdb.d/02-create-tables.sql
```

### 데이터 백업 및 복원

#### 백업

```bash
# 데이터베이스 백업
kubectl exec -n tripgen-dev deployment/user-db -- pg_dump -U tripgen_user tripgen_user_db > user-db-backup.sql
```

#### 복원

```bash
# 데이터베이스 복원
kubectl exec -i -n tripgen-dev deployment/user-db -- psql -U tripgen_user tripgen_user_db < user-db-backup.sql
```

### 모니터링

#### 리소스 사용량 확인

```bash
# Pod 리소스 사용량
kubectl top pod -n tripgen-dev -l app=user-db

# 스토리지 사용량
kubectl describe pvc -n tripgen-dev user-db-pvc
```

#### 로그 모니터링

```bash
# 실시간 로그 확인
kubectl logs -n tripgen-dev -l app=user-db -f

# 오류 로그 필터링
kubectl logs -n tripgen-dev -l app=user-db | grep ERROR
```

## 개발환경 특화 설정

### 개발용 유용한 명령어

```bash
# 빠른 재시작
kubectl rollout restart -n tripgen-dev deployment/user-db

# 스키마 재생성 (개발용)
kubectl exec -it -n tripgen-dev deployment/user-db -- psql -U tripgen_user -d tripgen_user_db -c "DROP SCHEMA IF EXISTS tripgen_user CASCADE; CREATE SCHEMA tripgen_user;"

# 테스트 데이터 삽입
kubectl exec -it -n tripgen-dev deployment/user-db -- psql -U tripgen_user -d tripgen_user_db -f /docker-entrypoint-initdb.d/06-insert-sample-data.sql
```

### 성능 최적화 (개발용)

```sql
-- 개발환경용 PostgreSQL 설정
ALTER SYSTEM SET shared_buffers = '128MB';
ALTER SYSTEM SET effective_cache_size = '512MB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
SELECT pg_reload_conf();
```

---

**다음 단계**: [Trip Service 데이터베이스 설치](db-trip-dev.md)

**관련 문서**:
- [AI Service 데이터베이스 설치](db-ai-dev.md)
- [Location Service 데이터베이스 설치](db-location-dev.md)
- [전체 개발환경 구성 가이드](../README-dev.md)