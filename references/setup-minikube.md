아래 가이드는 예제 프로그램 phonebill 을 minikube에서 학습하기 위한 환경설정입니다.    
프로젝트 소스는 아래에 있습니다.   
https://github.com/cna-bootcamp/phonebill.git
https://github.com/cna-bootcamp/phonebill-front.git


- [사전 작업](#사전-작업)
- [Ubuntu 서버에 Minikube 설치 및 접속](#ubuntu-서버에-minikube-설치-및-접속)
  - [1. 서버에서 Minikube 시작](#1-서버에서-minikube-시작)
    - [minikube 설치](#minikube-설치)
    - [외부 접근 가능하도록 minikube 시작](#외부-접근-가능하도록-minikube-시작)
    - [Ingress 활성화](#ingress-활성화)
    - [외부에서 Nginx Ingress Controller POD 접속 설정](#외부에서-nginx-ingress-controller-pod-접속-설정)
  - [2. 서버에서 인증서 파일 확인](#2-서버에서-인증서-파일-확인)
  - [3. 서버에서 로컬로 파일 복사 (로컬에서 실행)](#3-서버에서-로컬로-파일-복사-로컬에서-실행)
  - [4. SSH 터널 생성 (로컬에서 실행)](#4-ssh-터널-생성-로컬에서-실행)
  - [5. 로컬의 kubeconfig 업데이트 (로컬에서 최초 1번 실행)](#5-로컬의-kubeconfig-업데이트-로컬에서-최초-1번-실행)
  - [6. 연결 테스트](#6-연결-테스트)
  - [7. SSH 터널 관리](#7-ssh-터널-관리)
- [Backing Service 설치](#backing-service-설치)
  - [Database 설치](#database-설치)
    - [PostgresSQL 설정 파일 작성](#postgressql-설정-파일-작성)
    - [PostgresSQL 설치](#postgressql-설치)
  - [Redis 설치](#redis-설치)
    - [설정파일 작성](#설정파일-작성)
    - [Redis 설치](#redis-설치-1)
  - [로컬에서 port forward](#로컬에서-port-forward)
    - [Port Forward](#port-forward)
    - [port forward 중지](#port-forward-중지)
- [minikube에 CI/CD 툴 설치](#minikube에-cicd-툴-설치)
  - [minikube에 Jenkins 설치](#minikube에-jenkins-설치)
    - [jenkins.yaml 작성](#jenkinsyaml-작성)
    - [Ingress 생성](#ingress-생성)
  - [minikube에 ArgoCD 설치](#minikube에-argocd-설치)

---

# 사전 작업

Azure 상에서 환경 구성하기 위한 가이드를 참고하여 아래 작업만 하십시오.

- Azure 구독
- 리소스 프로바이더 등록
- 리소스그룹 생성
- Azure CLI 설치 및 로그인
- 기본 configuratioon 셋팅

https://github.com/cna-bootcamp/handson-azure/blob/main/prepare/setup-server.md


VM을 생성하십시오. 
https://github.com/cna-bootcamp/clauding-guide/blob/main/references/create-vm.md


---

# Ubuntu 서버에 Minikube 설치 및 접속

## 1. 서버에서 Minikube 시작

환경변수 선언(Local에서 수행).   
VM_KEY, VM_IP는 본인 것으로 변경해야 함    
```
export VM_KEY=~/home/k8s_key.pem
export VM_USER=azureuser
export VM_IP=72.155.72.236
```

```bash
# 서버 접속
ssh -i ${VM_KEY} ${VM_USER}@${VM_IP}
```
팁) ~/.ssh/config 파일을 만들고 아래와 같이 설정하면 지정한 Host로 접근할 수 있음   

```
Host k8s
    HostName 72.155.72.236
    User azureuser
    Port 22
    IdentityFile ~/home/k8s_key.pem
```
접속: ssh k8s 

### minikube 설치
```
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# 필수 패키지 설치
sudo apt install -y curl wget apt-transport-https

# Minikube 바이너리 다운로드
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# 설치
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 설치 확인
minikube version
```

### 외부 접근 가능하도록 minikube 시작
VM_IP값은 본인것에 맞게 수정  
```
export VM_IP=72.155.72.236

# 7core, 12GB
minikube start \
  --driver=docker \
  --apiserver-ips=${VM_IP} \
  --cpus=7 \
  --memory=14336

# minikube 내부 IP 확인 (메모해 둘 것)
minikube ip
# 예: 192.168.49.2

```

### Ingress 활성화  
```
minikube addons enable ingress  
```
ingress-nginx 네임스페이스에 nginx Pod 확인   
```
k get po -n ingress-nginx  
```

### 외부에서 Nginx Ingress Controller POD 접속 설정   
이미 port forward 되어 있는지 확인
```
ps aux | grep port-forward
```

```
# HTTP (80)
sudo kubectl --kubeconfig=$HOME/.kube/config port-forward svc/ingress-nginx-controller 80:80 -n ingress-nginx --address 0.0.0.0 &

# HTTPS (443)
sudo kubectl --kubeconfig=$HOME/.kube/config port-forward svc/ingress-nginx-controller 443:443 -n ingress-nginx --address 0.0.0.0 &
```

(중요) VM의 방화벽(Azure의 경우는 NSG)에서 80,443 포트 오픈   
![](images/2025-12-01-15-32-27.png)
![](images/2025-12-01-15-32-46.png)
![](images/2025-12-01-15-33-24.png)


웹브라우저에서 http://{VM IP}로 접근하였을 때 '404 Not Found'라는 페이지가 연결되면 성공임.    


## 2. 서버에서 인증서 파일 확인

```bash
# 필요한 파일 위치 확인
ls ~/.minikube/ca.crt
ls ~/.minikube/profiles/minikube/client.crt
ls ~/.minikube/profiles/minikube/client.key
```

## 3. 서버에서 로컬로 파일 복사 (로컬에서 실행)

아래 값은 본인것에 맞게 수정해야 함  

```bash
export VM_IP=72.155.72.236
export VM_USER=azureuser
export VM_KEY=~/home/k8s_key.pem
```

```bash
# 로컬에 디렉토리 생성
mkdir -p ~/.kube/minikube-certs

# scp로 파일 복사
scp -i ${VM_KEY} ${VM_USER}@${VM_IP}:~/.minikube/ca.crt ~/.kube/minikube-certs/
scp -i ${VM_KEY} ${VM_USER}@${VM_IP}:~/.minikube/profiles/minikube/client.crt ~/.kube/minikube-certs/
scp -i ${VM_KEY} ${VM_USER}@${VM_IP}:~/.minikube/profiles/minikube/client.key ~/.kube/minikube-certs/
```

## 4. SSH 터널 생성 (로컬에서 실행)

```bash
# MINIKUBE_IP는 2단계에서 확인한 minikube ip 결과값
export MINIKUBE_IP=192.168.49.2

# SSH 터널 생성 (백그라운드 실행)
ssh -i ${VM_KEY} -L 8443:${MINIKUBE_IP}:8443 ${VM_USER}@${VM_IP} -N &

# 터널 프로세스 확인
ps aux | grep ssh
```

## 5. 로컬의 kubeconfig 업데이트 (로컬에서 최초 1번 실행)

```bash
KUBE_CERTS_DIR="${HOME}/.kube/minikube-certs"

# 클러스터 추가 (localhost로 설정 - SSH 터널 사용)
kubectl config set-cluster minikube-remote \
  --server=https://127.0.0.1:8443 \
  --certificate-authority=${KUBE_CERTS_DIR}/ca.crt

# 사용자 추가
kubectl config set-credentials minikube-remote \
  --client-certificate=${KUBE_CERTS_DIR}/client.crt \
  --client-key=${KUBE_CERTS_DIR}/client.key

# 컨텍스트 추가
kubectl config set-context minikube-remote \
  --cluster=minikube-remote \
  --user=minikube-remote

# 컨텍스트 사용
kubectl config use-context minikube-remote
```

## 6. 연결 테스트

```bash
# 클러스터 정보 확인
kubectl cluster-info

# 노드 확인
kubectl get nodes

# 파드 확인
kubectl get pods -A
```

## 7. SSH 터널 관리

```bash
# 터널 종료
pkill -f "ssh -i ${VM_KEY} -L 8443"

# 터널 재시작
ssh -i ${VM_KEY} -L 8443:${MINIKUBE_IP}:8443 ${VM_USER}@${VM_IP} -N &
```

---

# Backing Service 설치
아래 작업을 로컬 PC에서 수행하세요.    

작업 디렉토리 작성
```
mkdir ~/install/phonebill && cd ~/install/phonebill
```

namespace 작성/변경
```
k create ns phonebill  
kubens phonebill
```

## Database 설치

### PostgresSQL 설정 파일 작성  

아래와 같이 SVC변수를 auth, inquiry, change로 변경하여 각 서비스별 설정 파일 생성      
```
export SVC=auth
```

```
cat > values-${SVC}.yaml << EOF
architecture: standalone

# 글로벌 설정
global:
  postgresql:
    auth:
      postgresPassword: "Hi5Jessica!"
      replicationPassword: "Hi5Jessica!"
      database: "${SVC}db"
      username: "unicorn"
      password: "P@ssw0rd$"
  storageClass: "standard"

# Primary 설정
primary:
  persistence:
    enabled: true
    storageClass: "standard"
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

# image: organization이 bitnami -> bitnamilegacy로 변경
image:
  registry: docker.io
  repository: bitnamilegacy/postgresql

EOF
```

### PostgresSQL 설치  
```
helm upgrade -i auth -f values-auth.yaml bitnami/postgresql --version 12.12.10
helm upgrade -i inquiry -f values-inquiry.yaml bitnami/postgresql --version 12.12.10
helm upgrade -i change -f values-change.yaml bitnami/postgresql --version 12.12.10
```

---

## Redis 설치

### 설정파일 작성

```
cat > values-cache.yaml << EOF
architecture: standalone

auth:
  enabled: true
  password: "P@ssw0rd$"

master:
  persistence:
    enabled: true
    storageClass: "standard"
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

sentinel:
  enabled: false

service:
  type: ClusterIP
  ports:
    redis: 6379

podAntiAffinityPreset: soft

securityContext:
  enabled: true
  fsGroup: 1001
  runAsUser: 1001


# image: organization이 bitnami -> bitnamilegacy로 변경   
image:
  registry: registry-1.docker.io
  repository: bitnamilegacy/redis

EOF
```

### Redis 설치
```
helm upgrade -i cache -f values-cache.yaml bitnami/redis
```

---

## 로컬에서 port forward

### Port Forward
새로운 터미널을 열어 수행하세요.  
```
k port-forward svc/auth-postgresql 15432:5432 &
k port-forward svc/inquiry-postgresql 25432:5432 &
k port-forward svc/change-postgresql 35432:5432 &
k port-forward svc/cache-redis-master 16379:6379 &
```

### port forward 중지
프로세스 ID 확인   
```
ps -ef | grep port-forward
```
예시) 두번째 있는 Process ID를 확인
```
> ps -ef | grep port-forward
501 84369 78584   0  4:42AM ttys024    0:00.05 kubectl port-forward svc/auth-postgresql 15432:5432
501 84370 78584   0  4:42AM ttys024    0:00.05 kubectl port-forward svc/inquiry-postgresql 25432:5432

> kill 84369 84370
```

---

# minikube에 CI/CD 툴 설치

아래 링크를 참조하여 helm으로 설치.   
https://github.com/cna-bootcamp/clauding-guide/blob/882cabb67d64150513f1c580b00a5b377e23109d/guides/setup/05.setup-cicd-tools.md


## minikube에 Jenkins 설치

### jenkins.yaml 작성

```
cat > jenkins.yaml << EOF
global:
  storageClass: "standard"

jenkinsUser: admin
jenkinsPassword: "P@ssw0rd$"
jenkinsHost: "http://myjenkins.io"
jenkinsHome: /bitnami/jenkins/home

javaOpts:
  - -Dfile.encoding=UTF-8

containerPorts:
  http: 8080
  https: 8443
  agentListener: 50000

agentListenerService:
  enabled: true
  type: ClusterIP
  ports:
    agentListener: 50000

persistence:
  enabled: true
  storageClass: "standard"
  accessModes:
    - ReadWriteOnce
  size: 8Gi

image:
  registry: docker.io
  repository: bitnamilegacy/jenkins
  tag: 2.516.2-debian-12-r0

agent:
  enabled: true
  image:
    registry: docker.io
    repository: bitnamilegacy/jenkins-agent
    tag: 0.3327.0-debian-12-r1

serviceAccount:
  create: true
  automountServiceAccountToken: true
EOF
```

### Ingress 생성
yaml 작성  
```
cat > jenkins-ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: jenkins
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
spec:
  ingressClassName: nginx
  rules:
    - host: myjenkins.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: jenkins
                port:
                  number: 80
EOF
```

ingress 생성
```
k apply -f jenkins-ingress.yaml  
```

hosts 추가
```
sudo vi /etc/hosts
```

예시)
```
# Jenkins
72.155.72.236   myjenkins.io
```

---

## minikube에 ArgoCD 설치

minikube가 설치된 VM IP로 환경변수 생성   
```
export ING_IP=72.155.72.236
```

설정 파일 생성
```
cat > argocd.yaml << EOF
global:
  domain: argo.$ING_IP.nip.io

server:
  ingress:
    enabled: true
    https: true
    annotations:
      kubernetes.io/ingress.class: nginx
    tls:
      - secretName: argocd-tls-secret
  extraArgs:
    - --insecure  # ArgoCD 서버가 TLS 종료를 Ingress에 위임

configs:
  params:
    server.insecure: true  # Ingress에서 TLS를 처리하므로 ArgoCD 서버는 HTTP로 통신
certificate:
  enabled: false  # 자체 서명 인증서 사용 비활성화 (외부 인증서 사용 시)
EOF
```

---


