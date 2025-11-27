# Ubuntu 서버의 Minikube에 로컬에서 접속하기

## 1. 환경 변수 설정 (로컬에서)

```bash
export VM_IP=72.155.72.236
export VM_USER=azureuser
export VM_KEY=~/home/k8s_key.pem
```

## 2. 서버에서 Minikube 시작

```bash
# 서버 접속
ssh -i ${VM_KEY} ${VM_USER}@${VM_IP}
```

## minikube 설치
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

# 외부 접근 가능하도록 minikube 시작
```
export VM_IP=72.155.72.236

minikube start \
  --driver=docker \
  --apiserver-ips=${VM_IP}

# minikube 내부 IP 확인 (메모해 둘 것)
minikube ip
# 예: 192.168.49.2

```

## 3. 서버에서 인증서 파일 확인

```bash
# 필요한 파일 위치 확인
ls ~/.minikube/ca.crt
ls ~/.minikube/profiles/minikube/client.crt
ls ~/.minikube/profiles/minikube/client.key
```

## 4. 서버에서 로컬로 파일 복사 (로컬에서 실행)

```bash
# 로컬에 디렉토리 생성
mkdir -p ~/.kube/minikube-certs

# scp로 파일 복사
scp -i ${VM_KEY} ${VM_USER}@${VM_IP}:~/.minikube/ca.crt ~/.kube/minikube-certs/
scp -i ${VM_KEY} ${VM_USER}@${VM_IP}:~/.minikube/profiles/minikube/client.crt ~/.kube/minikube-certs/
scp -i ${VM_KEY} ${VM_USER}@${VM_IP}:~/.minikube/profiles/minikube/client.key ~/.kube/minikube-certs/
```

## 5. SSH 터널 생성 (로컬에서 실행)

```bash
# MINIKUBE_IP는 2단계에서 확인한 minikube ip 결과값
export MINIKUBE_IP=192.168.49.2

# SSH 터널 생성 (백그라운드 실행)
ssh -i ${VM_KEY} -L 8443:${MINIKUBE_IP}:8443 ${VM_USER}@${VM_IP} -N &

# 터널 프로세스 확인
ps aux | grep ssh
```

## 6. 로컬의 kubeconfig 업데이트 (로컬에서 실행)

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

## 7. 연결 테스트

```bash
# 클러스터 정보 확인
kubectl cluster-info

# 노드 확인
kubectl get nodes

# 파드 확인
kubectl get pods -A
```

## 8. SSH 터널 관리

```bash
# 터널 종료
pkill -f "ssh -i ${VM_KEY} -L 8443"

# 터널 재시작
ssh -i ${VM_KEY} -L 8443:${MINIKUBE_IP}:8443 ${VM_USER}@${VM_IP} -N &
```

## 9. 편의를 위한 스크립트 (선택사항)

`~/.bashrc` 또는 `~/.zshrc`에 추가:

```bash
# Minikube 원격 접속 설정
export VM_IP=72.155.72.236
export VM_USER=azureuser
export VM_KEY=~/home/k8s_key.pem
export MINIKUBE_IP=192.168.49.2

# 터널 시작 함수
minikube-tunnel-start() {
  ssh -i ${VM_KEY} -L 8443:${MINIKUBE_IP}:8443 ${VM_USER}@${VM_IP} -N &
  echo "SSH tunnel started"
}

# 터널 종료 함수
minikube-tunnel-stop() {
  pkill -f "ssh -i ${VM_KEY} -L 8443"
  echo "SSH tunnel stopped"
}
```

사용법:
```bash
source ~/.bashrc
minikube-tunnel-start
minikube-tunnel-stop
```
