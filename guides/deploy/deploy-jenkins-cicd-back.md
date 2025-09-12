# 백엔드 Jenkins 파이프라인 작성 가이드

[요청사항]  
- Jenkins + Kustomize 기반 CI/CD 파이프라인 구축 가이드 작성  
- 환경별(dev/staging/prod) 매니페스트 관리 및 자동 배포 구현
- SonarQube 코드 품질 분석과 Quality Gate 포함
- '[결과파일]'에 구축 방법 및 파이프라인 작성 가이드 생성    
- 아래 작업은 실제 수행하여 파일 생성
  - Kustomize 디렉토리 구조 생성
  - Base Kustomization 작성
  - 환경별 Overlay 작성
  - 환경별 Patch 파일 생성
  - 환경별 설정 파일 작성
  - Jenkinsfile 작성
  - 수동 배포 스크립트 작성 

[작업순서]
- 사전 준비사항 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인  
  - {ACR명}: Azure Container Registry 이름 
  - {RESOURCE_GROUP}: Azure 리소스 그룹명
  - {AKS_CLUSTER}: AKS 클러스터명
  예시)
  ```
  [실행정보]
  - ACR명: acrdigitalgarage01
  - RESOURCE_GROUP: rg-digitalgarage-01
  - AKS_CLUSTER: aks-digitalgarage-01  
  ``` 
  
- 시스템명과 서비스명 확인   
  settings.gradle에서 확인.    
  - 시스템명: rootProject.name 
  - 서비스명: include 'common'하위의 include문 뒤의 값임 

  예시) include 'common'하위의 5개가 서비스명임.  
  ```
  rootProject.name = 'phonebill'

  include 'common'
  include 'api-gateway'
  include 'user-service'
  include 'bill-service'
  include 'product-service'
  include 'kos-mock'
  ```  

- Jenkins 서버 환경 구성 안내
  - Jenkins 설치 및 필수 플러그인 설치   
    ```
    # Jenkins 필수 플러그인 목록
    - Kubernetes
    - Pipeline Utility Steps
    - Docker Pipeline
    - GitHub
    - SonarQube Scanner
    - Azure Credentials
    ``` 
  
  - Jenkins Credentials 등록 방법 안내   
    ```
    # Azure Service Principal
    Manage Jenkins > Credentials > Add Credentials
    - Kind: Microsoft Azure Service Principal
    - ID: azure-credentials
    - Subscription ID: {구독ID}
    - Client ID: {클라이언트ID}
    - Client Secret: {클라이언트시크릿}
    - Tenant ID: {테넌트ID}
    - Azure Environment: Azure
    
    # ACR Credentials  
    - Kind: Username with password
    - ID: acr-credentials
    - Username: {ACR명}
    - Password: {ACR패스워드}

    # SonarQube Token
    - Kind: Secret text
    - ID: sonarqube-token
    - Secret: {SonarQube토큰}
    ```

- Kustomize 디렉토리 구조 생성      
  - 프로젝트 루트에 CI/CD 디렉토리 생성   
    ```
    mkdir -p deployment/cicd/kustomize/{base,overlays/{dev,staging,prod}}
    mkdir -p deployment/cicd/kustomize/base/{common,{서비스명1},{서비스명2},...}
    mkdir -p deployment/cicd/{config,scripts}
    ```
  - 기존 k8s 매니페스트를 base로 복사
    ```
    # 기존 deployment/k8s/* 파일들을 base로 복사
    cp deployment/k8s/common/* deployment/cicd/kustomize/base/common/
    cp deployment/k8s/{서비스명}/* deployment/cicd/kustomize/base/{서비스명}/
    
    # 네임스페이스 하드코딩 제거
    find deployment/cicd/kustomize/base -name "*.yaml" -exec sed -i 's/namespace: .*//' {} \;
    ``` 

- Base Kustomization 작성 
  `deployment/cicd/kustomize/base/kustomization.yaml` 파일 생성 방법 안내    
  ```yaml
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization

  metadata:
    name: {시스템명}-base

  resources:
    # Common resources
    - namespace.yaml
    - common/configmap-common.yaml
    - common/secret-common.yaml
    - common/secret-imagepull.yaml
    - common/ingress.yaml

    # 각 서비스별 리소스
    - {서비스명}/deployment.yaml
    - {서비스명}/service.yaml
    - {서비스명}/configmap.yaml
    - {서비스명}/secret.yaml

  commonLabels:
    app: {시스템명}
    version: v1

  images:
    - name: {ACR명}.azurecr.io/{시스템명}/{서비스명}
      newTag: latest
  ```

- 환경별 Overlay 작성  
  각 환경별로 `overlays/{환경}/kustomization.yaml` 생성  
  ```yaml
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization

  namespace: {시스템명}-{환경}

  resources:
    - ../../base

  patchesStrategicMerge:
    - configmap-common-patch.yaml
    - deployment-patch.yaml
    - ingress-patch.yaml
    - secret-common-patch.yaml
    - secret-{서비스명}-patch.yaml

  images:
    - name: {ACR명}.azurecr.io/{시스템명}/{서비스명}
      newTag: {환경}-latest

  namePrefix: {환경}-

  commonLabels:
    environment: {환경}
  ```

- 환경별 Patch 파일 생성
  각 환경별로 필요한 patch 파일들을 생성합니다.   
  **중요원칙**:  
  - **base 매니페스트에 없는 항목은 추가 않함**  
  - **base 매니페스트와 항목이 일치해야 함**  
  - Secret 매니페스트에 'data'가 아닌 'stringData'사용  
  
  **1. ConfigMap Common Patch 파일 생성**
  `deployment/cicd/kustomize/overlays/{환경}/configmap-common-patch.yaml`
  - base의 cm-common.yaml을 환경별로 오버라이드
  - 환경별 도메인, 프로파일, 데이터베이스 설정 변경
  - CORS_ALLOWED_ORIGINS를 환경별 도메인으로 설정
  - SPRING_PROFILES_ACTIVE를 환경에 맞게 설정 (dev/staging/prod)
  - DDL_AUTO 설정: dev는 "update", staging/prod는 "validate"
  - JWT 토큰 유효시간은 prod에서 보안을 위해 짧게 설정
  
  **2. Secret Common Patch 파일 생성**
  `deployment/cicd/kustomize/overlays/{환경}/secret-common-patch.yaml`
  - base의 secret-common.yaml을 환경별로 오버라이드  
  - 환경별 공통 시크릿 값들 설정
  - Redis 비밀번호, 데이터베이스 접속 정보 등
  
  **3. Ingress Patch 파일 생성**
  `deployment/cicd/kustomize/overlays/{환경}/ingress-patch.yaml`
  - base의 ingress.yaml을 환경별로 오버라이드
  - 환경별 도메인 설정: {시스템명}-{환경}.도메인 형식
  - service name을 namePrefix가 적용된 이름으로 변경 ({환경}-{서비스명})
  - prod 환경은 HTTPS 강제 적용 및 SSL 인증서 설정
  - staging/prod는 nginx.ingress.kubernetes.io/ssl-redirect: "true"
  - dev는 nginx.ingress.kubernetes.io/ssl-redirect: "false"
  
  **4. deployment Patch 파일 생성** ⚠️ **중요**
  `deployment/cicd/kustomize/overlays/{환경}/deployment-patch.yaml`
  
  **필수 포함 사항:**
  - ✅ **replicas 설정**: 각 서비스별 Deployment의 replica 수를 환경별로 설정
    - dev: 모든 서비스 1 replica (리소스 절약)
    - staging: 모든 서비스 2 replicas  
    - prod: 모든 서비스 3 replicas
  - ✅ **resources 설정**: 각 서비스별 Deployment의 resources를 환경별로 설정
    - dev: requests(256m CPU, 256Mi Memory), limits(1024m CPU, 1024Mi Memory)
    - staging: requests(512m CPU, 512Mi Memory), limits(2048m CPU, 2048Mi Memory)
    - prod: requests(1024m CPU, 1024Mi Memory), limits(4096m CPU, 4096Mi Memory)
  
  **작성 형식:**
  - **Strategic Merge Patch 형식** 사용 (JSON Patch 아님)
  - 각 서비스별로 별도의 Deployment 리소스로 분리하여 작성
  - replicas와 resources를 **반드시 모두** 포함
  
  **5. 서비스별 Secret Patch 파일 생성**
  `deployment/cicd/kustomize/overlays/{환경}/secret-{서비스명}-patch.yaml`
  - 각 서비스별 전용 시크릿 파일을 환경별로 오버라이드
  - 데이터베이스 접속 정보, API 키 등 서비스별 민감 정보
  - 환경별 데이터베이스 연결 정보 (dev/staging/prod DB 분리)
  - 외부 API 연동 정보 (환경별 엔드포인트, 인증키)
  
  **Patch 파일 작성 가이드라인:**
  - metadata.name은 base와 동일하게 유지 (Kustomize가 매칭)
  - 변경이 필요한 부분만 포함 (Strategic Merge Patch 방식)
  - 환경별 특성에 맞는 값들로 설정
  - 보안이 중요한 값들은 Secret으로, 일반 설정은 ConfigMap으로 분리
  - 각 환경의 리소스 사용량과 트래픽을 고려하여 replica 수 결정

- 환경별 설정 파일 작성    
  `deployment/cicd/config/deploy_env_vars_{환경}` 파일 생성 방법  
  ```bash
  # {환경} Environment Configuration
  resource_group={RESOURCE_GROUP}
  cluster_name={AKS_CLUSTER}
  ```

- Jenkinsfile 작성    
  `deployment/cicd/Jenkinsfile` 파일 생성 방법을 안내합니다.
  
  주요 구성 요소:
  - **Pod Template**: Gradle, Podman, Azure-CLI 컨테이너
  - **Build & Test**: Gradle 기반 빌드 및 단위 테스트
  - **SonarQube Analysis**: 코드 품질 분석 및 Quality Gate
  - **Container Build & Push**: 환경별 이미지 태그로 빌드 및 푸시
  - **Kustomize Deploy**: 환경별 매니페스트 적용
  - **Health Check**: 배포 후 서비스 상태 확인

  ```groovy
  def PIPELINE_ID = "${env.BUILD_NUMBER}"
  
  def getImageTag() {
      def dateFormat = new java.text.SimpleDateFormat('yyyyMMddHHmmss')
      def currentDate = new Date()
      return dateFormat.format(currentDate)
  }
  
  podTemplate(
      label: "${PIPELINE_ID}",
      serviceAccount: 'jenkins',
      containers: [
          containerTemplate(name: 'podman', image: "mgoltzsche/podman", ttyEnabled: true, command: 'cat', privileged: true),
          containerTemplate(name: 'gradle', image: 'gradle:jdk17', ttyEnabled: true, command: 'cat'),
          containerTemplate(name: 'azure-cli', image: 'hiondal/azure-kubectl:latest', command: 'cat', ttyEnabled: true)
      ]
  ) {
      node(PIPELINE_ID) {
          def props
          def imageTag = getImageTag()
          def environment = params.ENVIRONMENT ?: 'dev'
          def services = ['{서비스명1}', '{서비스명2}', '{서비스명3}']
          
          stage("Get Source") {
              checkout scm
              props = readProperties file: "deployment/cicd/config/deploy_env_vars_${environment}"
          }

          stage("Setup AKS") {
              container('azure-cli') {
                  withCredentials([azureServicePrincipal('azure-credentials')]) {
                      sh """
                          az login --service-principal -u \$AZURE_CLIENT_ID -p \$AZURE_CLIENT_SECRET -t \$AZURE_TENANT_ID
                          az aks get-credentials --resource-group \${props.resource_group} --name \${props.cluster_name} --overwrite-existing
                          kubectl create namespace {시스템명}-\${environment} --dry-run=client -o yaml | kubectl apply -f -
                      """
                  }
              }
          }

          stage('Build & SonarQube Analysis') {
              container('gradle') {
                  withSonarQubeEnv('SonarQube') {
                      sh """
                          chmod +x gradlew
                          ./gradlew build -x test
                          
                          # 각 서비스별 테스트 및 분석
                          ./gradlew :{서비스명}:test :{서비스명}:jacocoTestReport :{서비스명}:sonar \\
                              -Dsonar.projectKey={시스템명}-{서비스명}-\${environment} \\
                              -Dsonar.projectName={시스템명}-{서비스명}
                      """
                  }
              }
          }

          stage('Quality Gate') {
              timeout(time: 10, unit: 'MINUTES') {
                  def qg = waitForQualityGate()
                  if (qg.status != 'OK') {
                      error "Pipeline aborted due to quality gate failure: \${qg.status}"
                  }
              }
          }

          stage('Build & Push Images') {
              container('podman') {
                  withCredentials([usernamePassword(
                      credentialsId: 'acr-credentials',
                      usernameVariable: 'USERNAME',
                      passwordVariable: 'PASSWORD'
                  )]) {
                      sh "podman login {ACR명}.azurecr.io --username \$USERNAME --password \$PASSWORD"

                      services.each { service ->
                          sh """
                              podman build \\
                                  --build-arg BUILD_LIB_DIR="\${service}/build/libs" \\
                                  --build-arg ARTIFACTORY_FILE="\${service}.jar" \\
                                  -f deployment/container/Dockerfile \\
                                  -t {ACR명}.azurecr.io/{시스템명}/\${service}:\${environment}-\${imageTag} .

                              podman push {ACR명}.azurecr.io/{시스템명}/\${service}:\${environment}-\${imageTag}
                          """
                      }
                  }
              }
          }

          stage('Update Kustomize & Deploy') {
              container('azure-cli') {
                  sh """
                      # Kustomize 설치
                      curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
                      sudo mv kustomize /usr/local/bin/

                      # 환경별 디렉토리로 이동
                      cd deployment/cicd/kustomize/overlays/\${environment}

                      # 이미지 태그 업데이트
                      services.each { service ->
                          sh "kustomize edit set image {ACR명}.azurecr.io/{시스템명}/\${service}:\${environment}-\${imageTag}"
                      }

                      # 매니페스트 적용
                      kubectl apply -k .

                      echo "Waiting for deployments to be ready..."
                      services.each { service ->
                          sh "kubectl -n {시스템명}-\${environment} wait --for=condition=available deployment/\${environment}-\${service} --timeout=300s"
                      }
                  """
              }
          }

          stage('Health Check') {
              container('azure-cli') {
                  sh """
                      echo "🔍 Health Check starting..."
                      
                      # API Gateway Health Check (첫 번째 서비스로 가정)
                      GATEWAY_POD=\$(kubectl get pod -n {시스템명}-\${environment} -l app={첫번째서비스명} -o jsonpath='{.items[0].metadata.name}')
                      kubectl -n {시스템명}-\${environment} exec \$GATEWAY_POD -- curl -f http://localhost:8080/health || exit 1
                      
                      echo "✅ All services are healthy!"
                  """
              }
          }
      }
  }
  ```

- Jenkins Pipeline Job 생성 방법 안내    
  - Jenkins 웹 UI에서 New Item > Pipeline 선택
  - Pipeline script from SCM 설정 방법:
    ```
    SCM: Git
    Repository URL: {Git저장소URL}
    Branch: main (또는 develop)
    Script Path: deployment/cicd/Jenkinsfile
    ```
  - Pipeline Parameters 설정:
    ```
    ENVIRONMENT: Choice Parameter (dev, staging, prod)
    IMAGE_TAG: String Parameter (default: latest)
    ```

- SonarQube 프로젝트 설정 방법 작성 
  - SonarQube에서 각 서비스별 프로젝트 생성
  - Quality Gate 설정:
    ```
    Coverage: >= 80%
    Duplicated Lines: <= 3%
    Maintainability Rating: <= A
    Reliability Rating: <= A
    Security Rating: <= A
    ```

- 배포 실행 방법 작성    
  - Jenkins 파이프라인 실행:
    ```
    1. Jenkins > {프로젝트명} > Build with Parameters
    2. ENVIRONMENT 선택 (dev/staging/prod)
    3. IMAGE_TAG 입력 (선택사항)
    4. Build 클릭
    ```
  - 배포 상태 확인:
    ```
    kubectl get pods -n {시스템명}-{환경}
    kubectl get services -n {시스템명}-{환경}
    kubectl get ingress -n {시스템명}-{환경}
    ```

- 수동 배포 스크립트 작성
  `deployment/cicd/scripts/deploy.sh` 파일 생성:
  ```bash
  #!/bin/bash
  set -e

  ENVIRONMENT=${1:-dev}
  IMAGE_TAG=${2:-latest}

  # 환경별 이미지 태그 업데이트
  cd deployment/cicd/kustomize/overlays/${ENVIRONMENT}
  
  # 각 서비스 이미지 태그 업데이트
  kustomize edit set image {ACR명}.azurecr.io/{시스템명}/{서비스명1}:${ENVIRONMENT}-${IMAGE_TAG}
  kustomize edit set image {ACR명}.azurecr.io/{시스템명}/{서비스명2}:${ENVIRONMENT}-${IMAGE_TAG}
  
  # 배포 실행
  kubectl apply -k .
  
  # 배포 상태 확인
  kubectl rollout status deployment/${ENVIRONMENT}-{서비스명1} -n {시스템명}-${ENVIRONMENT}
  kubectl rollout status deployment/${ENVIRONMENT}-{서비스명2} -n {시스템명}-${ENVIRONMENT}
  
  echo "✅ Deployment completed successfully!"
  ```

- 롤백 방법 작성
  - 이전 버전으로 롤백:
    ```bash
    # 특정 버전으로 롤백
    kubectl rollout undo deployment/{환경}-{서비스명} -n {시스템명}-{환경} --to-revision=2
    
    # 롤백 상태 확인
    kubectl rollout status deployment/{환경}-{서비스명} -n {시스템명}-{환경}
    ```
  - 이미지 태그 기반 롤백:
    ```bash
    # 이전 안정 버전 이미지 태그로 업데이트
    cd deployment/cicd/kustomize/overlays/{환경}
    kustomize edit set image {ACR명}.azurecr.io/{시스템명}/{서비스명}:{환경}-{이전태그}
    kubectl apply -k .
    ```

[체크리스트]
Jenkins CI/CD 파이프라인 구축 작업을 누락 없이 진행하기 위한 체크리스트입니다.

## 📋 사전 준비 체크리스트
- [ ] settings.gradle에서 시스템명과 서비스명 확인 완료
- [ ] 실행정보 섹션에서 ACR명, 리소스 그룹, AKS 클러스터명 확인 완료

## 📂 Kustomize 구조 생성 체크리스트  
- [ ] 디렉토리 구조 생성: `deployment/cicd/kustomize/{base,overlays/{dev,staging,prod}}`
- [ ] 서비스별 base 디렉토리 생성: `deployment/cicd/kustomize/base/{common,{서비스명들}}`
- [ ] 기존 k8s 매니페스트를 base로 복사 완료
- [ ] Base kustomization.yaml 파일 생성 완료

## 🔧 환경별 Overlay 구성 체크리스트
### 공통 체크 사항
- **base 매니페스트에 없는 항목을 추가하지 않았는지 체크**  
- **base 매니페스트와 항목이 일치 하는지 체크** 
- Secret 매니페스트에 'data'가 아닌 'stringData'사용했는지 체크  

### DEV 환경
- [ ] `overlays/dev/kustomization.yaml` 생성 완료
- [ ] `overlays/dev/configmap-common-patch.yaml` 생성 완료 (dev 프로파일, update DDL)
- [ ] `overlays/dev/secret-common-patch.yaml` 생성 완료  
- [ ] `overlays/dev/ingress-patch.yaml` 생성 완료 (dev 도메인, HTTP)
- [ ] `overlays/dev/deployment-patch.yaml` 생성 완료 (replicas, resources 지정)
- [ ] 각 서비스별 `overlays/dev/secret-{서비스명}-patch.yaml` 생성 완료

### STAGING 환경  
- [ ] `overlays/staging/kustomization.yaml` 생성 완료
- [ ] `overlays/staging/configmap-common-patch.yaml` 생성 완료 (staging 프로파일, validate DDL)
- [ ] `overlays/staging/secret-common-patch.yaml` 생성 완료
- [ ] `overlays/staging/ingress-patch.yaml` 생성 완료 (staging 도메인, HTTPS)  
- [ ] `overlays/staging/deployment-patch.yaml` 생성 완료 (replicas, resources 지정)
- [ ] 각 서비스별 `overlays/staging/secret-{서비스명}-patch.yaml` 생성 완료

### PROD 환경
- [ ] `overlays/prod/kustomization.yaml` 생성 완료  
- [ ] `overlays/prod/configmap-common-patch.yaml` 생성 완료 (prod 프로파일, validate DDL, 짧은 JWT)
- [ ] `overlays/prod/secret-common-patch.yaml` 생성 완료
- [ ] `overlays/prod/ingress-patch.yaml` 생성 완료 (prod 도메인, HTTPS, SSL 인증서)
- [ ] `overlays/prod/deployment-patch.yaml` 생성 완료 (replicas, resources 지정)
- [ ] 각 서비스별 `overlays/prod/secret-{서비스명}-patch.yaml` 생성 완료

## ⚙️ 설정 및 스크립트 체크리스트
- [ ] 환경별 설정 파일 생성: `config/deploy_env_vars_{dev,staging,prod}`
- [ ] `Jenkinsfile` 생성 완료 (Pod Template, Build, SonarQube, Deploy 단계 포함)
- [ ] 수동 배포 스크립트 `scripts/deploy.sh` 생성 완료
- [ ] 스크립트 실행 권한 설정 완료 (`chmod +x scripts/deploy.sh`)

[결과파일]
- 가이드: deployment/cicd/jenkins-pipeline-guide.md
- 환경별 설정 파일: deployment/cicd/config/*
- Kustomize 파일: deployment/cicd/kustomize/*
- 수동배포 스크립트: deployment/cicd/scripts
- Jenkins 스크립트: deployment/cicd/Jenkinsfile
