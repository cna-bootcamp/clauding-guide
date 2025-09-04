# 프론트엔드 배포 가이드

[요청사항]  
- 프론트엔드 서비스를 쿠버네티스에 배포하기 위한 매니페스트 파일 작성 
- 매니페스트 파일 작성까지만 하고 실제 배포는 수행방법만 가이드  
- '[결과파일]'에 수행한 명령어를 포함하여 배포 가이드 레포트 생성 

[작업순서]
- 실행정보 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인  
  - {시스템명}: 대표 시스템 이름 
  - {ACR명}: 컨테이너 레지스트리 이름 
  - {k8s명}: Kubernetes 클러스터 이름  
  - {네임스페이스}: 배포할 네임스페이스 
  - {파드수}: 생성할 파드수 
  - {리소스(CPU)}: 요청값/최대값
  - {리소스(메모리)}: 요청값/최대값
  - {Gateway Host}: API Gateway의 Host명 
  예시)
  ```
  [실행정보]
  - 시스템명: tripgen
  - ACR명: acrdigitalgarage01
  - k8s명: aks-digitalgarage-01
  - 네임스페이스: tripgen
  - 파드수: 2
  - 리소스(CPU): 256m/1024m
  - 리소스(메모리): 256Mi/1024Mi
  - Gateway Host: http://tripgen-api.20.214.196.128.nip.io
  ``` 
  
- 서비스명 확인   
  package.json의 "name" 필드값이 서비스명임.  
  예시) 아래 예에서는 'tripgen-front'가 서비스명임.  
  ```
  {
    "name": "tripgen-front",
    "private": true,
  ```

- 매니페스트 작성 주의사항
  - namespace는 명시: {네임스페이스}값 이용
  - 객체이름 네이밍룰
    - Ingress: {서비스명}
    - ConfigMap: cm-{서비스명}
    - Service: {서비스명}
    - Secret: {서비스명}
    - Deployment: {서비스명}
    
- 매니페스트 작성: deployment/k8s/ 디렉토리 하위에 작성  
  - ConfigMap 매니페스트 작성   
    - public/runtime-env.js의 내용을 읽음
    - 파일명 runtime-env.js를 키로 하고 파일 내용을 값으로 하는 ConfigMap 매니페스트 작성  
      단, 내용에서 백엔드 API 주소의 'http://Host:Port'를 '{Gateway Host}'로 변경         
      예시) 
      AUTH_API_URL: 'http://localhost:8081/api' 
      -> AUTH_API_URL: 'http://tripgen.20.214.196.128.nip.io/api'

  - Ingress 매니페스트 작성
    - **중요**: Ingress Host는 반드시 아래 명령으로 실제 External IP를 확인하여 사용할 것
      ```  
      kubectl get svc ingress-nginx-controller -n ingress-nginx   
      ```     
      출력 예시: EXTERNAL-IP 컬럼에서 실제 IP 확인 (예:20.214.196.128)
    - ingressClassName: nginx
    - host: {시스템명}.{실제확인한 External-IP}.nip.io
      **잘못된 예**: tripgen.임의IP.nip.io ❌
      **올바른 예**: tripgen.20.214.196.128.nip.io ✅
    - path: '/'
    - pathType: Prefix
    - backend.service.name: {서비스명}
    - backend.service.port.number: 80    

  - Service 매니페스트 작성  
    - name: {서비스명}
    - port: 8080
    - targetPort: 80  
    - type: ClusterIP
  
  - Deployment 매니페스트 작성  
    - name: {서비스명}
    - replicas: {파드수}
    - ImagePullPolicy: Always
    - ImagePullSecrets: {시스템명}
    - image: {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest 
    - resources: 
      - {리소스(CPU)}: 요청값/최대값
      - {리소스(메모리)}: 요청값/최대값
    - Probe:   
      - Startup Probe: '/health'로 지정
      - Readiness Probe: '/health'로 지정  
      - Liveness Probe: Actuator '/health'로 지정 
      - initialDelaySeconds, periodSeconds, failureThreshold를 Probe에 맞게 적절히 지정 
    - volume mount
      - ConfigMap cm-{서비스명}를 '/usr/share/nginx/html/runtime-env.js'로 마운트   
      
- 체크 리스트로 수행결과 검증: 반드시 수행하고 그 결과를 배포 가이드에 포함 
  - 객체이름 네이밍룰 준수 여부
  - Ingress Controller External IP 확인 및 매니페스트에 반영 확인
    kubectl get svc ingress-nginx-controller -n ingress-nginx        
    EXTERNAL-IP 컬럼의 실제 값이 ingress.yaml의 host에 정확하게 설정되었는지 재확인할 것 
  - Image명이 '{ACR명}.azurecr.io/{시스템명}/{서비스명}:latest' 형식인지 재확인 
  - ConfigMap 'cm-{서비스명}'의 data 내용 확인 
    - key는 runtime-env.js인가?
    - value에 각 백엔드 API 주소의 Host가 {Gateway Host}인가 ?
  
- 배포 가이드 작성
  - 배포가이드 검증 결과
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
    kubectl apply -f deployment/k8s
    ``` 
  - 객체 생성 확인 가이드

  - 
[결과파일]
- 배포방법 가이드: deployment/k8s/deploy-k8s-guide.md
- 매니페스트 파일: deployment/k8s/*

