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
- 작업 완료 후 '[체크리스트]'대로 검사 
 
[작업순서]
- 사전 준비사항 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인
  - {ACR_NAME}: Azure Container Registry 이름
  - {RESOURCE_GROUP}: Azure 리소스 그룹명
  - {AKS_CLUSTER}: AKS 클러스터명
    예시)
  ```
  [실행정보]
  - ACR_NAME: myproject-acr
  - RESOURCE_GROUP: rg-myproject-01
  - AKS_CLUSTER: aks-myproject-01
  ``` 

- 시스템명과 서비스명 확인   
  settings.gradle에서 확인.
  - {SYSTEM_NAME}: rootProject.name
  - {SERVICE_NAMES}: include 'common'하위의 include문 뒤의 값임

  예시) include 'common'하위의 서비스명들.
  ```
  rootProject.name = 'myproject'

  include 'common'
  include 'api-gateway'
  include 'user-service'
  include 'order-service'
  include 'payment-service'
  ```  

- JDK버전 확인
  루트 build.gradle에서 JDK 버전 확인.   
  {JDK_VERSION}: 'java' 섹션에서 JDK 버전 확인. 아래 예에서는 21임.
  ```
  java {
      toolchain {
          languageVersion = JavaLanguageVersion.of(21)
      }
  }
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
    - Username: {ACR_NAME}
    - Password: {ACR_PASSWORD}

    # SonarQube Token
    - Kind: Secret text
    - ID: sonarqube-token
    - Secret: {SonarQube토큰}
    ```

- Kustomize 디렉토리 구조 생성
  - 프로젝트 루트에 CI/CD 디렉토리 생성
    ```
    mkdir -p deployment/cicd/kustomize/{base,overlays/{dev,staging,prod}}
    mkdir -p deployment/cicd/kustomize/base/{common,{SERVICE_NAME_1},{SERVICE_NAME_2},...}
    mkdir -p deployment/cicd/{config,scripts}
    ```
  - 기존 k8s 매니페스트를 base로 복사
    ```
    # 기존 deployment/k8s/* 파일들을 base로 복사
    cp deployment/k8s/common/* deployment/cicd/kustomize/base/common/
    cp deployment/k8s/{SERVICE_NAME}/* deployment/cicd/kustomize/base/{SERVICE_NAME}/
    
    # 네임스페이스 하드코딩 제거
    find deployment/cicd/kustomize/base -name "*.yaml" -exec sed -i 's/namespace: .*//' {} \;
    ``` 

- Base Kustomization 작성
  `deployment/cicd/kustomize/base/kustomization.yaml` 파일 생성 방법 안내
  ```yaml
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization

  metadata:
    name: {SYSTEM_NAME}-base

  resources:
    # Common resources
    - namespace.yaml
    - common/configmap-common.yaml
    - common/secret-common.yaml
    - common/secret-imagepull.yaml
    - common/ingress.yaml

    # 각 서비스별 리소스
    - {SERVICE_NAME}/deployment.yaml
    - {SERVICE_NAME}/service.yaml
    - {SERVICE_NAME}/configmap.yaml
    - {SERVICE_NAME}/secret.yaml

  commonLabels:
    app: {SYSTEM_NAME}
    version: v1

  images:
    - name: {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}
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

  patches:
    - path: configmap-common-patch.yaml
      target:
        kind: ConfigMap
        name: cm-common
    - path: deployment-{서비스명}-patch.yaml
      target:
        kind: Deployment
        name: {서비스명}
    - path: ingress-patch.yaml
      target:
        kind: Ingress
        name: {시스템명}-ingress
    - path: secret-common-patch.yaml
      target:
        kind: Secret
        name: secret-common
    - path: secret-{서비스명}-patch.yaml
      target:
        kind: Secret
        name: secret-{서비스명}

  images:
    - name: {ACR명}.azurecr.io/{시스템명}/{서비스명}
      newTag: {환경}-latest

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
  - CORS_ALLOWED_ORIGINS를 환경별 도메인으로 설정. 기본값은 base의 cm-common.yaml과 동일하게 함
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
  - 개발환경 Ingress Host의 기본값은 base의 ingress.yaml과 동일하게 함
  - Staging/Prod 환경별 도메인 설정: {시스템명}.도메인 형식
  - service name을 '{서비스명}'으로 함.
  - Staging/prod 환경은 HTTPS 강제 적용 및 SSL 인증서 설정
  - staging/prod는 nginx.ingress.kubernetes.io/ssl-redirect: "true"
  - dev는 nginx.ingress.kubernetes.io/ssl-redirect: "false"

  **4. deployment Patch 파일 생성** ⚠️ **중요**
  각 서비스별로 별도 파일 생성
  `deployment/cicd/kustomize/overlays/{환경}/deployment-{서비스명}-patch.yaml`

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
  - base의 각 서비스별 secret-{서비스명}.yaml을 환경별로 오버라이드
  - 기본값은 base의 secret-{서비스명}.yaml과 동일하게 함

- -

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
  - **SonarQube Analysis**: services.each 루프를 통한 각 서비스별 코드 품질 분석 및 Quality Gate
  - **Container Build & Push**: 30분 timeout 설정과 함께 환경별 이미지 태그로 빌드 및 푸시
  - **Kustomize Deploy**: 환경별 매니페스트 적용

  **🔧 최신 최적화 사항**:
  - **Jenkins Pod Template 최적화**: timeout 설정(slaveConnectTimeout: 300, idleMinutes: 30, activeDeadlineSeconds: 3600)
  - **리소스 제한 설정**: 각 컨테이너별 CPU/Memory request/limit 설정으로 안정성 향상
  - **Tolerations 설정**: CICD 전용 노드에서 실행하도록 설정 (dedicated=cicd)
  - **Kustomize 설치 최적화**: sudo 없이 사용자 홈 디렉토리에 설치하여 권한 문제 해결
  - **Patch 방법 변경**: `patchesStrategicMerge` → `patches` (최신 문법, target 명시)
  - **SonarQube 분석 최적화**: 반복 코드를 services.each 루프로 통합하여 유지보수성 향상
  - **Docker 빌드 안정성**: 30분 timeout 설정으로 Jenkins 에이전트 연결 끊김 방지
  - **코드 간소화**: 40줄 → 13줄로 대폭 단축, 새 서비스 추가 시 services 배열에만 추가

  **⚠️ 중요: 변수 참조 문법**
  Jenkins Groovy에서 bash shell로 변수 전달 시:
  - **올바른 문법**: `${variable}` (Groovy 문자열 보간)
  - **잘못된 문법**: `\${variable}` (bash 특수문자 이스케이프로 인한 "syntax error: bad substitution" 오류)

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
      slaveConnectTimeout: 300,
      idleMinutes: 30,
      activeDeadlineSeconds: 3600,
      podRetention: never(),  // 파드 자동 정리 옵션: never(), onFailure(), always(), default()
      yaml: '''
          spec:
            tolerations:
            - effect: NoSchedule
              key: dedicated
              operator: Equal
              value: cicd
      ''',
      containers: [
          containerTemplate(
              name: 'podman', 
              image: "mgoltzsche/podman", 
              ttyEnabled: true, 
              command: 'cat', 
              privileged: true,
              resourceRequestCpu: '500m',
              resourceRequestMemory: '2Gi',
              resourceLimitCpu: '2000m',
              resourceLimitMemory: '4Gi'
          ),
          containerTemplate(
              name: 'gradle',
              image: 'gradle:jdk{JDK버전}',
              ttyEnabled: true,
              command: 'cat',
              resourceRequestCpu: '500m',
              resourceRequestMemory: '1Gi',
              resourceLimitCpu: '1000m',
              resourceLimitMemory: '2Gi',
              envVars: [
                  envVar(key: 'DOCKER_HOST', value: 'unix:///run/podman/podman.sock'),
                  envVar(key: 'TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE', value: '/run/podman/podman.sock'),
                  envVar(key: 'TESTCONTAINERS_RYUK_DISABLED', value: 'true')
              ]
          ),
          containerTemplate(
              name: 'azure-cli', 
              image: 'hiondal/azure-kubectl:latest', 
              command: 'cat', 
              ttyEnabled: true,
              resourceRequestCpu: '200m',
              resourceRequestMemory: '512Mi',
              resourceLimitCpu: '500m',
              resourceLimitMemory: '1Gi'
          )
      ],
      volumes: [
          emptyDirVolume(mountPath: '/home/gradle/.gradle', memory: false),
          emptyDirVolume(mountPath: '/root/.azure', memory: false),
          emptyDirVolume(mountPath: '/run/podman', memory: false)
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
                          az aks get-credentials --resource-group ${props.resource_group} --name ${props.cluster_name} --overwrite-existing
                          kubectl create namespace {시스템명}-${environment} --dry-run=client -o yaml | kubectl apply -f -
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
                      """
                      
                      // 각 서비스별 테스트 및 SonarQube 분석
                      services.each { service ->
                          sh """
                              ./gradlew :${service}:test :${service}:jacocoTestReport :${service}:sonar \\
                                  -Dsonar.projectKey={시스템명}-${service}-${environment} \\
                                  -Dsonar.projectName={시스템명}-${service}-${environment} \\
                                  -Dsonar.java.binaries=build/classes/java/main \\
                                  -Dsonar.coverage.jacoco.xmlReportPaths=build/reports/jacoco/test/jacocoTestReport.xml \\
                                  -Dsonar.exclusions=**/config/**,**/entity/**,**/dto/**,**/*Application.class,**/exception/**
                          """
                      }
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
              timeout(time: 30, unit: 'MINUTES') {
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
                                      --build-arg BUILD_LIB_DIR="${service}/build/libs" \\
                                      --build-arg ARTIFACTORY_FILE="${service}.jar" \\
                                      -f deployment/container/Dockerfile-backend \\
                                      -t {ACR명}.azurecr.io/{시스템명}/${service}:${environment}-${imageTag} .

                                  podman push {ACR명}.azurecr.io/{시스템명}/${service}:${environment}-${imageTag}
                              """
                          }
                      }
                  }
              }
          }

          stage('Update Kustomize & Deploy') {
              container('azure-cli') {
                  sh """
                      # Kustomize 설치 (sudo 없이 사용자 디렉토리에 설치)
                      curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
                      mkdir -p \$HOME/bin
                      mv kustomize \$HOME/bin/
                      export PATH=\$PATH:\$HOME/bin

                      # 환경별 디렉토리로 이동
                      cd deployment/cicd/kustomize/overlays/${environment}

                      # 이미지 태그 업데이트
                      services.each { service ->
                          sh "kustomize edit set image {ACR명}.azurecr.io/{시스템명}/${service}:${environment}-${imageTag}"
                      }

                      # 매니페스트 적용
                      kubectl apply -k .

                      echo "Waiting for deployments to be ready..."
                      services.each { service ->
                          sh "kubectl -n {시스템명}-${environment} wait --for=condition=available deployment/${service} --timeout=300s"
                      }
                  """
              }
          }
          
          // 파이프라인 완료 로그 (Scripted Pipeline 방식)
          stage('Pipeline Complete') {
              echo "🧹 Pipeline completed. Pod cleanup handled by Jenkins Kubernetes Plugin."
              
              // 성공/실패 여부 로깅
              if (currentBuild.result == null || currentBuild.result == 'SUCCESS') {
                  echo "✅ Pipeline completed successfully!"
              } else {
                  echo "❌ Pipeline failed with result: ${currentBuild.result}"
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
  
  # 각 서비스 이미지 태그 업데이트 (실제 서비스명으로 교체)
  for service in {서비스명1} {서비스명2} {서비스명3}; do
      kustomize edit set image {ACR명}.azurecr.io/{시스템명}/${service}:${ENVIRONMENT}-${IMAGE_TAG}
  done
  
  # 배포 실행
  kubectl apply -k .
  
  # 배포 상태 확인 (실제 서비스명으로 교체)
  for service in {서비스명1} {서비스명2} {서비스명3}; do
      kubectl rollout status deployment/${service} -n {시스템명}-${ENVIRONMENT}
  done
  
  echo "✅ Deployment completed successfully!"
  ```

- 롤백 방법 작성
  - 이전 버전으로 롤백:
    ```bash
    # 특정 버전으로 롤백
    kubectl rollout undo deployment/{서비스명} -n {시스템명}-{환경} --to-revision=2
    
    # 롤백 상태 확인
    kubectl rollout status deployment/{서비스명} -n {시스템명}-{환경}
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
- [ ] 루트 build.gradle에서 JDK버전 확인 완료
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
- **⚠️ Kustomize patch 방법 변경**: `patchesStrategicMerge` → `patches` (target 명시)

### DEV 환경
- [ ] `overlays/dev/kustomization.yaml` 생성 완료
- [ ] `overlays/dev/configmap-common-patch.yaml` 생성 완료 (dev 프로파일, update DDL)
- [ ] `overlays/dev/secret-common-patch.yaml` 생성 완료
- [ ] `overlays/dev/ingress-patch.yaml` 생성 완료 (Host 기본값은 base의 ingress.yaml과 동일)
- [ ] `overlays/dev/deployment-patch.yaml` 생성 완료 (replicas, resources 지정)
- [ ] 각 서비스별 `overlays/dev/secret-{서비스명}-patch.yaml` 생성 완료

### STAGING 환경
- [ ] `overlays/staging/kustomization.yaml` 생성 완료
- [ ] `overlays/staging/configmap-common-patch.yaml` 생성 완료 (staging 프로파일, validate DDL)
- [ ] `overlays/staging/secret-common-patch.yaml` 생성 완료
- [ ] `overlays/staging/ingress-patch.yaml` 생성 완료 (prod 도메인, HTTPS, SSL 인증서)
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
- [ ] `Jenkinsfile` 생성 완료
- [ ] `Jenkinsfile` 주요 내용 확인
  - Pod Template, Build, SonarQube, Deploy 단계 포함
  - gradle 컨테이너 이미지 이름에 올바른 JDK버전 사용: gradle:jdk{JDK버전}
  - 변수 참조 문법 확인: `${variable}` 사용, `\${variable}` 사용 금지
  - 모든 서비스명이 실제 프로젝트 서비스명으로 치환되었는지 확인
- [ ] 수동 배포 스크립트 `scripts/deploy.sh` 생성 완료
- [ ] 스크립트 실행 권한 설정 완료 (`chmod +x scripts/deploy.sh`)

[결과파일]
- 가이드: deployment/cicd/jenkins-pipeline-guide.md
- 환경별 설정 파일: deployment/cicd/config/*
- Kustomize 파일: deployment/cicd/kustomize/*
- 수동배포 스크립트: deployment/cicd/scripts
- Jenkins 스크립트: deployment/cicd/Jenkinsfile
