# deploy-actions-cicd-back.md 범용화 계획

## 개요
`guides/deploy/deploy-actions-cicd-back.md` 파일이 Azure(ACR/AKS)에 특화되어 있어, `deploy-jenkins-cicd-back.md`처럼 범용적으로 사용할 수 있도록 수정이 필요합니다.

## 변경 대상 항목

### 1. 실행정보 섹션 변경 (라인 19-32)

**현재 (Azure 특화)**:
```
- {ACR_NAME}: Azure Container Registry 이름
- {RESOURCE_GROUP}: Azure 리소스 그룹명
- {AKS_CLUSTER}: AKS 클러스터명
- {NAMESPACE}: Namespace명

예시)
- ACR_NAME: acrdigitalgarage01
- RESOURCE_GROUP: rg-digitalgarage-01
- AKS_CLUSTER: aks-digitalgarage-01
- NAMESPACE: phonebill-dg0500
```

**변경 후 (범용)**:
```
- Image Registry: container image registry
- Image Organization: container image organization
- NAMESPACE: 네임스페이스

예시)
- Image Registry: docker.io
- Image Organization: phonebill
- NAMESPACE: phonebill
```

---

### 2. GitHub Repository Secrets 설정 변경 (라인 62-115)

**현재 (Azure 특화)**:
- AZURE_CREDENTIALS (Azure Service Principal)
- ACR_USERNAME / ACR_PASSWORD

**변경 후 (범용)**:
- acr-credentials -> imagereg-credentials로 변경  
```
# Image Registry Credentials
IMG_USERNAME: {이미지레지스트리_사용자명}
IMG_PASSWORD: {이미지레지스트리_패스워드}
```

---

### 3. Base Kustomization images 섹션 변경 (라인 171-173)

**현재**:
```yaml
images:
  - name: {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}
    newTag: latest
```

**변경 후**:
```yaml
images:
  - name: {Image Registry}/{Image Organization}/{SERVICE_NAME}
    newTag: latest
```

---

### 4. 환경별 Overlay images 섹션 변경 (라인 274-276)

**현재**:
```yaml
images:
  - name: {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}
    newTag: {ENVIRONMENT}-latest
```

**변경 후**:
```yaml
images:
  - name: {Image Registry}/{Image Organization}/{SERVICE_NAME}
    newTag: {ENVIRONMENT}-latest
```

---

### 5. GitHub Actions 워크플로우 변경 (라인 289-563)

#### 5.1 env 섹션 변경 (라인 324-328)

**현재**:
```yaml
env:
  REGISTRY: ${{ secrets.REGISTRY }}
  IMAGE_ORG: ${{ secrets.IMAGE_ORG }}
  RESOURCE_GROUP: ${{ secrets.RESOURCE_GROUP }}
  AKS_CLUSTER: ${{ secrets.AKS_CLUSTER }}
```

**변경 후**:
```yaml
env:
  REGISTRY: ${{ secrets.REGISTRY }}
  IMAGE_ORG: ${{ secrets.IMAGE_ORG }}
```

#### 5.2 Load environment variables 변경 (라인 356-391)

**현재**: Azure 특화 변수(RESOURCE_GROUP, AKS_CLUSTER) 로드

**변경 후**: namespace만 로드하도록 간소화
```yaml
- name: Load environment variables
  id: env_vars
  run: |
    ENV=${{ steps.determine_env.outputs.environment }}

    # Read environment variables from .github/config file
    if [[ -f ".github/config/deploy_env_vars_${ENV}" ]]; then
      source ".github/config/deploy_env_vars_${ENV}"
    fi

    echo "NAMESPACE=$namespace" >> $GITHUB_ENV
```

#### 5.3 Login to Azure Container Registry 변경 (라인 477-482)

**현재**:
```yaml
- name: Login to Azure Container Registry
  uses: docker/login-action@v3
  with:
    registry: ${{ env.REGISTRY }}
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}
```

**변경 후**:
```yaml
- name: Login to Image Registry
  uses: docker/login-action@v3
  with:
    registry: ${{ env.REGISTRY }}
    username: ${{ secrets.IMG_USERNAME }}
    password: ${{ secrets.IMG_PASSWORD }}
```

#### 5.4 Deploy job - Azure 관련 부분 제거 (라인 501-533)

**제거할 항목**:
- Install Azure CLI 단계
- Azure Login 단계
- Get AKS Credentials 단계

**변경 후**: kubeconfig 설정은 self-hosted runner 또는 GitHub Secrets에서 KUBECONFIG로 관리
```yaml
- name: Setup kubectl
  uses: azure/setup-kubectl@v3

- name: Configure Kubernetes
  run: |
    echo "${{ secrets.KUBECONFIG }}" > $HOME/.kube/config
    chmod 600 $HOME/.kube/config
```

---

### 6. 환경별 설정 파일 변경 (라인 566-588)

**현재**:
```bash
# {환경} Environment Configuration
resource_group={RESOURCE_GROUP}
cluster_name={AKS_CLUSTER}
```

**변경 후**:
```bash
# {환경} Environment Configuration
namespace={NAMESPACE}
```

---

### 7. 수동 배포 스크립트 변경 (라인 592-658)

#### 7.1 이미지 태그 업데이트 명령 변경 (라인 634)

**현재**:
```bash
kustomize edit set image {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/$service:${ENVIRONMENT}-${IMAGE_TAG}
```

**변경 후**:
```bash
kustomize edit set image {Image Registry}/{Image Organization}/$service:${ENVIRONMENT}-${IMAGE_TAG}
```

---

### 8. 체크리스트 변경 (라인 696-699)

**현재**:
```
- [ ] 실행정보 섹션에서 ACR명, 리소스 그룹, AKS 클러스터명 확인 완료
```

**변경 후**:
```
- [ ] 실행정보 섹션에서 Image Registry, Image Organization 확인 완료
```

---

## 추가 작업

### Azure 전용 가이드 분리
`deploy-jenkins-cicd-back.md`처럼 Azure 전용 가이드를 별도 파일로 분리:
- 파일명: `deploy-actions-cicd-back-azure.md`
- 내용: 현재 `deploy-actions-cicd-back.md`의 Azure 특화 내용 보존

---

## 변경 요약 테이블

| 항목 | 현재 (Azure) | 변경 후 (범용) |
|------|-------------|---------------|
| Container Registry | ACR_NAME.azurecr.io | Image Registry |
| 이미지 조직 | SYSTEM_NAME | Image Organization |
| 클러스터 인증 | Azure Service Principal | KUBECONFIG Secret |
| 환경변수 | resource_group, cluster_name | namespace |
| Registry Credentials | ACR_USERNAME/PASSWORD | IMG_USERNAME/PASSWORD |

---

## 참고 파일
- 범용 Jenkins 가이드: `guides/deploy/deploy-jenkins-cicd-back.md`
- Azure 전용 Jenkins 가이드: `guides/deploy/deploy-jenkins-cicd-back-azure.md`
