# 백엔드 GitHub Actions 파이프라인 작성 가이드

[요청사항]  
- GitHub Actions 기반 CI/CD 파이프라인 구축 가이드 작성  
- 환경별(dev/staging/prod) Kustomize 매니페스트 관리 및 자동 배포 구현
- SonarQube 코드 품질 분석과 Quality Gate 포함
- Kustomize 매니페스트 생성부터 배포까지 전체 과정 안내
- '[결과파일]'에 구축 방법 및 파이프라인 작성 가이드 생성    
- 아래 작업은 실제 수행하여 파일 생성
  - Kustomize 디렉토리 구조 생성
  - Base Kustomization 작성
  - 환경별 Overlay 작성
  - 환경별 Patch 파일 생성
  - GitHub Actions 워크플로우 파일 작성
  - 환경별 배포 변수 파일 작성
  - 수동 배포 스크립트 작성
  
[작업순서]
- 사전 준비사항 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인  
  - {ACR_NAME}: Azure Container Registry 이름
  - {RESOURCE_GROUP}: Azure 리소스 그룹명
  - {AKS_CLUSTER}: AKS 클러스터명
  - {NAMESPACE}: Namespace명 
  예시)
  ```
  [실행정보]
  - ACR_NAME: acrdigitalgarage01
  - RESOURCE_GROUP: rg-digitalgarage-01
  - AKS_CLUSTER: aks-digitalgarage-01
  - NAMESPACE: phonebill-dg0500
  ``` 
  
- 시스템명과 서비스명 확인     
  settings.gradle에서 확인.  
  - {SYSTEM_NAME}: rootProject.name
  - {SERVICE_NAMES}: include 'common'하위의 include문 뒤의 값임

  예시) include 'common'하위의 서비스명들.
  ```
  rootProject.name = 'phonebill'

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
      "tenantId": "4f0a3bfd-1156-4cce-8dc2-a049a13dba23",
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
    - **수동 실행**: Actions 탭 > "Backend Services CI/CD" > "Run workflow" 버튼 클릭
      - Environment: dev/staging/prod 선택
      - Skip SonarQube Analysis: true/false 선택

- Kustomize 디렉토리 구조 생성      
  - GitHub Actions 전용 Kustomize 디렉토리 생성   
    ```bash
    mkdir -p .github/kustomize/{base,overlays/{dev,staging,prod}}
    mkdir -p .github/kustomize/base/{common,{서비스명1},{서비스명2},...}
    mkdir -p .github/{config,scripts}
    ```
  - 기존 k8s 매니페스트를 base로 복사
    ```bash
    # 기존 deployment/k8s/* 파일들을 base로 복사 
    cp deployment/k8s/common/* .github/kustomize/base/common/
    cp deployment/k8s/{서비스명}/* .github/kustomize/base/{서비스명}/
    
    # 네임스페이스 하드코딩 제거
    find .github/kustomize/base -name "*.yaml" -exec sed -i 's/namespace: .*//' {} \;
    ``` 

- Base Kustomization 작성 
  `.github/kustomize/base/kustomization.yaml` 파일 생성    
  ```yaml
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization

  metadata:
    name: {SYSTEM_NAME}-base

  resources:
    # Common resources
    - common/configmap-common.yaml
    - common/secret-common.yaml
    - common/secret-imagepull.yaml
    - common/ingress.yaml

    # 각 서비스별 리소스
    - {SERVICE_NAME}/deployment.yaml
    - {SERVICE_NAME}/service.yaml
    - {SERVICE_NAME}/configmap.yaml
    - {SERVICE_NAME}/secret.yaml

  images:
    - name: {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}
      newTag: latest
  ```

- 환경별 Patch 파일 생성
  각 환경별로 필요한 patch 파일들을 생성합니다.   
  **중요원칙**:  
  - **base 매니페스트에 없는 항목은 추가 안함**
  - **base 매니페스트와 항목이 일치해야 함**
  - Secret 매니페스트에 'data'가 아닌 'stringData'사용

  **1. ConfigMap Common Patch 파일 생성**   
  `.github/kustomize/overlays/{ENVIRONMENT}/cm-common-patch.yaml`  

  - base 매니페스트를 환경별로 복사
    ```
    cp .github/kustomize/base/common/cm-common.yaml .github/kustomize/overlays/{ENVIRONMENT}/cm-common-patch.yaml
    ```

  - SPRING_PROFILES_ACTIVE를 환경에 맞게 설정 (dev/staging/prod)
  - DDL_AUTO 설정: dev는 "update", staging/prod는 "validate"
  - JWT 토큰 유효시간은 prod에서 보안을 위해 짧게 설정

  **2. Secret Common Patch 파일 생성**    
  `.github/kustomize/overlays/{ENVIRONMENT}/secret-common-patch.yaml`     

  - base 매니페스트를 환경별로 복사
    ```
    cp .github/kustomize/base/common/secret-common.yaml .github/kustomize/overlays/{ENVIRONMENT}/secret-common-patch.yaml
    ```
  
  **3. Ingress Patch 파일 생성**  
  `.github/kustomize/overlays/{ENVIRONMENT}/ingress-patch.yaml`   
  - base의 ingress.yaml을 환경별로 오버라이드
  - **⚠️ 중요**: 개발환경 Ingress Host의 기본값은 base의 ingress.yaml과 **정확히 동일하게** 함
    - base에서 `host: {SYSTEM_NAME}-api.20.214.196.128.nip.io` 이면
    - dev에서도 `host: {SYSTEM_NAME}-api.20.214.196.128.nip.io` 로 동일하게 설정
    - **절대** `{SYSTEM_NAME}-dev-api.xxx` 처럼 변경하지 말 것
  - Staging/Prod 환경별 도메인 설정: {SYSTEM_NAME}.도메인 형식
  - service name을 '{서비스명}'으로 함.
  - Staging/prod 환경은 HTTPS 강제 적용 및 SSL 인증서 설정
  - staging/prod는 nginx.ingress.kubernetes.io/ssl-redirect: "true"
  - dev는 nginx.ingress.kubernetes.io/ssl-redirect: "false"

  **4. deployment Patch 파일 생성** ⚠️ **중요**  
  각 서비스별로 별도 파일 생성    
  `.github/kustomize/overlays/{ENVIRONMENT}/deployment-{SERVICE_NAME}-patch.yaml`   

  **필수 포함 사항:**  
  - ✅ **replicas 설정**: 각 서비스별 Deployment의 replica 수를 환경별로 설정
    - dev: 모든 서비스 1 replica (리소스 절약)
    - staging: 모든 서비스 2 replicas
    - prod: 모든 서비스 3 replicas
  - ✅ **resources 설정**: 각 서비스별 Deployment의 resources를 환경별로 설정
    - dev: requests(256m CPU, 256Mi Memory), limits(1024m CPU, 1024Mi Memory)
    - staging: requests(512m CPU, 512Mi Memory), limits(2048m CPU, 2048Mi Memory)
    - prod: requests(1024m CPU, 1024Mi Memory), limits(4096m CPU, 4096Mi Memory)

  **5. Secret Service Patch 파일 생성**  
  각 서비스별로 별도 파일 생성  
  `.github/kustomize/overlays/{ENVIRONMENT}/secret-{SERVICE_NAME}-patch.yaml`   

  - base 매니페스트를 환경별로 복사
    ```
    cp .github/kustomize/base/{SERVICE_NAME}/secret-{SERVICE_NAME}.yaml .github/kustomize/overlays/{ENVIRONMENT}/secret-{SERVICE_NAME}-patch.yaml
    ```
  - 환경별 데이터베이스 연결 정보로 수정  
  - **⚠️ 중요**: 패스워드 등 민감정보는 실제 환경 구축 시 별도 설정
  
- 환경별 Overlay 작성   
  각 환경별로 `overlays/{환경}/kustomization.yaml` 생성   
  ```yaml
  apiVersion: kustomize.config.k8s.io/v1beta1
  kind: Kustomization

  namespace: {NAMESPACE}

  resources:
    - ../../base

  patches:
    - path: cm-common-patch.yaml
      target:
        kind: ConfigMap
        name: cm-common
    - path: deployment-{SERVICE_NAME}-patch.yaml
      target:
        kind: Deployment
        name: {SERVICE_NAME}
    - path: ingress-patch.yaml
      target:
        kind: Ingress
        name: {SYSTEM_NAME}
    - path: secret-common-patch.yaml
      target:
        kind: Secret
        name: secret-common
    - path: secret-{SERVICE_NAME}-patch.yaml
      target:
        kind: Secret
        name: secret-{SERVICE_NAME}

  images:
    - name: {ACR_NAME}.azurecr.io/{SYSTEM_NAME}/{SERVICE_NAME}
      newTag: {ENVIRONMENT}-latest

  ```
  
- GitHub Actions 워크플로우 작성   
  `.github/workflows/backend-cicd.yaml` 파일 생성 방법을 안내합니다.   
  
  주요 구성 요소:  
  - **Build & Test**: Gradle 기반 빌드 및 단위 테스트
  - **SonarQube Analysis**: 코드 품질 분석 및 Quality Gate
  - **Container Build & Push**: 환경별 이미지 태그로 빌드 및 푸시
  - **Kustomize Deploy**: 환경별 매니페스트 적용

  ```yaml
  name: Backend Services CI/CD

  on:
    push:
      branches: [ main, develop ]
      paths:
        - '{서비스명1}/**'
        - '{서비스명2}/**'
        - '{서비스명3}/**'
        - '{서비스명N}/**'
        - 'common/**'
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
    REGISTRY: ${{ secrets.REGISTRY }}
    IMAGE_ORG: ${{ secrets.IMAGE_ORG }}
    RESOURCE_GROUP: ${{ secrets.RESOURCE_GROUP }}
    AKS_CLUSTER: ${{ secrets.AKS_CLUSTER }}

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

        - name: Set up JDK {버전}
          uses: actions/setup-java@v3
          with:
            java-version: '{JDK버전}'
            distribution: 'temurin'
            cache: 'gradle'

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
            NAMESPACE="{NAMESPACE}"
            
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

        - name: Grant execute permission for gradlew
          run: chmod +x gradlew

        - name: Build with Gradle
          run: |
            ./gradlew build -x test

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
            
            # Define services array
            services=({SERVICE_NAME1} {SERVICE_NAME2} {SERVICE_NAME3} {SERVICE_NAMEN})
            
            # Run tests, coverage reports, and SonarQube analysis for each service
            for service in "${services[@]}"; do
              ./gradlew :$service:test :$service:jacocoTestReport :$service:sonar \
                -Dsonar.projectKey={SYSTEM_NAME}-$service-${{ steps.determine_env.outputs.environment }} \
                -Dsonar.projectName={SYSTEM_NAME}-$service-${{ steps.determine_env.outputs.environment }} \
                -Dsonar.host.url=$SONAR_HOST_URL \
                -Dsonar.token=$SONAR_TOKEN \
                -Dsonar.java.binaries=build/classes/java/main \
                -Dsonar.coverage.jacoco.xmlReportPaths=build/reports/jacoco/test/jacocoTestReport.xml \
                -Dsonar.exclusions=**/config/**,**/entity/**,**/dto/**,**/*Application.class,**/exception/**
            done

        - name: Upload build artifacts
          uses: actions/upload-artifact@v4
          with:
            name: app-builds
            path: |
              {SERVICE_NAME1}/build/libs/*.jar
              {SERVICE_NAME2}/build/libs/*.jar
              {SERVICE_NAME3}/build/libs/*.jar
              {SERVICE_NAMEN}/build/libs/*.jar

        - name: Set outputs
          id: set_outputs
          run: |
            # Generate timestamp for image tag
            IMAGE_TAG=$(date +%Y%m%d%H%M%S)
            echo "image_tag=$IMAGE_TAG" >> $GITHUB_OUTPUT
            echo "environment=${{ steps.determine_env.outputs.environment }}" >> $GITHUB_OUTPUT

    release:
      name: Build and Push Docker Images
      needs: build
      runs-on: ubuntu-latest

      steps:
        - name: Check out code
          uses: actions/checkout@v4

        - name: Download build artifacts
          uses: actions/download-artifact@v4
          with:
            name: app-builds

        - name: Set environment variables from build job
          run: |
            echo "REGISTRY=${{ needs.build.outputs.registry }}" >> $GITHUB_ENV
            echo "IMAGE_ORG=${{ needs.build.outputs.image_org }}" >> $GITHUB_ENV
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

        - name: Build and push Docker images for all services
          run: |
            # Define services array
            services=({SERVICE_NAME1} {SERVICE_NAME2} {SERVICE_NAME3} {SERVICE_NAMEN})
            
            # Build and push each service image
            for service in "${services[@]}"; do
              echo "Building and pushing $service..."
              docker build \
                --build-arg BUILD_LIB_DIR="$service/build/libs" \
                --build-arg ARTIFACTORY_FILE="$service.jar" \
                -f deployment/container/Dockerfile-backend \
                -t ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/$service:${{ needs.build.outputs.environment }}-${{ needs.build.outputs.image_tag }} .
              
              docker push ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/$service:${{ needs.build.outputs.environment }}-${{ needs.build.outputs.image_tag }}
            done

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
            kubectl create namespace ${{ env.NAMESPACE }} --dry-run=client -o yaml | kubectl apply -f -

        - name: Install Kustomize
          run: |
            curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
            sudo mv kustomize /usr/local/bin/

        - name: Update Kustomize images and deploy
          run: |
            # 환경별 디렉토리로 이동
            cd deployment/cicd/kustomize/overlays/${{ env.ENVIRONMENT }}

            # 각 서비스별 이미지 태그 업데이트
            kustomize edit set image ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/api-gateway:${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}
            kustomize edit set image ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/user-service:${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}
            kustomize edit set image ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/bill-service:${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}
            kustomize edit set image ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/product-service:${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}
            kustomize edit set image ${{ env.REGISTRY }}/${{ env.IMAGE_ORG }}/kos-mock:${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}

            # 매니페스트 적용
            kubectl apply -k .

        - name: Wait for deployments to be ready
          run: |
            echo "Waiting for deployments to be ready..."
            kubectl -n ${{ env.NAMESPACE }} wait --for=condition=available deployment/${{ env.ENVIRONMENT }}-api-gateway --timeout=300s
            kubectl -n ${{ env.NAMESPACE }} wait --for=condition=available deployment/${{ env.ENVIRONMENT }}-user-service --timeout=300s
            kubectl -n ${{ env.NAMESPACE }} wait --for=condition=available deployment/${{ env.ENVIRONMENT }}-bill-service --timeout=300s
            kubectl -n ${{ env.NAMESPACE }} wait --for=condition=available deployment/${{ env.ENVIRONMENT }}-product-service --timeout=300s
            kubectl -n ${{ env.NAMESPACE }} wait --for=condition=available deployment/${{ env.ENVIRONMENT }}-kos-mock --timeout=300s

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
    kubectl rollout undo deployment/{환경}-{서비스명} -n {NAMESPACE} --to-revision=2
    
    # 롤백 상태 확인
    kubectl rollout status deployment/{환경}-{서비스명} -n {NAMESPACE}
    ```
  - 수동 스크립트를 이용한 롤백:
    ```bash
    # 이전 안정 버전 이미지 태그로 배포
    ./deployment/cicd/scripts/deploy-actions.sh {환경} {이전태그}
    ```
  
[체크리스트]
GitHub Actions CI/CD 파이프라인 구축 작업을 누락 없이 진행하기 위한 체크리스트입니다.
  
## 📋 사전 준비 체크리스트
- [ ] settings.gradle에서 시스템명과 서비스명 확인 완료
- [ ] 실행정보 섹션에서 ACR명, 리소스 그룹, AKS 클러스터명 확인 완료

## 📂 GitHub Actions 전용 Kustomize 구조 생성 체크리스트
- [ ] 디렉토리 구조 생성: `.github/kustomize/{base,overlays/{dev,staging,prod}}`
- [ ] 서비스별 base 디렉토리 생성: `.github/kustomize/base/{common,{서비스명들}}`
- [ ] 기존 k8s 매니페스트를 base로 복사 완료
- [ ] **리소스 누락 방지 검증 완료**:
  - [ ] `ls .github/kustomize/base/*/` 명령으로 모든 서비스 디렉토리의 파일 확인
  - [ ] 각 서비스별 필수 파일 존재 확인 (deployment.yaml, service.yaml 필수)
  - [ ] ConfigMap 파일 존재 시 `cm-{서비스명}.yaml` 명명 규칙 준수 확인
  - [ ] Secret 파일 존재 시 `secret-{서비스명}.yaml` 명명 규칙 준수 확인
- [ ] Base kustomization.yaml 파일 생성 완료
  - [ ] 모든 서비스의 deployment.yaml, service.yaml 포함 확인
  - [ ] 존재하는 모든 ConfigMap 파일 포함 확인 (`cm-{서비스명}.yaml`)
  - [ ] 존재하는 모든 Secret 파일 포함 확인 (`secret-{서비스명}.yaml`)
- [ ] **검증 명령어 실행 완료**:
  - [ ] `kubectl kustomize .github/kustomize/base/` 정상 실행 확인
  - [ ] 에러 메시지 없이 모든 리소스 출력 확인

## 🔧 GitHub Actions 전용 환경별 Overlay 구성 체크리스트
### 중요 체크 사항
- Base Kustomization에서 존재하지 않는 Secret 파일들 제거

### 공통 체크 사항
- **base 매니페스트에 없는 항목을 추가하지 않았는지 체크**
- **base 매니페스트와 항목이 일치 하는지 체크**
- Secret 매니페스트에 'data'가 아닌 'stringData'사용했는지 체크
- **⚠️ Kustomize patch 방법 변경**: `patchesStrategicMerge` → `patches` (target 명시)

### DEV 환경
- [ ] `.github/kustomize/overlays/dev/kustomization.yaml` 생성 완료
- [ ] `.github/kustomize/overlays/dev/cm-common-patch.yaml` 생성 완료 (dev 프로파일, update DDL)
- [ ] `.github/kustomize/overlays/dev/secret-common-patch.yaml` 생성 완료
- [ ] `.github/kustomize/overlays/dev/ingress-patch.yaml` 생성 완료 (**Host 기본값은 base의 ingress.yaml과 동일**)
- [ ] `.github/kustomize/overlays/dev/deployment-{서비스명}-patch.yaml` 생성 완료 (replicas, resources 지정)
- [ ] 각 서비스별 `.github/kustomize/overlays/dev/secret-{서비스명}-patch.yaml` 생성 완료

### STAGING 환경
- [ ] `.github/kustomize/overlays/staging/kustomization.yaml` 생성 완료
- [ ] `.github/kustomize/overlays/staging/cm-common-patch.yaml` 생성 완료 (staging 프로파일, validate DDL)
- [ ] `.github/kustomize/overlays/staging/secret-common-patch.yaml` 생성 완료
- [ ] `.github/kustomize/overlays/staging/ingress-patch.yaml` 생성 완료 (prod 도메인, HTTPS, SSL 인증서)
- [ ] `.github/kustomize/overlays/staging/deployment-{서비스명}-patch.yaml` 생성 완료 (replicas, resources 지정)
- [ ] 각 서비스별 `.github/kustomize/overlays/staging/secret-{서비스명}-patch.yaml` 생성 완료

### PROD 환경
- [ ] `.github/kustomize/overlays/prod/kustomization.yaml` 생성 완료
- [ ] `.github/kustomize/overlays/prod/cm-common-patch.yaml` 생성 완료 (prod 프로파일, validate DDL, 짧은 JWT)
- [ ] `.github/kustomize/overlays/prod/secret-common-patch.yaml` 생성 완료
- [ ] `.github/kustomize/overlays/prod/ingress-patch.yaml` 생성 완료 (prod 도메인, HTTPS, SSL 인증서)
- [ ] `.github/kustomize/overlays/prod/deployment-{서비스명}-patch.yaml` 생성 완료 (replicas, resources 지정)
- [ ] 각 서비스별 `.github/kustomize/overlays/prod/secret-{서비스명}-patch.yaml` 생성 완료

## ⚙️ GitHub Actions 설정 및 스크립트 체크리스트
- [ ] 환경별 설정 파일 생성: `.github/config/deploy_env_vars_{dev,staging,prod}`
- [ ] GitHub Actions 워크플로우 파일 `.github/workflows/backend-cicd.yaml` 생성 완료
- [ ] 워크플로우 주요 내용 확인
  - Build, SonarQube, Docker Build & Push, Deploy 단계 포함
  - JDK 버전 확인: `java-version: '{JDK버전}'`
  - 변수 참조 문법 확인: `${{ needs.build.outputs.* }}` 사용
  - 모든 서비스명이 실제 프로젝트 서비스명으로 치환되었는지 확인
  - **환경 변수 SKIP_SONARQUBE 처리 확인**: 기본값 'true', 조건부 실행
  - **플레이스홀더 사용 확인**: {ACR_NAME}, {SYSTEM_NAME}, {SERVICE_NAME} 등

- [ ] 수동 배포 스크립트 `.github/scripts/deploy-actions.sh` 생성 완료
- [ ] 스크립트 실행 권한 설정 완료 (`chmod +x .github/scripts/*.sh`)
  
[결과파일]
- 가이드: .github/actions-pipeline-guide.md
- GitHub Actions 워크플로우: .github/workflows/backend-cicd.yaml
- GitHub Actions 전용 Kustomize 매니페스트: .github/kustomize/*
- GitHub Actions 전용 환경별 설정 파일: .github/config/*
