# ArgoCD 파이프라인 작성 가이드 

[요청사항]  
- CI/CD 파이프라인에서 CI와 CD를 분리하여 ArgoCD를 활용한 GitOps 방식의 배포 준비 수행   
- 환경별(dev/staging/prod) Kustomize 매니페스트 관리 및 자동 배포 구현
- '[결과파일]'에 수행 결과 작성

[작업순서]
- 사전 준비사항 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인  
  - {SYSTEM_NAME}: 대표 시스템명 
  - {FRONTEND_SERVICE}: 프론트엔드 서비스명
  - {IMG_REG}: Container Image Registry 주소
  - {IMG_ORG}: Container Image Organization
  - {MANIFEST_REPO_URL}: 'git remote get-url origin' 명령으로 매니페스트 원격 주소를 구함  
  - {JENKINS_GIT_CREDENTIALS}: 매니페스트 레포지토리를 접근하기 위한 Jenkins Credential. Jenkins기반일때만 필요    
  - {MANIFEST_SECRET_GIT_USERNAME}: 매니페스트 레포지토리를 접근하기 위한 Git Username을 정의한 GitHub Action 변수명. GitHub Actions에만 필요
  - {MANIFEST_SECRET_GIT_PASSWORD}: 매니페스트 레포지토리를 접근하기 위한 Git Password을 정의한 GitHub Action 변수명. GitHub Actions에만 필요 
  
  예시)
  ```
  [실행정보]
  - SYSTEM_NAME: phonebill
  - FRONTEND_SERVICE: phonebill-front
  - IMG_REG: docker.io
  - IMG_ORG: hiondal
  - MANIFEST_REPO_URL: https://github.com/cna-bootcamp/phonebill-manifest.git
  - JENKINS_GIT_CREDENTIALS: github-credentials-dg0500
  - MANIFEST_SECRET_GIT_USERNAME: GIT_USERNAME
  - MANIFEST_SECRET_GIT_PASSWORD: GIT_PASSWORD
  ``` 

- 작업 편의를 위한 환경변수   
  - {BASE_DIR}: ..
  - {BACKEND_DIR}: ${BASE_DIR}/${SYSTEM_NAME}
  - {FRONTEND_DIR}: ${BASE_DIR}/${FRONTEND_SERVICE}
  - {MANIFEST_DIR}: .
  
- 백엔드 서비스명 확인   
  ${BACKEND_DIR}/settings.gradle에서 확인.
  {SERVICE_NAMES}: include 'common'하위의 include문 뒤의 값임

  예시) include 'common'하위의 서비스명들.
  ```
  rootProject.name = 'phonebill'

  include 'common'
  include 'api-gateway'
  include 'user-service'
  include 'order-service'
  include 'payment-service'
  ```  

- 매니페스트 레포지토리 구성
  - 백엔드 매니페스트 복사
  ```bash
  mkdir -p ${MANIFEST_DIR}/${SYSTEM_NAME}
  cp -r ${BACKEND_DIR}/deployment/cicd/kustomize ${MANIFEST_DIR}/${SYSTEM_NAME}/
  ```
  - 프론트엔드 매니페스트 복사
  ```bash
  # 프론트엔드 매니페스트 디렉토리 생성 및 복사
  mkdir -p ${MANIFEST_DIR}/${FRONTEND_SERVICE}
  cp -r ${FRONTEND_DIR}/deployment/cicd/kustomize ${MANIFEST_DIR}/${FRONTEND_SERVICE}/
  ```

- CI/CD가 분리된 Jenkins 파이프라인 스크립트 작성
  (중요) 'JENKINS_GIT_CREDENTIALS' 값이 있는 경우만 수행.  

  **분석된 기존 파이프라인 구조:**
  - Build & Test → SonarQube Analysis → Build & Push Images → **Deploy (직접 K8s 배포)**

  **ArgoCD 적용 시 변경사항:**
  - Deploy 단계를 **매니페스트 레포지토리 업데이트**로 교체
  - `kubectl apply` 제거하고 `git push`로 ArgoCD 트리거
  - Git 전용 컨테이너 추가로 매니페스트 업데이트 작업 분리

  **컨테이너 템플릿 추가:**
  Jenkins 파이프라인의 containers 섹션에 Git 컨테이너 추가:
  ```
  containers: [
      // 기존 컨테이너들...
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
          name: 'git',
          image: 'alpine/git:latest',
          command: 'cat',
          ttyEnabled: true,
          resourceRequestCpu: '100m',
          resourceRequestMemory: '256Mi',
          resourceLimitCpu: '300m',
          resourceLimitMemory: '512Mi'
      )
  ]
  ```

  **1) 백엔드 Jenkins 파이프라인 수정**
  - 기존 파일을 새 파일로 복사
    ```
    cp ${BACKEND_DIR}/deployment/cicd/Jenkinsfile ${BACKEND_DIR}/deployment/cicd/Jenkinsfile_ArgoCD
    ```

 - Jenkinsfile_ArgoCD파일을 ArgoCD용으로 수정: 'Update Kustomize & Deploy' 스테이지를 다음으로 교체
    ```
    stage('Update Manifest Repository') {
        container('git') {
            withCredentials([usernamePassword(
                credentialsId: '{JENKINS_GIT_CREDENTIALS}',
                usernameVariable: 'GIT_USERNAME',
                passwordVariable: 'GIT_TOKEN'
            )]) {
                sh """
                    # 매니페스트 레포지토리 클론
                    REPO_URL=\$(echo "{MANIFEST_REPO_URL}" | sed 's|https://||')
                    git clone https://\${GIT_USERNAME}:\${GIT_TOKEN}@\${REPO_URL} manifest-repo
                    cd manifest-repo

                    # 각 서비스별 이미지 태그 업데이트 (sed 명령 사용)
                    services="{SERVICE_NAMES}"
                    for service in \$services; do
                        echo "Updating \$service image tag..."
                        sed -i "s|image: {IMG_REG}/{IMG_ORG}/\$service:.*|image: {IMG_REG}/{IMG_ORG}/\$service:${environment}-${imageTag}|g" \\
                            {SYSTEM_NAME}/kustomize/base/\$service/deployment.yaml

                        # 변경 사항 확인
                        echo "Updated \$service deployment.yaml:"
                        grep "image: {IMG_REG}/{IMG_ORG}/\$service" {SYSTEM_NAME}/kustomize/base/\$service/deployment.yaml
                    done

                    # Git 설정 및 푸시
                    git config user.name "Jenkins CI"
                    git config user.email "jenkins@example.com"
                    git add .
                    git commit -m "🚀 Update {SYSTEM_NAME} ${environment} images to ${environment}-${imageTag}"
                    git push origin main

                    echo "✅ 매니페스트 업데이트 완료. ArgoCD가 자동으로 배포합니다."
                """
            }
        }
    }
    ```

  **2) 프론트엔드 Jenkins 파이프라인 수정**
  - 기존 파일을 새 파일로 복사
    ```
    cp ${FRONTEND_DIR}/deployment/cicd/Jenkinsfile ${FRONTEND_DIR}/deployment/cicd/Jenkinsfile_ArgoCD
    ```
  - Jenkinsfile_ArgoCD파일을 ArgoCD용으로 수정: 'Update Kustomize & Deploy' 스테이지를 다음으로 교체
 
    ```
    stage('Update Frontend Manifest Repository') {
        container('git') {
            withCredentials([usernamePassword(
                credentialsId: '{JENKINS_GIT_CREDENTIALS}',
                usernameVariable: 'GIT_USERNAME',
                passwordVariable: 'GIT_TOKEN'
            )]) {
                sh """
                    # 매니페스트 레포지토리 클론
                    REPO_URL=\$(echo "{MANIFEST_REPO_URL}" | sed 's|https://||')
                    git clone https://\${GIT_USERNAME}:\${GIT_TOKEN}@\${REPO_URL} manifest-repo
                    cd manifest-repo

                    echo "Updating {FRONTEND_SERVICE} image tag..."
                    sed -i "s|image: {IMG_REG}/{IMG_ORG}/{FRONTEND_SERVICE}:.*|image: {IMG_REG}/{IMG_ORG}/{FRONTEND_SERVICE}:${environment}-${imageTag}|g" \\
                        {FRONTEND_SERVICE}/kustomize/base/deployment.yaml

                    # 변경 사항 확인
                    echo "Updated {FRONTEND_SERVICE} deployment.yaml:"
                    grep "image: {IMG_REG}/{IMG_ORG}/{FRONTEND_SERVICE}" {FRONTEND_SERVICE}/kustomize/base/deployment.yaml
                    
                    # Git 설정 및 푸시
                    cd ../../../..
                    git config user.name "Jenkins CI"
                    git config user.email "jenkins@example.com"
                    git add .
                    git commit -m "🚀 Update {FRONTEND_SERVICE} \${environment} image to \${environment}-\${imageTag}"
                    git push origin main

                    echo "✅ 프론트엔드 매니페스트 업데이트 완료. ArgoCD가 자동으로 배포합니다."
                """
            }
        }
    }
    ```

- CI/CD가 분리된 GitHub Actions Workflow 작성
  (중요) 'MANIFEST_SECRET_GIT_USERNAME'과 'MANIFEST_SECRET_GIT_PASSWORD'가 있는 경우만 수행.   
  **1) 백엔드 GitHub Actions Workflow 수정**
  - 기존 파일을 새 파일로 복사
    ```
    cp ${BACKEND_DIR}/.github/workflows/backend-cicd.yaml ${BACKEND_DIR}/.github/workflows/backend-cicd_ArgoCD.yaml
    ```

  - backend-cicd_ArgoCD.yaml의 deploy job을 **update-manifest** job으로 교체
  ```
  update-manifest:
    name: Update Manifest Repository
    needs: [build, release]
    runs-on: ubuntu-latest

    steps:
    - name: Set image tag environment variable
      run: |
        echo "IMAGE_TAG=${{ needs.build.outputs.image_tag }}" >> $GITHUB_ENV
        echo "ENVIRONMENT=${{ needs.build.outputs.environment }}" >> $GITHUB_ENV

    - name: Update Manifest Repository
      run: |
        # 매니페스트 레포지토리 클론
        REPO_URL=$(echo "{MANIFEST_REPO_URL}" | sed 's|https://||')
        git clone https://${{ secrets.{MANIFEST_SECRET_GIT_USERNAME} }}:${{ secrets.{MANIFEST_SECRET_GIT_PASSWORD} }}@${REPO_URL} manifest-repo
        cd manifest-repo

        # Kustomize 설치
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
        sudo mv kustomize /usr/local/bin/

        # 매니페스트 업데이트
        cd {SYSTEM_NAME}/kustomize/overlays/${{ env.ENVIRONMENT }}

        # 각 서비스별 이미지 태그 업데이트
        services="{SERVICE_NAMES}"
        for service in $services; do
          kustomize edit set image {IMG_REG}/{IMG_ORG}/$service:${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}
        done

        # Git 설정 및 푸시
        cd ../../../..
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"
        git add .
        git commit -m "🚀 Update {SYSTEM_NAME} ${{ env.ENVIRONMENT }} images to ${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}"
        git push origin main

        echo "✅ 매니페스트 업데이트 완료. ArgoCD가 자동으로 배포합니다."
  ```

  **2) 프론트엔드 GitHub Actions Workflow 수정**
  - 기존 파일을 새 파일로 복사
    ```
    cp ${FRONTEND_DIR}/.github/workflows/frontend-cicd.yaml ${FRONTEND_DIR}/.github/workflows/frontend-cicd_ArgoCD.yaml
    ```
  - frontend-cicd_ArgoCD.yaml의 프론트엔드용 deploy job 교체
    ```
    update-manifest:
      name: Update Frontend Manifest Repository
      needs: [build, release]
      runs-on: ubuntu-latest

      steps:
      - name: Set image tag environment variable
        run: |
          echo "IMAGE_TAG=${{ needs.build.outputs.image_tag }}" >> $GITHUB_ENV
          echo "ENVIRONMENT=${{ needs.build.outputs.environment }}" >> $GITHUB_ENV

      - name: Update Frontend Manifest Repository
        run: |
          # 매니페스트 레포지토리 클론
          REPO_URL=$(echo "{MANIFEST_REPO_URL}" | sed 's|https://||')
          git clone https://${{ secrets.{MANIFEST_SECRET_GIT_USERNAME} }}:${{ secrets.{MANIFEST_SECRET_GIT_PASSWORD} }}@${REPO_URL} manifest-repo
          cd manifest-repo

          # Kustomize 설치
          curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
          sudo mv kustomize /usr/local/bin/

          # 프론트엔드 매니페스트 업데이트
          cd {FRONTEND_SERVICE}/kustomize/overlays/${{ env.ENVIRONMENT }}

          # 이미지 태그 업데이트
          kustomize edit set image {IMG_REG}/{IMG_ORG}/{FRONTEND_SERVICE}:${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}

          # Git 설정 및 푸시
          cd ../../../..
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add .
          git commit -m "🚀 Update {FRONTEND_SERVICE} ${{ env.ENVIRONMENT }} image to ${{ env.ENVIRONMENT }}-${{ env.IMAGE_TAG }}"
          git push origin main

          echo "✅ 프론트엔드 매니페스트 업데이트 완료. ArgoCD가 자동으로 배포합니다."
    ```

[결과파일]
작업결과: deploy-argocd-prepare.md

