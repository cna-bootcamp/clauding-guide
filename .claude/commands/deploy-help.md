---
description: 배포 작업 순서 안내
---

아래 내용을 터미널에 표시합니다:

```
배포 작업 순서

1단계: 백엔드 컨테이너 이미지 작성
/deploy-build-image-back
- 백엔드컨테이너이미지작성가이드에 따라 작성

2단계: 프론트엔드 컨테이너 이미지 작성
/deploy-build-image-front
- 프론트엔드컨테이너이미지작성가이드에 따라 작성

3단계: 백엔드 컨테이너 실행방법 작성
/deploy-run-container-guide-back
- [실행정보] 섹션에 ACR명, VM 정보 제공 필요

4단계: 프론트엔드 컨테이너 실행방법 작성
/deploy-run-container-guide-front
- [실행정보] 섹션에 시스템명, ACR명, VM 정보 제공 필요

5단계: 백엔드 배포 가이드 작성
/deploy-k8s-guide-back
- [실행정보] 섹션에 ACR명, k8s명, 네임스페이스 등 제공 필요

6단계: 프론트엔드 배포 가이드 작성
/deploy-k8s-guide-front
- [실행정보] 섹션에 시스템명, ACR명, k8s명, Gateway Host 등 제공 필요

7단계: CI/CD 파이프라인 작성 (택1)

[Jenkins 사용 시]
/deploy-jenkins-cicd-guide-back - 백엔드 Jenkins CI/CD
/deploy-jenkins-cicd-guide-front - 프론트엔드 Jenkins CI/CD
- [실행정보] 필수: IMG_REG, IMG_ORG, JENKINS_CLOUD_NAME, NAMESPACE

[GitHub Actions 사용 시]
/deploy-actions-cicd-guide-back - 백엔드 GitHub Actions CI/CD
/deploy-actions-cicd-guide-front - 프론트엔드 GitHub Actions CI/CD
- [실행정보] 필수: ACR_NAME, RESOURCE_GROUP, AKS_CLUSTER, NAMESPACE
```
