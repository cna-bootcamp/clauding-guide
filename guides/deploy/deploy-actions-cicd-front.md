# 프론트엔드 GitHub Actions 파이프라인 작성 가이드

[요청사항]
- GitHub Actions + Kustomize 기반 CI/CD 파이프라인 구축 가이드 작성
- 환경별(dev/staging/prod) 매니페스트 관리 및 자동 배포 구현
- SonarQube 코드 품질 분석과 Quality Gate 포함
- Node.js 기반 빌드 및 컨테이너 이미지 생성
- '[결과파일]'에 구축 방법 및 파이프라인 작성 가이드 생성
- 아래 작업은 실제 수행하여 파일 생성
  - ESLint 설정 파일 작성
  - GitHub Actions 전용 Kustomize 디렉토리 구조 생성
  - Base Kustomization 작성
  - 환경별 Overlay 작성
  - 환경별 Patch 파일 생성
  - GitHub Actions 워크플로우 파일 작성
  - 환경별 배포 변수 파일 작성
  - 수동 배포 스크립트 작성

[작업순서]
- 사전 준비사항 확인
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인
  - {SYSTEM_NAME}: 시스템명 (phonebill)
  - {ACR_NAME}: Azure Container Registry 이름
  - {RESOURCE_GROUP}: Azure 리소스 그룹명
  - {AKS_CLUSTER}: AKS 클러스터명
    예시)
  ```
  [실행정보]
  - SYSTEM_NAME: phonebill
  - ACR_NAME: acrdigitalgarage01
  - RESOURCE_GROUP: rg-digitalgarage-01
  - AKS_CLUSTER: aks-digitalgarage-01
  ```

- 서비스명 확인
  package.json에서 확인.
  - {SERVICE_NAME}: package.json의 "name" 필드
  예시)
  ```json
  {
    ...
    "name": "phonebill-front",
    ...
  }
  ```

- Node.js 버전 확인
  package.json에서 Node.js 버전 확인.
  {NODE_VERSION}: "engines" 섹션에서 Node.js 버전 확인. 없으면 20 버전 사용.
  ```json
  {
    "engines": {
      "node": "20.x"
    }
  }
  ```

- GitHub 저장소 환경 구성 안내
  - GitHub Repository Secrets 설정
    - Azure 접근 인증정보 설정
    ```
    # Azure Service Principal
    Repository Settings > Secrets and variables > Actions > Repository secrets에 등록

    AZURE_CREDENTIALS:
    {
      "clientId": "{클라이언트ID}",
      "clientSecret": "{클라이언트시크릿}",
      "subscriptionId": "{구독ID}",
      "tenantId": "{테넌트ID}"
    }
    예시)
    {
      "clientId": "5e4b5b41-7208-48b7-b821-d6d5acf50ecf",
      "clientSecret": "ldu8Q~GQEzFYU.dJX7_QsahR7n7C2xqkIM6hqbV8",
      "subscriptionId": "2513dd36-7978-48e3-9a7c-b221d4874f66",
      "tenantId": "4f0a3bfd-1156-4cce-8dc2-a049a13dba23"
    }
    ```

    - ACR Credentials
      Credential 구하는 방법 안내
      az acr credential show --name {acr 이름}
      예) az acr credential show --name acrdigitalgarage01
      ```
      ACR_USERNAME: {ACR_NAME}
      ACR_PASSWORD: {ACR패스워드}
      ```
    - SonarQube URL과 인증 토큰
      SONAR_HOST_URL 구하는 방법과 SONAR_TOKEN 작성법 안내
      SONAR_HOST_URL: 아래 명령 수행 후 http://{External IP}를 지정
      k get svc -n sonarqube
      예) http://20.249.187.69

      SONAR_TOKEN 값은 아래와 같이 작성
      - SonarQube 로그인 후 우측 상단 'Administrator' > My Account 클릭
      - Security 탭 선택 후 토큰 생성

      ```
      SONAR_TOKEN: {SonarQube토큰}
      SONAR_HOST_URL: {SonarQube서버URL}
      ```

    - Docker Hub (Rate Limit 해결용)
      Docker Hub 패스워드 작성 방법 안내
      - DockerHub(https://hub.docker.com)에 로그인
      - 우측 상단 프로필 아이콘 클릭 후 Account Settings를 선택
      - 좌측메뉴에서 'Personal Access Tokens' 클릭하여 생성
      ```
      DOCKERHUB_USERNAME: {Docker Hub 사용자명}
      DOCKERHUB_PASSWORD: {Docker Hub 패스워드}
      ```

  - GitHub Repository Variables 설정
    ```
    # Workflow 제어 변수
    Repository Settings > Secrets and variables > Actions > Variables > Repository variables에 등록

    ENVIRONMENT: dev (기본값, 수동실행시 선택 가능: dev/staging/prod)
    SKIP_SONARQUBE: true (기본값, 수동실행시 선택 가능: true/false)
    ```

    **사용 방법:**
    - **자동 실행**: Push/PR 시 기본값 사용 (ENVIRONMENT=dev, SKIP_SONARQUBE=true)
    - **수동 실행**: Actions 탭 > "Frontend CI/CD" > "Run workflow" 버튼 클릭
      - Environment: dev/staging/prod 선택
      - Skip SonarQube Analysis: true/false 선택

- ESLint 설정 파일 작성
  TypeScript React 프로젝트를 위한 `.eslintrc.cjs` 파일을 프로젝트 루트에 생성합니다.

  **⚠️ 중요**: ES 모듈 프로젝트에서는 `.eslintrc.cjs` 확장자 사용 필수

  ```javascript
  module.exports = {
    root: true,
    env: {
      browser: true,
      es2020: true,
      node: true
    },
    extends: [
      'eslint:recommended',
      'plugin:@typescript-eslint/recommended',
      'plugin:react-hooks/recommended'
    ],
    ignorePatterns: [
      'dist',
      '.eslintrc.cjs',
      'node_modules',
      'build',
      'coverage'
    ],
    parser: '@typescript-eslint/parser',
    parserOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      ecmaFeatures: {
        jsx: true
      }
    },
    plugins: [
      'react-refresh',
      '@typescript-eslint'
    ],
    rules: {
      // React 관련 규칙
      'react-refresh/only-export-components': [
        'warn',
        { allowConstantExport: true },
      ],

      // TypeScript 관련 규칙
      '@typescript-eslint/no-unused-vars': ['error', {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_'
      }],
      '@typescript-eslint/no-explicit-any': 'warn',

      // 일반 규칙
      'no-unused-vars': 'off', // TypeScript 규칙을 사용

      // Hooks 규칙
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn'
    },
    overrides: [
      {
        files: ['**/*.test.ts', '**/*.test.tsx', '**/*.spec.ts', '**/*.spec.tsx'],
        env: {
          jest: true
        }
      }
    ]
  }
  ```

  **필수 ESLint 관련 devDependencies 설치**:
  ```bash
  npm install --save-dev eslint-plugin-react
  ```

  **package.json lint 스크립트 수정** (max-warnings 20으로 설정):
  ```json
  {
    "scripts": {
      "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 20"
    }
  }
  ```

- GitHub Actions 전용 Kustomize 디렉토리 구조 생성
  - GitHub Actions 전용 Kustomize 디렉토리 생성
    ```bash
    mkdir -p .github/kustomize/{base,overlays/{dev,staging,prod}}
    mkdir -p .github/kustomize/base
    mkdir -p .github/{config,scripts}
    ```
  - 기존 k8s 매니페스트를 base로 복사
    ```bash
    # 기존 deployment/k8s/* 파일들을 base로 복사
    cp deployment/k8s/* .github/kustomize/base/

    # 네임스페이스 하드코딩 제거
    find .github/kustomize/base -name "*.yaml" -exec sed -i 's/namespace: .*//' {} \;
    ```

- Base Kustomization 작성
  `.github/kustomize/base/kustomization.yaml` 파일 생성

  **⚠️ 중요: 리소스 누락 방지 가이드**
  1. **디렉토리별 파일 확인**: base 디렉토리의 모든 yaml 파일을 확인
  2. **일관성 체크**: 모든 리소스가 동일한 파일 구조를 가지는지 확인
  3. **누락 검증**: `ls .github/kustomize/base/` 명령으로 실제 파일과 kustomization.yaml 리스트 비교
  4. **명명 규칙 준수**: ConfigMap은 `configmap.yaml` 또는 `cm-{SERVICE_NAME}.yaml`, Service는 `service.yaml` 패턴 확인

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
  ls .github/kustomize/base/

  # kustomization.yaml 유효성 검사
  kubectl kustomize .github/kustomize/base/
  ```

- 환경별 Patch 파일 생성
  각 환경별로 필요한 patch 파일들을 생성합니다.
  **중요원칙**:
  - **base 매니페스트에 없는 항목은 추가 안함**
  - **base 매니페스트와 항목이 일치해야 함**

  **1. ConfigMap Patch 파일 생성**
  `.github/kustomize/overlays/{ENVIRONMENT}/configmap-patch.yaml`

  - base 매니페스트를 환경별로 복사
    ```
    cp .github/kustomize/base/configmap.yaml .github/kustomize/overlays/{ENVIRONMENT}/configmap-patch.yaml
    ```

  - 환경별 API 엔드포인트 설정
  - dev: 개발 API 서버 주소, staging/prod: 운영 API 서버 주소

  **2. Ingress Patch 파일 생성**
  `.github/kustomize/overlays/{ENVIRONMENT}/ingress-patch.yaml`
  - base의 ingress.yaml을 환경별로 오버라이드
  - **⚠️ 중요**: 개발환경 Ingress Host의 기본값은 base의 ingress.yaml과 **정확히 동일하게** 함
    - base에서 `host: {SERVICE_NAME}.20.214.196.128.nip.io` 이면
    - dev에서도 `host: {SERVICE_NAME}.20.214.196.128.nip.io` 로 동일하게 설정
    - **절대** `{SERVICE_NAME}-dev.xxx` 처럼 변경하지 말 것
  - Staging/Prod 환경별 도메인 설정: {SERVICE_NAME}-{환경}.도메인 형식
  - Staging/prod 환경은 HTTPS 강제 적용 및 SSL 인증서 설정
  - staging/prod는 nginx.ingress.kubernetes.io/ssl-redirect: "true"
  - dev는 nginx.ingress.kubernetes.io/ssl-redirect: "false"

  **3. Deployment Patch 파일 생성** ⚠️ **중요**
  `.github/kustomize/overlays/{ENVIRONMENT}/deployment-patch.yaml`

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

  namespace: {SYSTEM_NAME}-{ENVIRONMENT}

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
      newTag: latest

  ```

- GitHub Actions 워크플로우 작성
  `.github/workflows/frontend-cicd.yaml` 파일 생성 방법을 안내합니다.

  주요 구성 요소:
  - **Build & Test**: Node.js 기반 빌드 및 단위 테스트, ESLint 검사
  - **SonarQube Analysis**: 프론트엔드 코드 품질 분석 및 Quality Gate
  - **Container Build & Push**: 환경별 이미지 태그로 빌드 및 푸시
  - **Kustomize Deploy**: 환경별 매니페스트 적용

  ```yaml
  name: Frontend CI/CD

  on:
    push:
      branches: [ main, develop ]
      paths:
        - 'src/**'
        - 'public/**'
        - 'package*.json'
        - 'tsconfig*.json'
        - 'vite.config.ts'
        - 'index.html'
        - '.github/**'
    pull_request:
      branches: [ main ]
    workflow_dispatch:
      inputs:
        ENVIRONMENT:
          description: 'Target environment'
          required: true
          default: 'dev'
          type: choice
          options:
            - dev
            - staging
            - prod
        SKIP_SONARQUBE:
          description: 'Skip SonarQube Analysis'
          required: false
          default: 'true'
          type: choice
          options:
            - 'true'
            - 'false'

  env:
    REGISTRY: {ACR_NAME}.azurecr.io
    IMAGE_ORG: {SYSTEM_NAME}
    RESOURCE_GROUP: {RESOURCE_GROUP}
    AKS_CLUSTER: {AKS_CLUSTER}

  jobs:
    build:
      name: Build and Test
      runs-on: ubuntu-latest
      outputs:
        image_tag: ${{ steps.set_outputs.outputs.image_tag }}
        environment: ${{ steps.set_outputs.outputs.environment }}

      steps:
        - name: Check out code
          uses: actions/checkout@v4

        - name: Set up Node.js {NODE_VERSION}
          uses: actions/setup-node@v3
          with:
            node-version: '{NODE_VERSION}'
            cache: 'npm'

        - name: Determine environment
          id: determine_env
          run: |
            # Use input parameter or default to 'dev'
            ENVIRONMENT="${{ github.event.inputs.ENVIRONMENT || 'dev' }}"
            echo "environment=$ENVIRONMENT" >> $GITHUB_OUTPUT

        - name: Load environment variables
          id: env_vars
          run: |
            ENV=${{ steps.determine_env.outputs.environment }}

            # Initialize variables with defaults
            REGISTRY="{ACR_NAME}.azurecr.io"
            IMAGE_ORG="{SYSTEM_NAME}"
            RESOURCE_GROUP="{RESOURCE_GROUP}"
            AKS_CLUSTER="{AKS_CLUSTER}"

            # Read environment variables from .github/config file
            if [[ -f ".github/config/deploy_env_vars_${ENV}" ]]; then
              while IFS= read -r line || [[ -n "$line" ]]; do
                # Skip comments and empty lines
                [[ "$line" =~ ^#.*$ ]] && continue
                [[ -z "$line" ]] && continue

                # Extract key-value pairs
                key=$(echo "$line" | cut -d '=' -f1)
                value=$(echo "$line" | cut -d '=' -f2-)

                # Override defaults if found in config
                case "$key" in
                  "resource_group") RESOURCE_GROUP="$value" ;;
                  "cluster_name") AKS_CLUSTER="$value" ;;
                esac
              done < ".github/config/deploy_env_vars_${ENV}"
            fi

            # Export for other jobs
            echo "REGISTRY=$REGISTRY" >> $GITHUB_ENV
            echo "IMAGE_ORG=$IMAGE_ORG" >> $GITHUB_ENV
            echo "RESOURCE_GROUP=$RESOURCE_GROUP" >> $GITHUB_ENV
            echo "AKS_CLUSTER=$AKS_CLUSTER" >> $GITHUB_ENV

        - name: Install dependencies
          run: npm ci

        - name: Build and Test
          run: |
            npm run build
            npm run lint

        - name: SonarQube Analysis & Quality Gate
          env:
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
            SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
            SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
          run: |
            # Check if SonarQube should be skipped
            SKIP_SONARQUBE="${{ github.event.inputs.SKIP_SONARQUBE || 'true' }}"

            if [[ "$SKIP_SONARQUBE" == "true" ]]; then
              echo "⏭️ Skipping SonarQube Analysis (SKIP_SONARQUBE=$SKIP_SONARQUBE)"
              exit 0
            fi

            # Install SonarQube Scanner
            npm install -g sonarqube-scanner

            # Run SonarQube analysis
            sonar-scanner \
              -Dsonar.projectKey={SERVICE_NAME}-${{ steps.determine_env.outputs.environment }} \
              -Dsonar.projectName={SERVICE_NAME}-${{ steps.determine_env.outputs.environment }} \
              -Dsonar.sources=src \
              -Dsonar.tests=src \
              -Dsonar.test.inclusions=**/*.test.ts,**/*.test.tsx,**/*.spec.ts,**/*.spec.tsx \
              -Dsonar.exclusions=node_modules/**,dist/**,build/**,coverage/**,**/*.config.js,**/*.config.ts,scripts/** \
              -Dsonar.scm.disabled=true \
              -Dsonar.sourceEncoding=UTF-8 \
              -Dsonar.typescript.tsconfigPaths=tsconfig.json \
              -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
              -Dsonar.javascript.node.maxspace=4096 \
              -Dsonar.host.url=$SONAR_HOST_URL \
              -Dsonar.token=$SONAR_TOKEN

        - name: Upload build artifacts
          uses: actions/upload-artifact@v4
          with:
            name: dist
            path: dist/

        - name: Set outputs
          id: set_outputs
          run: |
            # Generate timestamp for image tag
            IMAGE_TAG=$(date +%Y%m%d%H%M%S)
            echo "image_tag=$IMAGE_TAG" >> $GITHUB_OUTPUT
            echo "environment=${{ steps.determine_env.outputs.environment }}" >> $GITHUB_OUTPUT

    release:
      name: Build and Push Docker Image
      needs: build
      runs-on: ubuntu-latest

      steps:
        - name: Check out code
          uses: actions/checkout@v4

        - name: Download build artifacts
          uses: actions/download-artifact@v4
          with:
            name: dist
            path: dist/

        - name: Set environment variables from build job
          run: |
            echo "REGISTRY=${{ env.REGISTRY }}" >> $GITHUB_ENV
            echo "IMAGE_ORG=${{ env.IMAGE_ORG }}" >> $GITHUB_ENV
            echo "ENVIRONMENT=${{ needs.build.outputs.environment }}" >> $GITHUB_ENV
            echo "IMAGE_TAG=${{ needs.build.outputs.image_tag }}" >> $GITHUB_ENV

        - name: Set up Docker Buildx
          uses: docker/setup-buildx-action@v3

        - name: Login to Docker Hub (prevent rate limit)
          uses: docker/login-action@v3
          with:
            username: ${{ secrets.DOCKERHUB_USERNAME }}
            password: ${{ secrets.DOCKERHUB_PASSWORD }}

        - name: Login to Azure Container Registry
          uses: docker/login-action@v3
          with:
            registry: ${{ env.REGISTRY }}
            username: ${{ secrets.ACR_USERNAME }}
            password: ${{ secrets.ACR_PASSWORD }}

        - name: Build and push Docker image
          run: |
            docker build \
              -f deployment/container/Dockerfile-frontend \
              --build-arg PROJECT_FOLDER="." \
              --build-arg BUILD_FOLDER="deployment/container" \
              --build-arg EXPORT_PORT="8080" \
              -t ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/{SERVICE_NAME}:${{ needs.build.outputs.environment }}-${{ needs.build.outputs.image_tag }} .

            docker push ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/{SERVICE_NAME}:${{ needs.build.outputs.environment }}-${{ needs.build.outputs.image_tag }}

    deploy:
      name: Deploy to Kubernetes
      needs: [build, release]
      runs-on: ubuntu-latest

      steps:
        - name: Check out code
          uses: actions/checkout@v4

        - name: Set image tag environment variable
          run: |
            echo "IMAGE_TAG=${{ needs.build.outputs.image_tag }}" >> $GITHUB_ENV
            echo "ENVIRONMENT=${{ needs.build.outputs.environment }}" >> $GITHUB_ENV

        - name: Install Azure CLI
          run: |
            curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

        - name: Azure Login
          uses: azure/login@v1
          with:
            creds: ${{ secrets.AZURE_CREDENTIALS }}

        - name: Setup kubectl
          uses: azure/setup-kubectl@v3

        - name: Get AKS Credentials
          run: |
            az aks get-credentials --resource-group ${{ env.RESOURCE_GROUP }} --name ${{ env.AKS_CLUSTER }} --overwrite-existing

        - name: Create namespace
          run: |
            kubectl create namespace {SYSTEM_NAME}-${{ env.ENVIRONMENT }} --dry-run=client -o yaml | kubectl apply -f -

        - name: Install Kustomize
          run: |
            curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
            sudo mv kustomize /usr/local/bin/

        - name: Update Kustomize images and deploy
          run: |
            # 환경별 디렉토리로 이동
            cd .github/kustomize/overlays/${{ env.ENVIRONMENT }}

            # 이미지 태그 업데이트
            kustomize edit set image ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/{SERVICE_NAME}:${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}

            # 매니페스트 적용
            kubectl apply -k .

        - name: Wait for deployments to be ready
          run: |
            echo "Waiting for deployments to be ready..."
            kubectl -n {SYSTEM_NAME}-${{ env.ENVIRONMENT }} wait --for=condition=available deployment/{SERVICE_NAME} --timeout=300s

  ```

- GitHub Actions 전용 환경별 설정 파일 작성
  `.github/config/deploy_env_vars_{환경}` 파일 생성 방법

  **.github/config/deploy_env_vars_dev**
  ```bash
  # dev Environment Configuration
  resource_group={RESOURCE_GROUP}
  cluster_name={AKS_CLUSTER}
  ```

  **.github/config/deploy_env_vars_staging**
  ```bash
  # staging Environment Configuration
  resource_group={RESOURCE_GROUP}
  cluster_name={AKS_CLUSTER}
  ```

  **.github/config/deploy_env_vars_prod**
  ```bash
  # prod Environment Configuration
  resource_group={RESOURCE_GROUP}
  cluster_name={AKS_CLUSTER}
  ```

  **참고**: Kustomize 방식에서는 namespace, replicas, resources 등은 kustomization.yaml과 patch 파일에서 관리됩니다.

- GitHub Actions 전용 수동 배포 스크립트 작성
  `.github/scripts/deploy-actions-frontend.sh` 파일 생성:
  ```bash
  #!/bin/bash
  set -e

  ENVIRONMENT=${1:-dev}
  IMAGE_TAG=${2:-latest}

  echo "🚀 프론트엔드 수동 배포 시작..."
  echo "Environment: $ENVIRONMENT"
  echo "Image Tag: $IMAGE_TAG"

  # Check if kustomize is installed
  if ! command -v kustomize &> /dev/null; then
      echo "Installing Kustomize..."
      curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
      sudo mv kustomize /usr/local/bin/
  fi

  # Load environment variables from .github/config
  if [[ -f ".github/config/deploy_env_vars_${ENVIRONMENT}" ]]; then
      source ".github/config/deploy_env_vars_${ENVIRONMENT}"
      echo "✅ Environment variables loaded for $ENVIRONMENT"
  else
      echo "❌ Environment configuration file not found: .github/config/deploy_env_vars_${ENVIRONMENT}"
      exit 1
  fi

  # Create namespace
  echo "📝 Creating namespace {SYSTEM_NAME}-${ENVIRONMENT}..."
  kubectl create namespace {SYSTEM_NAME}-${ENVIRONMENT} --dry-run=client -o yaml | kubectl apply -f -

  # 환경별 이미지 태그 업데이트 (.github/kustomize 사용)
  cd .github/kustomize/overlays/${ENVIRONMENT}

  echo "🔄 Updating image tags..."
  # 이미지 태그 업데이트
  kustomize edit set image {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}:${ENVIRONMENT}-${IMAGE_TAG}

  echo "🚀 Deploying to Kubernetes..."
  # 배포 실행
  kubectl apply -k .

  echo "⏳ Waiting for deployments to be ready..."
  # 배포 상태 확인
  kubectl rollout status deployment/{SERVICE_NAME} -n {SYSTEM_NAME}-${ENVIRONMENT} --timeout=300s

  echo "🔍 Health check..."
  # Health Check
  POD=$(kubectl get pod -n {SYSTEM_NAME}-${ENVIRONMENT} -l app.kubernetes.io/name={SERVICE_NAME} -o jsonpath='{.items[0].metadata.name}')
  kubectl -n {SYSTEM_NAME}-${ENVIRONMENT} exec $POD -- curl -f http://localhost:8080/ || echo "Health check failed, but deployment completed"

  echo "📋 Service Information:"
  kubectl get pods -n {SYSTEM_NAME}-${ENVIRONMENT}
  kubectl get services -n {SYSTEM_NAME}-${ENVIRONMENT}
  kubectl get ingress -n {SYSTEM_NAME}-${ENVIRONMENT}

  echo "✅ GitHub Actions frontend deployment completed successfully!"
  ```

- SonarQube 프로젝트 설정 방법 작성
  - SonarQube에서 프론트엔드 프로젝트 생성
  - 프로젝트 키: `{SERVICE_NAME}-{환경}`
  - 언어: JavaScript/TypeScript
  - Quality Gate 설정:
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

- 롤백 방법 작성
  - GitHub Actions에서 이전 버전으로 롤백:
    ```bash
    # 이전 워크플로우 실행으로 롤백
    1. GitHub > Actions > 성공한 이전 워크플로우 선택
    2. Re-run all jobs 클릭
    ```
  - kubectl을 이용한 롤백:
    ```bash
    # 특정 버전으로 롤백
    kubectl rollout undo deployment/{SERVICE_NAME} -n {SYSTEM_NAME}-{환경} --to-revision=2

    # 롤백 상태 확인
    kubectl rollout status deployment/{SERVICE_NAME} -n {SYSTEM_NAME}-{환경}
    ```
  - 수동 스크립트를 이용한 롤백:
    ```bash
    # 이전 안정 버전 이미지 태그로 배포
    ./.github/scripts/deploy-actions-frontend.sh {환경} {이전태그}
    ```

[체크리스트]
GitHub Actions CI/CD 파이프라인 구축 작업을 누락 없이 진행하기 위한 체크리스트입니다.

## 📋 사전 준비 체크리스트
- [ ] package.json에서 시스템명과 서비스명 확인 완료
- [ ] 실행정보 섹션에서 ACR명, 리소스 그룹, AKS 클러스터명 확인 완료

## 📂 GitHub Actions 전용 Kustomize 구조 생성 체크리스트
- [ ] 디렉토리 구조 생성: `.github/kustomize/{base,overlays/{dev,staging,prod}}`
- [ ] 기존 k8s 매니페스트를 base로 복사 완료
- [ ] **리소스 누락 방지 검증 완료**:
  - [ ] `ls .github/kustomize/base/` 명령으로 모든 파일 확인
  - [ ] 필수 파일 존재 확인 (deployment.yaml, service.yaml, configmap.yaml, ingress.yaml 필수)
- [ ] Base kustomization.yaml 파일 생성 완료
  - [ ] 모든 리소스 파일 포함 확인
- [ ] **검증 명령어 실행 완료**:
  - [ ] `kubectl kustomize .github/kustomize/base/` 정상 실행 확인
  - [ ] 에러 메시지 없이 모든 리소스 출력 확인

## 🔧 GitHub Actions 전용 환경별 Overlay 구성 체크리스트
### 공통 체크 사항
- **base 매니페스트에 없는 항목을 추가하지 않았는지 체크**
- **base 매니페스트와 항목이 일치 하는지 체크**
- **⚠️ Kustomize patch 방법 변경**: `patchesStrategicMerge` → `patches` (target 명시)

### DEV 환경
- [ ] `.github/kustomize/overlays/dev/kustomization.yaml` 생성 완료
- [ ] `.github/kustomize/overlays/dev/configmap-patch.yaml` 생성 완료 (개발 API 엔드포인트)
- [ ] `.github/kustomize/overlays/dev/ingress-patch.yaml` 생성 완료 (**Host 기본값은 base의 ingress.yaml과 동일**)
- [ ] `.github/kustomize/overlays/dev/deployment-patch.yaml` 생성 완료 (replicas=1, dev 리소스)

### STAGING 환경
- [ ] `.github/kustomize/overlays/staging/kustomization.yaml` 생성 완료
- [ ] `.github/kustomize/overlays/staging/configmap-patch.yaml` 생성 완료 (스테이징 API 엔드포인트)
- [ ] `.github/kustomize/overlays/staging/ingress-patch.yaml` 생성 완료 (staging 도메인, HTTPS, SSL 인증서)
- [ ] `.github/kustomize/overlays/staging/deployment-patch.yaml` 생성 완료 (replicas=2, staging 리소스)

### PROD 환경
- [ ] `.github/kustomize/overlays/prod/kustomization.yaml` 생성 완료
- [ ] `.github/kustomize/overlays/prod/configmap-patch.yaml` 생성 완료 (운영 API 엔드포인트)
- [ ] `.github/kustomize/overlays/prod/ingress-patch.yaml` 생성 완료 (prod 도메인, HTTPS, SSL 인증서)
- [ ] `.github/kustomize/overlays/prod/deployment-patch.yaml` 생성 완료 (replicas=3, prod 리소스)

## ⚙️ GitHub Actions 설정 및 스크립트 체크리스트
- [ ] 환경별 설정 파일 생성: `.github/config/deploy_env_vars_{dev,staging,prod}`
- [ ] GitHub Actions 워크플로우 파일 `.github/workflows/frontend-cicd.yaml` 생성 완료
- [ ] 워크플로우 주요 내용 확인
  - Build, SonarQube, Docker Build & Push, Deploy 단계 포함
  - Node.js 버전 확인: `node-version: '{NODE_VERSION}'`
  - 변수 참조 문법 확인: `${{ needs.build.outputs.* }}` 사용
  - 서비스명이 실제 프로젝트 서비스명으로 치환되었는지 확인
  - **환경 변수 SKIP_SONARQUBE 처리 확인**: 기본값 'true', 조건부 실행
  - **플레이스홀더 사용 확인**: {ACR_NAME}, {SYSTEM_NAME}, {SERVICE_NAME} 등

- [ ] 수동 배포 스크립트 `.github/scripts/deploy-actions-frontend.sh` 생성 완료
- [ ] 스크립트 실행 권한 설정 완료 (`chmod +x .github/scripts/*.sh`)

[결과파일]
- 가이드: .github/actions-pipeline-guide.md
- GitHub Actions 워크플로우: .github/workflows/frontend-cicd.yaml
- GitHub Actions 전용 Kustomize 매니페스트: .github/kustomize/*
- GitHub Actions 전용 환경별 설정 파일: .github/config/*
- GitHub Actions 전용 수동배포 스크립트: .github/scripts/deploy-actions-frontend.sh