# 백엔드 배포 가이드

[요청사항]  
- 백엔드 서비스를 쿠버네티스에 배포하기 위한 매니페스트 파일 작성 
- 매니페스트 파일 작성까지만 하고 실제 배포는 수행방법만 가이드  
- '[결과파일]'에 수행한 명령어를 포함하여 배포 가이드 레포트 생성 

[작업순서]
- 실행정보 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인  
  - {ACR명}: 컨테이너 레지스트리 이름 
  - {k8s명}: Kubernetes 클러스터 이름  
  - {네임스페이스}: 배포할 네임스페이스 
  - {파드수}: 생성할 파드수 
  - {리소스(CPU)}: 요청값/최대값
  - {리소스(메모리)}: 요청값/최대값
  예시)
  ```
  [실행정보]
  - ACR명: acrdigitalgarage01
  - k8s명: aks-digitalgarage-01
  - 네임스페이스: tripgen
  - 파드수: 2
  - 리소스(CPU): 256m/1024m
  - 리소스(메모리): 256Mi/1024Mi
  ``` 
  
- 시스템명과 서비스명 확인   
  settings.gradle에서 확인.    
  - 시스템명: rootProject.name 
  - 서비스명: include 'common'하위의 include문 뒤의 값임 

  예시) include 'common'하위의 4개가 서비스명임.  
  ```
  rootProject.name = 'tripgen'

  include 'common'
  include 'user-service'
  include 'location-service'
  include 'ai-service'
  include 'trip-service'
  ``` 

- 매니페스트 작성 주의사항
  - namespace는 명시: {네임스페이스}값 이용
  - Database와 Redis의 Host명은 Service 객체 이름으로 함
  - Secret 변수 값은 'stringData'를 사용하여 평문으로 지정
  - 공통 Secret의 JWT_SECRET 값은 반드시 openssl명령으로 생성하여 지정 
  - 매니페스트 파일 안에 환경변수를 사용하지 말고 실제 값을 지정  
    예) host: "tripgen.${INGRESS_IP}.nip.io" => host: "tripgen.4.1.2.3.nip.io"

- 공통 매니페스트 작성: deployment/k8s/common/ 디렉토리 하위에 작성   
  - Image Pull Secret 매니페스트 작성: secret-imagepull.yaml  
    - name: {시스템명}
    - USERNAME과 PASSWORD을 아래 명령으로 구하여 매니페스트 파일 작성  
      ```
      USERNAME=$(az acr credential show -n ${ACR명} --query "username" -o tsv)
      PASSWORD=$(az acr credential show -n ${ACR명} --query "passwords[0].value" -o tsv)
      ```   
    - USERNAME과 PASSWORD의 실제 값을 매니페스트에 지정    
  - Ingress 매니페스트 작성: ingress.yaml 
    - Ingress Host: ingress controller 서비스 객체의 External IP를 구함 
      ```
      kubectl get svc ingress-nginx-controller -n ingress-nginx  
      ``` 
    - ingressClassName: nginx
    - host: {시스템명}.{Ingress Host}.nip.io. 실제 Ingress Host값을 지정
    - path: 각 서비스 별 Controller 클래스의 '@RequestMapping'과 클래스 내 메소드의 매핑정보를 읽어 지정   
    - pathType: Prefix
    - backend.service.name: {서비스명}
    - backend.service.port.number: 80
  
  - 공통 ConfigMap과 Secret 매니페스트 작성  
    - 각 서비스의 실행 프로파일({서비스명}/.run/{서비스명}.run.xml)을 읽어 공통된 환경변수를 추출.   
    - 보안이 필요한 환경변수는 Secret 매니페스트로 작성: secret-common.yaml(name:cm-common)
    - 그 외 일반 환경변수 매니페스트 작성: cm-common.yaml(name:secret-common)
  
- 서비스별 매니페스트 작성: deployment/k8s/{서비스명}/ 디렉토리 하위에 작성  
  - ConfigMap과 Secret 매니페스트 작성   
    - 각 서비스의 실행 프로파일({서비스명}/.run/{서비스명}.run.xml)을 읽어 환경변수를 추출. 
    - cm-common.yaml과 secret-common.yaml에 있는 공통 환경변수는 중복해서 작성하면 안됨     
    - 보안이 필요한 환경변수는 Secret 매니페스트로 작성: secret-{서비스명}.yaml(name:cm-{서비스명})
    - 그 외 일반 환경변수 매니페스트 작성: cm-{서비스명}.yaml(name:secret-{서비스명})
  - Service 매니페스트 작성  
    - name: {서비스명}
    - port: 80
    - targetPort: 실행 프로파일의 SERVER_PORT값  
    - type: ClusterIP
  - Deployment 매니페스트 작성  
    - name: {서비스명}
    - replicas: {파드수}
    - ImagePullPolicy: Always
    - ImagePullSecrets: {시스템명}
    - image: {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest 
    - envFrom: 
      - configMapRef: 공통 ConfigMap 'cm-common'과 각 서비스 ConfigMap 'cm-{서비스명}'을 지정  
      - secretRef: 공통 Secret 'secret-common'과 각 서비스 Secret 'secret-{서비스명}'을 지정 
    - resources: 
      - {리소스(CPU)}: 요청값/최대값
      - {리소스(메모리)}: 요청값/최대값
    - Probe:  
      - Startup Probe: Actuator '/actuator/health'로 지정
      - Readiness Probe: Actuator '/actuator/health/rediness'로 지정  
      - Liveness Probe: Actuator '/actuator/health/liveness'로 지정 
      - initialDelaySeconds, periodSeconds, failureThreshold를 Probe에 맞게 적절히 지정 

- 배포 가이드
  - 사전확인 방법 가이드 
    - Azure 로그인 상태 확인
      ```
      az account show
      ```
    - AKS Credential 확인: 
      ```
      kubectl cluster-info  
      ``` 
    - namespace 존재 확인   
      ```
      kubectl get ns {네임스페이스}  
      ``` 
  - 매니페스트 적용 가이드
    ```
    kubectl apply -f deployment/k8s/common
    kubectl apply -f deployment/k8s/{서비스명}
    ``` 
  - 객체 생성 확인 가이드

- 배포 가이드 작성

[결과파일]
- 배포방법 가이드: deployment/k8s/deploy-k8s-guide.md
- 공통 매니페스트 파일: deployment/k8s/common/*
- 서비스별 매니페스트 파일: deployment/k8s/{서비스명}/*

