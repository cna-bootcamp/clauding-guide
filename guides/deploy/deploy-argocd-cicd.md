# ArgoCD 파이프라인 작성 가이드

[요청사항]  
- CI/CD 파이프라인에서 CI와 CD를 분리하여 ArgoCD를 활용한 GitOps 방식의 배포 가이드 작성   
- 환경별(dev/staging/prod) Kustomize 매니페스트 관리 및 자동 배포 구현
- '[결과파일]'에 구축 방법 및 파이프라인 작성 가이드 생성    
- 아래 작업은 실제 수행하여 파일 생성
  - 매니페스트 레포지토리 구성
  - CI/CD가 분리된 Jenkins 파이프라인 스크립트 작성
  - CI/CD가 분리된 GitHub Actions Workflow 작성  

[작업순서]
- 사전 준비사항 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인  
  - {SYSTEM_NAME}: 대표 시스템명 
  - {FRONTEND_SERVICE}: 프론트엔드 서비스명
  - {ACR_NAME}: Azure Container Registry 이름
  - {RESOURCE_GROUP}: Azure 리소스 그룹명
  - {AKS_CLUSTER}: AKS 클러스터명
  - {MANIFEST_REG}: 'git remote get-url origin' 명령으로 매니페스트 원격 주소를 구함  
  - {JENKINS_GIT_CREDENTIALS}: 매니페스트 레포지토리를 접근하기 위한 Jenkins Credential 
  - {MANIFEST_SECRET_GIT_USERNAME}: 매니페스트 레포지토리를 접근하기 위한 Git Username을 정의한 GitHub Action 변수명 
  - {MANIFEST_SECRET_GIT_PASSWORD}: 매니페스트 레포지토리를 접근하기 위한 Git Password을 정의한 GitHub Action 변수명 

  예시)
  ```
  [실행정보]
  - SYSTEM_NAME: phonebill
  - FRONTEND_SERVICE: phonebill-front
  - ACR_NAME: acrdigitalgarage01
  - RESOURCE_GROUP: rg-digitalgarage-01
  - AKS_CLUSTER: aks-digitalgarage-01
  - MANIFEST_REG: https://github.com/cna-bootcamp/phonebill-manifest.git
  - JENKINS_GIT_CREDENTIALS: github-credentials-dg0500
  - MANIFEST_SECRET_GIT_USERNAME: GIT_USERNAME
  - MANIFEST_SECRET_GIT_PASSWORD: GIT_PASSWORD
  ``` 

- 환경변수 생성   
  export BASE_DIR=..

  # 작업 편의를 위한 파생 환경변수
  export BACKEND_DIR=${BASE_DIR}/${SYSTEM_NAME}
  export FRONTEND_DIR=${BASE_DIR}/${FRONTEND_SERVICE}
  export MANIFEST_DIR=.

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
  - 백엔드 Jenkins 파이프라인 스크립트 작성  
    - ${BACKEND_DIR}/deployment/cicd/Jenkisfile을 ${BACKEND_DIR}/deployment/cicd/Jenkisfile_ArgoCD로 복사  
    - Jenkisfile_ArgoCD 변경: 직접 Deploy하지 않고 매니페스트 레포지토리의 Deployment 매니페스트의 이미지명만 변경하여 푸시 하도록 수정 
  - 프론트엔드 Jenkins 파이프라인 스크립트 작성  
    - ${FRONTEND_DIR}/deployment/cicd/Jenkisfile을 ${FRONTEND_DIR}/deployment/cicd/Jenkisfile_ArgoCD로 복사  
    - Jenkisfile_ArgoCD 변경: 직접 Deploy하지 않고 매니페스트 레포지토리의 Deployment 매니페스트의 이미지명만 변경하여 푸시 하도록 수정 

- CI/CD가 분리된 GitHub Actions Workflow 작성
  - 백엔드 GitHub Actions Workflow 작성  
    - ${BACKEND_DIR}/.github/workflows/backend-cicd.yaml을 ${BACKEND_DIR}/.github/workflows/backend-cicd_ArgoCD.yaml로 복사  
    - backend-cicd_ArgoCD.yaml 변경: 직접 Deploy하지 않고 매니페스트 레포지토리의 Deployment 매니페스트의 이미지명만 변경하여 푸시 하도록 수정 
  - 프론트엔드 GitHub Actions Workflow 작성  
    - ${FRONTEND_DIR}/.github/workflows/frontend-cicd.yaml을 ${FRONTEND_DIR}/.github/workflows/frontend-cicd_ArgoCD.yaml로 복사  
    - frontend-cicd_ArgoCD.yaml 변경: 직접 Deploy하지 않고 매니페스트 레포지토리의 Deployment 매니페스트의 이미지명만 변경하여 푸시 하도록 수정 

- Jenkins파이프라인 수행 방법 안내 
  - 'JENKINS_GIT_CREDENTIALS' 작성 방법 안내   
  - 파이프라인 설정 수정 방법 안내 
  - 파이프라인 실행 방법 안내 
  
- GitHub Actions Workflow 수행 방법 안내  
  - 'MANIFEST_SECRET_GIT_USERNAME'과 'MANIFEST_SECRET_GIT_PASSWORD' 작성 방법 안내 
  - GitHub Actions Workflow 실행 방법 안내   

[결과파일]
파이프라인 작성 가이드: deploy-argocd-guide.md

