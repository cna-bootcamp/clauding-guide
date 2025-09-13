# 프론트엔드 Jenkins 파이프라인 작성 가이드

[요청사항]
- Jenkins + Kustomize 기반 CI/CD 파이프라인 구축 가이드 작성
- 환경별(dev/staging/prod) 매니페스트 관리 및 자동 배포 구현
- SonarQube 코드 품질 분석과 Quality Gate 포함
- Node.js 기반 빌드 및 컨테이너 이미지 생성
- '[결과파일]'에 구축 방법 및 파이프라인 작성 가이드 생성
- 아래 작업은 실제 수행하여 파일 생성
  - ESLint 설정 파일 작성
  - Kustomize 디렉토리 구조 생성
  - Base Kustomization 작성
  - 환경별 Overlay 작성
  - 환경별 Patch 파일 생성
  - 환경별 설정 파일 작성
  - Jenkinsfile 작성
  - 수동 배포 스크립트 작성

[작업순서]
- 프롬프트 제공정보 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인
  - {SYSTEM_NAME}: 시스템명 
  - {ACR_NAME}: Azure Container Registry 이름
  - {RESOURCE_GROUP}: Azure 리소스 그룹명
  - {AKS_CLUSTER}: AKS 클러스터명
    예시)
  ```
  [실행정보]
  - SYSTEM-NAME: phonebill
  - ACR_NAME: acrdigitalgarage01
  - RESOURCE_GROUP: rg-digitalgarage-01
  - AKS_CLUSTER: aks-digitalgarage-01
  ``` 

- 서비스명 확인   
  서비스명은 package.json에서 확인.
  - {SERVICE_NAME}: package.json의 "name" 필드
  예시)
  ```json
  {
    ...
    "name": "phonebill-front",
    ...
  }

- Jenkins 서버 환경 구성 안내
  - Jenkins 설치 및 필수 플러그인
  Jenkins 필수 플러그인 목록:
  ```
  - Kubernetes
  - Pipeline Utility Steps
  - Docker Pipeline
  - GitHub
  - SonarQube Scanner
  - Azure Credentials
  - EnvInject Plugin
  ```

  - Jenkins Credentials 등록
    - Azure Service Principal
    ```
    Manage Jenkins > Credentials > Add Credentials
    - Kind: Microsoft Azure Service Principal
    - ID: azure-credentials
    - Subscription ID: {구독ID}
    - Client ID: {클라이언트ID}
    - Client Secret: {클라이언트시크릿}
    - Tenant ID: {테넌트ID}
    - Azure Environment: Azure
    ```

    - ACR Credentials
    ```
    - Kind: Username with password
    - ID: acr-credentials
    - Username: {ACR_NAME}
    - Password: {ACR_PASSWORD}
    ```

    - Docker Hub Credentials (Rate Limit 해결용)
    ```
    - Kind: Username with password
    - ID: dockerhub-credentials
    - Username: {DOCKERHUB_USERNAME}
    - Password: {DOCKERHUB_PASSWORD}
    참고: Docker Hub 무료 계정 생성 (https://hub.docker.com)
    ```

    - SonarQube Token
    ```
    - Kind: Secret text
    - ID: sonarqube-token
    - Secret: {SonarQube토큰}
    ```

- ESLint 설정 파일 작성
  TypeScript React 프로젝트를 위한 `.eslintrc.cjs` 파일을 프로젝트 루트에 생성합니다.
  
  **⚠️ 중요**: ES 모듈 프로젝트에서는 `.eslintrc.cjs` 확장자 사용 필수
  
  ```javascript
  module.exports = {
    root: true,
    env: { browser: true, es2020: true },
    extends: [
      'eslint:recommended',
      'plugin:@typescript-eslint/recommended',
      'plugin:react-hooks/recommended',
    ],
    ignorePatterns: ['dist', '.eslintrc.cjs'],
    parser: '@typescript-eslint/parser',
    plugins: ['react-refresh', '@typescript-eslint'],
    rules: {
      'react-refresh/only-export-components': [
        'warn',
        { allowConstantExport: true },
      ],
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'warn',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
    },
  }
  ```

  **package.json lint 스크립트 수정** (max-warnings 20으로 설정):
  ```json
  {
    "scripts": {
      "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 20"
    }
  }
  ```

- Kustomize 디렉토리 구조 생성
  - 프로젝트 루트에 CI/CD 디렉토리 생성
    ```
    mkdir -p deployment/cicd/kustomize/{base,overlays/{dev,staging,prod}}
    mkdir -p deployment/cicd/kustomize/base
    mkdir -p deployment/cicd/{config,scripts}
    ```
  - 기존 k8s 매니페스트를 base로 복사
    ```
    # 기존 deployment/k8s/* 파일들을 base로 복사
    cp deployment/k8s/* deployment/cicd/kustomize/base/
    
    # 네임스페이스 하드코딩 제거
    find deployment/cicd/kustomize/base -name "*.yaml" -exec sed -i 's/namespace: .*//' {} \;
    ```

- Base Kustomization 작성
  `deployment/cicd/kustomize/base/kustomization.yaml` 파일 생성 방법 안내
  
  **⚠️ 중요: 리소스 누락 방지 가이드**
  1. **디렉토리별 파일 확인**: base 디렉토리의 모든 yaml 파일을 확인
  2. **일관성 체크**: 모든 리소스가 동일한 파일 구조를 가지는지 확인
  3. **누락 검증**: `ls deployment/cicd/kustomize/base/` 명령으로 실제 파일과 kustomization.yaml 리스트 비교
  4. **명명 규칙 준수**: ConfigMap은 `configmap.yaml`, Service는 `service.yaml` 패턴 확인

  ```yaml
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization

  metadata:
    name: {SERVICE_NAME}-base

  resources:
    # Frontend resources
    - deployment.yaml
    - service.yaml
    - configmap.yaml
    - ingress.yaml

  images:
    - name: {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}
      newTag: latest
  ```
  
  **검증 명령어**:
  ```bash
  # base 디렉토리의 파일 확인
  ls deployment/cicd/kustomize/base/
  
  # kustomization.yaml 유효성 검사
  kubectl kustomize deployment/cicd/kustomize/base/
  ```

- 환경별 Patch 파일 생성
  각 환경별로 필요한 patch 파일들을 생성합니다.   
  **중요원칙**:
  - **base 매니페스트에 없는 항목은 추가 않함**
  - **base 매니페스트와 항목이 일치해야 함**

  **1. ConfigMap Patch 파일 생성**
  `deployment/cicd/kustomize/overlays/{환경}/configmap-patch.yaml`

  - base 매니페스트를 환경별로 복사
    ```
    cp deployment/cicd/kustomize/base/configmap.yaml deployment/cicd/kustomize/overlays/{환경}/configmap-patch.yaml
    ```

  - 환경별 API 엔드포인트 설정
  - dev: 개발 API 서버 주소, staging/prod: 운영 API 서버 주소

  **2. Ingress Patch 파일 생성**
  `deployment/cicd/kustomize/overlays/{환경}/ingress-patch.yaml`
  - base의 ingress.yaml을 환경별로 오버라이드
  - **⚠️ 중요**: 개발환경 Ingress Host의 기본값은 base의 ingress.yaml과 **정확히 동일하게** 함
  - Staging/Prod 환경별 도메인 설정: {SERVICE_NAME}-{환경}.도메인 형식
  - Staging/prod 환경은 HTTPS 강제 적용 및 SSL 인증서 설정
  - staging/prod는 nginx.ingress.kubernetes.io/ssl-redirect: "true"
  - dev는 nginx.ingress.kubernetes.io/ssl-redirect: "false"

  **3. Deployment Patch 파일 생성** ⚠️ **중요**
  `deployment/cicd/kustomize/overlays/{환경}/deployment-patch.yaml`

  **필수 포함 사항:**
  - ✅ **replicas 설정**: Deployment의 replica 수를 환경별로 설정
    - dev: 1 replica (리소스 절약)
    - staging: 2 replicas
    - prod: 3 replicas
  - ✅ **resources 설정**: Deployment의 resources를 환경별로 설정
    - dev: requests(256m CPU, 256Mi Memory), limits(1024m CPU, 1024Mi Memory)
    - staging: requests(512m CPU, 512Mi Memory), limits(2048m CPU, 2048Mi Memory)
    - prod: requests(1024m CPU, 1024Mi Memory), limits(4096m CPU, 4096Mi Memory)

  **작성 형식:**
  - **Strategic Merge Patch 형식** 사용 (JSON Patch 아님)
  - replicas와 resources를 **반드시 모두** 포함

- 환경별 Overlay 작성  
  각 환경별로 `overlays/{환경}/kustomization.yaml` 생성
  ```yaml
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization

  namespace: {SYSTEM_NAME}-{환경}

  resources:
    - ../../base

  patches:
    - path: configmap-patch.yaml
      target:
        kind: ConfigMap
        name: cm-{SERVICE_NAME}
    - path: deployment-patch.yaml
      target:
        kind: Deployment
        name: {SERVICE_NAME}
    - path: ingress-patch.yaml
      target:
        kind: Ingress
        name: {SERVICE_NAME}

  images:
    - name: {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}
      newTag: {환경}-latest

  ```

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
  - **Pod Template**: Node.js, Podman, Azure-CLI 컨테이너
  - **Build & Test**: Node.js 기반 빌드 및 단위 테스트
  - **SonarQube Analysis**: 프론트엔드 코드 품질 분석 및 Quality Gate
  - **Container Build & Push**: 30분 timeout 설정과 함께 환경별 이미지 태그로 빌드 및 푸시
  - **Kustomize Deploy**: 환경별 매니페스트 적용
  - **Pod Cleanup**: 파이프라인 완료 시 에이전트 파드 자동 정리

  **⚠️ 중요: Pod 자동 정리 설정**
  에이전트 파드가 파이프라인 완료 시 즉시 정리되도록 다음 설정들이 적용됨:
  - **podRetention: never()**: 파이프라인 완료 시 파드 즉시 삭제 (문법 주의: 문자열 'never' 아님)
  - **idleMinutes: 1**: 유휴 시간 1분으로 설정하여 빠른 정리
  - **terminationGracePeriodSeconds: 3**: 파드 종료 시 3초 내 강제 종료
  - **restartPolicy: Never**: 파드 재시작 방지
  - **try-catch-finally**: 예외 발생 시에도 정리 로직 실행 보장

  **⚠️ 중요: 변수 참조 문법 및 충돌 해결**
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
      idleMinutes: 1,
      activeDeadlineSeconds: 3600,
      podRetention: never(),  // 파드 자동 정리 옵션: never(), onFailure(), always(), default()
      yaml: '''
          spec:
            terminationGracePeriodSeconds: 3
            restartPolicy: Never
            tolerations:
            - effect: NoSchedule
              key: dedicated
              operator: Equal
              value: cicd
      ''',
      containers: [
          containerTemplate(
              name: 'node', 
              image: 'node:slim', 
              ttyEnabled: true, 
              command: 'cat',
              resourceRequestCpu: '500m',
              resourceRequestMemory: '1Gi',
              resourceLimitCpu: '2000m',
              resourceLimitMemory: '4Gi'
          ),
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
              name: 'azure-cli', 
              image: 'hiondal/azure-kubectl:latest', 
              command: 'cat', 
              ttyEnabled: true,
              resourceRequestCpu: '200m',
              resourceRequestMemory: '512Mi',
              resourceLimitCpu: '500m',
              resourceLimitMemory: '1Gi'
          ),
          containerTemplate(
              name: 'sonar-scanner', 
              image: 'sonarsource/sonar-scanner-cli:latest', 
              command: 'cat', 
              ttyEnabled: true,
              resourceRequestCpu: '200m',
              resourceRequestMemory: '512Mi',
              resourceLimitCpu: '1000m',
              resourceLimitMemory: '1Gi'
          )
      ],
      volumes: [
          emptyDirVolume(mountPath: '/root/.azure', memory: false),
          emptyDirVolume(mountPath: '/opt/sonar-scanner/.sonar/cache', memory: false),
          emptyDirVolume(mountPath: '/root/.npm', memory: false)
      ]
  ) {
      node(PIPELINE_ID) {
          def props
          def imageTag = getImageTag()
          def environment = params.ENVIRONMENT ?: 'dev'
          def skipSonarQube = (params.SKIP_SONARQUBE?.toLowerCase() == 'true')
          def sonarScannerHome = '/opt/sonar-scanner'
          
          try {
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
                              kubectl create namespace {SYSTEM_NAME}-${environment} --dry-run=client -o yaml | kubectl apply -f -
                          """
                      }
                  }
              }

              stage('Build & Test') {
                  container('node') {
                      sh """
                          npm ci
                          npm run build
                          npm run lint
                      """
                  }
              }

              stage('SonarQube Analysis & Quality Gate') {
                  if (skipSonarQube) {
                      echo "⏭️ Skipping SonarQube Analysis (SKIP_SONARQUBE=${params.SKIP_SONARQUBE})"
                  } else {
                      container('sonar-scanner') {
                          script {
                              try {
                                  withSonarQubeEnv('SonarQube') {
                                      sh """
                                        timeout 300 ${sonarScannerHome}/bin/sonar-scanner \\
                                        -Dsonar.projectKey={SERVICE_NAME}-${environment} \\
                                        -Dsonar.projectName={SERVICE_NAME}-${environment} \\
                                        -Dsonar.sources=src/components,src/pages,src/services,src/hooks \\
                                        -Dsonar.tests=src \\
                                        -Dsonar.test.inclusions=src/**/*.test.js,src/**/*.test.jsx,src/**/*.test.ts,src/**/*.test.tsx \\
                                        -Dsonar.exclusions=**/node_modules/**,**/build/**,**/dist/**,**/*.config.js,**/coverage/**,**/stores/**,**/config/**,**/types/**,**/styles/**,**/assets/** \\
                                        -Dsonar.scm.disabled=true \\
                                        -Dsonar.sourceEncoding=UTF-8 \\
                                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \\
                                        -Dsonar.scm.disabled=true \\
                                        -Dsonar.sourceEncoding=UTF-8
                                      """
                                  }
                                  
                                  timeout(time: 5, unit: 'MINUTES') {
                                      def qg = waitForQualityGate()
                                      if (qg.status != 'OK') {
                                          echo "⚠️ Quality Gate failed: ${qg.status}, but continuing pipeline..."
                                      }
                                  }
                              } catch (Exception e) {
                                  echo "⚠️ SonarQube analysis failed: ${e.getMessage()}, but continuing pipeline..."
                              }
                          }
                      }
                  }
              }

              stage('Build & Push Images') {
                  timeout(time: 30, unit: 'MINUTES') {
                      container('podman') {
                          withCredentials([
                              usernamePassword(
                                  credentialsId: 'acr-credentials',
                                  usernameVariable: 'ACR_USERNAME',
                                  passwordVariable: 'ACR_PASSWORD'
                              ),
                              usernamePassword(
                                  credentialsId: 'dockerhub-credentials',
                                  usernameVariable: 'DOCKERHUB_USERNAME', 
                                  passwordVariable: 'DOCKERHUB_PASSWORD'
                              )
                          ]) {
                              // Docker Hub 로그인 (rate limit 해결)
                              sh "podman login docker.io --username \$DOCKERHUB_USERNAME --password \$DOCKERHUB_PASSWORD"
                              
                              // ACR 로그인
                              sh "podman login {ACR_NAME}.azurecr.io --username \$ACR_USERNAME --password \$ACR_PASSWORD"

                              sh """
                                  podman build \\
                                      -f deployment/container/Dockerfile-frontend \\
                                      --build-arg PROJECT_FOLDER="." \\
                                      --build-arg BUILD_FOLDER="deployment/container" \\
                                      --build-arg EXPORT_PORT="8080" \\
                                      -t {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}:${environment}-${imageTag} .

                                  podman push {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}:${environment}-${imageTag}
                              """
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
                          \$HOME/bin/kustomize edit set image {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}:${environment}-${imageTag}

                          # 매니페스트 적용
                          kubectl apply -k .

                          # 배포 상태 확인
                          echo "Waiting for deployments to be ready..."
                          kubectl -n {SYSTEM_NAME}-${environment} wait --for=condition=available deployment/{SERVICE_NAME} --timeout=300s
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
              
          } catch (Exception e) {
              currentBuild.result = 'FAILURE'
              echo "❌ Pipeline failed with exception: ${e.getMessage()}"
              throw e
          } finally {
              echo "🧹 Cleaning up resources and preparing for pod termination..."
              echo "Pod will be terminated in 3 seconds due to terminationGracePeriodSeconds: 3"
          }
      }
  }
  ```

- Jenkins Pipeline Job 생성 안내

  - Pipeline Job 설정
  1. Jenkins 웹 UI에서 **New Item > Pipeline** 선택
  2. **Pipeline script from SCM** 설정:
     ```
     SCM: Git
     Repository URL: {Git저장소URL}
     Branch: main (또는 develop)
     Script Path: deployment/cicd/Jenkinsfile
     ```

  - Pipeline Parameters 설정
  ```
  ENVIRONMENT: Choice Parameter
  - Choices: dev, staging, prod
  - Default: dev
  - Description: 배포 환경 선택

  IMAGE_TAG: String Parameter
  - Default: latest
  - Description: 컨테이너 이미지 태그 (선택사항)
  
  SKIP_SONARQUBE: String Parameter
  - Default: true
  - Description: SonarQube 코드 분석 스킵 여부 (true/false)
  ```

- SonarQube 프로젝트 설정 안내

  - SonarQube 프로젝트 생성
    - SonarQube에서 프론트엔드 프로젝트 생성
    - 프로젝트 키: `{SERVICE_NAME}-{환경}`
    - 언어: JavaScript/TypeScript

  - Quality Gate 설정
  ```
  Coverage: >= 70%
  Duplicated Lines: <= 3%
  Maintainability Rating: <= A
  Reliability Rating: <= A
  Security Rating: <= A
  Code Smells: <= 50
  Bugs: = 0
  Vulnerabilities: = 0
  ```

- 수동 배포 스크립트 작성
  `deployment/cicd/scripts/deploy.sh` 파일 생성:
  ```bash
  #!/bin/bash
  set -e

  ENVIRONMENT=${1:-dev}
  IMAGE_TAG=${2:-latest}

  echo "🚀 Frontend 배포 시작 - 환경: $ENVIRONMENT, 태그: $IMAGE_TAG"

  # 환경별 이미지 태그 업데이트
  cd deployment/cicd/kustomize/overlays/${ENVIRONMENT}
  
  # 이미지 태그 업데이트
  kustomize edit set image {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}:${ENVIRONMENT}-${IMAGE_TAG}
  
  # 배포 실행
  kubectl apply -k .
  
  # 배포 상태 확인
  kubectl rollout status deployment/{SERVICE_NAME} -n {SYSTEM_NAME}-${ENVIRONMENT} --timeout=300s
  
  echo "✅ 배포 완료!"
  ```

- **리소스 검증 스크립트 생성** 
  `deployment/cicd/scripts/validate-resources.sh` 파일 생성:
  ```bash
  #!/bin/bash
  # Frontend 리소스 누락 검증 스크립트
  
  echo "🔍 {SERVICE_NAME} Base 리소스 누락 검증 시작..."
  
  BASE_DIR="deployment/cicd/kustomize/base"
  MISSING_RESOURCES=0
  REQUIRED_FILES=("deployment.yaml" "service.yaml" "configmap.yaml" "ingress.yaml")
  
  # 1. base 디렉토리의 파일 확인
  echo "1. Base 디렉토리 파일 목록:"
  if [ -d "$BASE_DIR" ]; then
      for required in "${REQUIRED_FILES[@]}"; do
          if [ -f "$BASE_DIR/$required" ]; then
              echo "  ✅ $required"
          else
              echo "  ❌ MISSING REQUIRED: $required"
              ((MISSING_RESOURCES++))
          fi
      done
  else
      echo "  ❌ Base 디렉토리가 없습니다"
      ((MISSING_RESOURCES++))
  fi
  
  # 2. kustomization.yaml과 실제 파일 비교
  echo ""
  echo "2. kustomization.yaml 리소스 검증:"
  if [ -f "$BASE_DIR/kustomization.yaml" ]; then
      while IFS= read -r line; do
          # resources 섹션의 YAML 파일 경로 추출
          if [[ $line =~ ^[[:space:]]*-[[:space:]]*([^#]+\.yaml)[[:space:]]*$ ]]; then
              resource_path=$(echo "${BASH_REMATCH[1]}" | xargs)  # 공백 제거
              full_path="$BASE_DIR/$resource_path"
              if [ -f "$full_path" ]; then
                  echo "  ✅ $resource_path"
              else
                  echo "  ❌ MISSING: $resource_path"
                  ((MISSING_RESOURCES++))
              fi
          fi
      done < "$BASE_DIR/kustomization.yaml"
  else
      echo "  ❌ kustomization.yaml 파일이 없습니다"
      ((MISSING_RESOURCES++))
  fi
  
  # 3. kubectl kustomize 검증
  echo ""
  echo "3. Kustomize 빌드 테스트:"
  if kubectl kustomize "$BASE_DIR" > /dev/null 2>&1; then
      echo "  ✅ Base kustomization 빌드 성공"
  else
      echo "  ❌ Base kustomization 빌드 실패:"
      kubectl kustomize "$BASE_DIR" 2>&1 | head -5 | sed 's/^/     /'
      ((MISSING_RESOURCES++))
  fi
  
  # 4. 환경별 overlay 검증
  echo ""
  echo "4. 환경별 Overlay 검증:"
  for env in dev staging prod; do
      overlay_dir="deployment/cicd/kustomize/overlays/$env"
      if [ -d "$overlay_dir" ] && [ -f "$overlay_dir/kustomization.yaml" ]; then
          if kubectl kustomize "$overlay_dir" > /dev/null 2>&1; then
              echo "  ✅ $env 환경 빌드 성공"
          else
              echo "  ❌ $env 환경 빌드 실패"
              ((MISSING_RESOURCES++))
          fi
      else
          echo "  ⚠️  $env 환경 설정 없음 (선택사항)"
      fi
  done
  
  # 결과 출력
  echo ""
  echo "======================================"
  if [ $MISSING_RESOURCES -eq 0 ]; then
      echo "🎯 검증 완료! 모든 리소스가 정상입니다."
      echo "======================================"
      exit 0
  else
      echo "❌ $MISSING_RESOURCES개의 문제가 발견되었습니다."
      echo "======================================"
      echo ""
      echo "💡 문제 해결 가이드:"
      echo "1. 누락된 파일들을 base 디렉토리에 추가하세요"
      echo "2. kustomization.yaml에서 존재하지 않는 파일 참조를 제거하세요"
      echo "3. 다시 검증: ./scripts/validate-resources.sh"
      exit 1
  fi
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
    kubectl get pods -n {SYSTEM_NAME}-{환경}
    kubectl get services -n {SYSTEM_NAME}-{환경}
    kubectl get ingress -n {SYSTEM_NAME}-{환경}
    ```

- 수동 배포 실행 방법
  ```bash
  # 개발환경 배포
  ./deployment/cicd/scripts/deploy.sh dev
  
  # 스테이징환경 배포
  ./deployment/cicd/scripts/deploy.sh staging
  
  # 운영환경 배포
  ./deployment/cicd/scripts/deploy.sh prod latest
  ```

- 롤백 방법 작성
  - 이전 버전으로 롤백:
    ```bash
    # 특정 버전으로 롤백
    kubectl rollout undo deployment/{SERVICE_NAME} -n {SYSTEM_NAME}-{환경} --to-revision=2
    
    # 롤백 상태 확인
    kubectl rollout status deployment/{SERVICE_NAME} -n {SYSTEM_NAME}-{환경}
    ```
  - 이미지 태그 기반 롤백:
    ```bash
    # 이전 안정 버전 이미지 태그로 업데이트
    cd deployment/cicd/kustomize/overlays/{환경}
    kustomize edit set image {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}:{환경}-{이전태그}
    kubectl apply -k .
    ```

[체크리스트]
Jenkins CI/CD 파이프라인 구축 작업을 누락 없이 진행하기 위한 체크리스트입니다.

## 📋 사전 준비 체크리스트
- [ ] package.json에서 프로젝트명 확인 완료
- [ ] 실행정보 섹션에서 ACR명, 리소스 그룹, AKS 클러스터명 확인 완료
- [ ] **ESLint 설정 파일 `.eslintrc.cjs` 생성 완료**
- [ ] **package.json lint 스크립트 max-warnings 20으로 수정 완료**

## 📂 Kustomize 구조 생성 체크리스트
- [ ] 디렉토리 구조 생성: `deployment/cicd/kustomize/{base,overlays/{dev,staging,prod}}`
- [ ] 기존 k8s 매니페스트를 base로 복사 완료
- [ ] 네임스페이스 하드코딩 제거 완료
- [ ] **리소스 누락 방지 검증 완료**:
  - [ ] `ls deployment/cicd/kustomize/base/` 명령으로 모든 파일 확인
  - [ ] 필수 파일 존재 확인 (deployment.yaml, service.yaml, configmap.yaml, ingress.yaml 필수)
- [ ] Base kustomization.yaml 파일 생성 완료
  - [ ] 모든 리소스 파일 포함 확인
- [ ] **검증 명령어 실행 완료**:
  - [ ] `kubectl kustomize deployment/cicd/kustomize/base/` 정상 실행 확인
  - [ ] 에러 메시지 없이 모든 리소스 출력 확인

## 🔧 환경별 Overlay 구성 체크리스트
### 공통 체크 사항
- **base 매니페스트에 없는 항목을 추가하지 않았는지 체크**
- **base 매니페스트와 항목이 일치 하는지 체크**
- **⚠️ Kustomize patch 방법**: `patches` (target 명시)

### DEV 환경
- [ ] `overlays/dev/kustomization.yaml` 생성 완료
- [ ] `overlays/dev/configmap-patch.yaml` 생성 완료 (개발 API 엔드포인트)
- [ ] `overlays/dev/ingress-patch.yaml` 생성 완료 (**Host 기본값은 base의 ingress.yaml과 동일**)
- [ ] `overlays/dev/deployment-patch.yaml` 생성 완료 (replicas=1, dev 리소스)

### STAGING 환경
- [ ] `overlays/staging/kustomization.yaml` 생성 완료
- [ ] `overlays/staging/configmap-patch.yaml` 생성 완료 (스테이징 API 엔드포인트)
- [ ] `overlays/staging/ingress-patch.yaml` 생성 완료 (staging 도메인, HTTPS)
- [ ] `overlays/staging/deployment-patch.yaml` 생성 완료 (replicas=2, staging 리소스)

### PROD 환경
- [ ] `overlays/prod/kustomization.yaml` 생성 완료
- [ ] `overlays/prod/configmap-patch.yaml` 생성 완료 (운영 API 엔드포인트)
- [ ] `overlays/prod/ingress-patch.yaml` 생성 완료 (prod 도메인, HTTPS, SSL 인증서)
- [ ] `overlays/prod/deployment-patch.yaml` 생성 완료 (replicas=3, prod 리소스)

## ⚙️ 설정 및 스크립트 체크리스트
- [ ] 환경별 설정 파일 생성: `config/deploy_env_vars_{dev,staging,prod}`
- [ ] `Jenkinsfile` 생성 완료
- [ ] `Jenkinsfile` 주요 내용 확인
  - 변수 참조 문법 확인: `${variable}` 사용, `\${variable}` 사용 금지
  - 서비스명이 실제 {SERVICE_NAME}으로 치환되었는지 확인
  - **파드 자동 정리 설정 확인**: podRetention: never(), idleMinutes: 1, terminationGracePeriodSeconds: 3
  - **try-catch-finally 블록 포함**: 예외 상황에서도 정리 로직 실행 보장
- [ ] 수동 배포 스크립트 `scripts/deploy.sh` 생성 완료
- [ ] **리소스 검증 스크립트 `scripts/validate-resources.sh` 생성 완료**
- [ ] 스크립트 실행 권한 설정 완료 (`chmod +x scripts/*.sh`)
- [ ] **검증 스크립트 실행하여 누락 리소스 확인 완료** (`./scripts/validate-resources.sh`)
- [ ] Dockerfile 및 Nginx 설정 파일 생성 완료

[결과파일]
- 가이드: deployment/cicd/jenkins-pipeline-guide-frontend.md
- 환경별 설정 파일: deployment/cicd/config/*
- Kustomize 파일: deployment/cicd/kustomize/*
- 수동배포 스크립트: deployment/cicd/scripts
- Jenkins 스크립트: deployment/cicd/Jenkinsfile
