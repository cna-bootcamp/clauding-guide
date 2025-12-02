# 백엔드 배포 가이드

[요청사항]  
- 백엔드 서비스를 쿠버네티스에 배포하기 위한 매니페스트 파일 작성 
- 매니페스트 파일 작성까지만 하고 실제 배포는 수행방법만 가이드  
- '[결과파일]'에 수행한 명령어를 포함하여 배포 가이드 레포트 생성 

[작업순서]
- 실행정보 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인  
  - {IMG_REG}: 컨테이너 이미지 레지스트리 주소
  - {IMG_ORG}: 컨테이너 이미지 Organization 주소
  - {BACKEND_HOST}: Baeckend 게이트웨이의 Ingress Host 주소  
  - {FRONTEND_HOST}: 프론트엔드 Ingress Host 주소  
  - {네임스페이스}: 배포할 네임스페이스 
  - {파드수}: 생성할 파드수 
  - {리소스(CPU)}: 요청값/최대값
  - {리소스(메모리)}: 요청값/최대값
  
  예시)
  ```
  [실행정보]
  - IMG_REG: docker.io
  - IMG_ORG: hiondal
  - BACKEND_HOST: phonebill-api.72.155.72.236.nip.io
  - FRONTEND_HOST: phonebill.72.155.72.236.nip.io
  - 네임스페이스: phonebill
  - 파드수: 1
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
  - 공통 Secret의 JWT_SECRET 값은 반드시 openssl명령으로 생성하여 지정 
  - 매니페스트 파일 안에 환경변수를 사용하지 말고 실제 값을 지정  
    예) host: "tripgen.${INGRESS_IP}.nip.io" => host: "tripgen.4.1.2.3.nip.io"
  - Secret 매니페스트에서 'data' 대신 'stringData'를 사용  
  - 객체이름 네이밍룰
    - 공통 ConfigMap: cm-common
    - 공통 Secret: secret-common
    - 서비스별 ConfigMap: cm-{서비스명}
    - 서비스별 Secret: secret-{서비스명}
    - Ingress: {시스템명}
    - Service: {서비스명}
    - Deployment: {서비스명}
  
- 공통 매니페스트 작성: deployment/k8s/common/ 디렉토리 하위에 작성   
  - Image Pull Secret 매니페스트 작성: secret-imagepull.yaml  
    - name: {시스템명}
    - USERNAME과 PASSWORD을 아래 명령으로 구하여 매니페스트 파일 작성  
      ```
      USERNAME=$(IMG_ID)
      PASSWORD=$(IMG_PW)
      ```   
    - USERNAME과 PASSWORD의 실제 값을 매니페스트에 지정    
  - Ingress 매니페스트 작성: ingress.yaml 
    - API Gateway 서비스가 없는 경우 Ingress에서 각 백엔드 서비스 연결   
      - ingressClassName: nginx
      - host: {BACKEND_HOST}
      - path: 각 서비스 별 Controller 클래스의 '@RequestMapping'과 클래스 내 메소드의 매핑정보를 읽어 지정   
      - pathType: Prefix
      - backend.service.name: {서비스명}
      - backend.service.port.number: 80  
    - API Gateway 서비스가 있는 경우 
      - ingressClassName: nginx
      - host: {BACKEND_HOST}
      - path: /   
      - pathType: Prefix
      - backend.service.name: {API Gateway 서비스명}
      - backend.service.port.number: {API Gateway 포트}
    - **중요**: annotation에 'nginx.ingress.kubernetes.io/rewrite-target' 설정 절대 하지 말것.     
       
  - 공통 ConfigMap과 Secret 매니페스트 작성  
    - 각 서비스의 실행 프로파일({서비스명}/.run/{서비스명}.run.xml)을 읽어 공통된 환경변수를 추출.   
    - 보안이 필요한 환경변수(암호, 인증토큰 등)는 Secret 매니페스트로 작성: secret-common.yaml(name:cm-common)
    - 그 외 일반 환경변수 매니페스트 작성: cm-common.yaml(name:secret-common)
    - Redis HOST명은 IP가 아닌 Service 객체명으로 함. 
      아래 명령으로 'redis'가 포함된 서비스 객체를 찾고 'ClusterIP'유형인 서비스명을 Host명으로 사용  
      ```
      kubectl get svc | grep redis
      ``` 
    - REDIS_DATABASE는 각 서비스별 ConfigMap에 지정
    - 주의) Database는 공통 ConfigMap/Secret으로 작성 금지
    - 공통 ConfigMap에 CORS_ALLOWED_ORIGINS 설정: 'http://localhost:8081,http://localhost:8082,http://localhost:8083,http://localhost:8084,http://{FRONTEND_HOST}'
  
- 서비스별 매니페스트 작성: deployment/k8s/{서비스명}/ 디렉토리 하위에 작성  
  - ConfigMap과 Secret 매니페스트 작성   
    - 각 서비스의 실행 프로파일({서비스명}/.run/{서비스명}.run.xml)을 읽어 환경변수를 추출. 
    - cm-common.yaml과 secret-common.yaml에 있는 공통 환경변수는 중복해서 작성하면 안됨     
    - 보안이 필요한 환경변수(암호, 인증토큰 등)는 Secret 매니페스트로 작성: secret-{서비스명}.yaml(name:cm-{서비스명})
    - 그 외 일반 환경변수 매니페스트 작성: cm-{서비스명}.yaml(name:secret-{서비스명})
    - Database HOST명은 IP가 아닌 Service 객체명으로 함.   
      아래 명령으로 '{서비스명}'과 'db'가 포함된 서비스 객체를 찾고 'ClusterIP'유형인 서비스명을 Host명으로 사용  
      ```
      kubectl get svc | grep {서비스명}
      ```
    - REDIS_DATABASE는 실행 프로파일에 지정된 값으로 서비스별 ConfigMap에 지정 
  - Service 매니페스트 작성  
    - API Gateway 서비스가 없는 경우 
      - name: {서비스명}
      - port: 80
      - targetPort: 실행 프로파일의 SERVER_PORT값  
      - type: ClusterIP
    - API Gateway 서비스가 있는 경우 
      - name: {API Gateway 서비스명}
      - port: {API Gateway 포트}
      - targetPort: {API Gateway 포트}  
      - type: ClusterIP 
  - Deployment 매니페스트 작성  
    - name: {서비스명}
    - replicas: {파드수}
    - ImagePullPolicy: Always
    - ImagePullSecrets: {시스템명}
    - image: {IMG_REG}/{IMG_ORG}/{서비스명}:latest 
    - ConfigMap과 Secret은 'env'대신에 'envFrom'을 사용하여 지정 
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

- 체크 리스트로 수행결과 검증: 반드시 수행하고 그 결과를 배포 가이드에 포함 
  - 객체이름 네이밍룰 준수 여부
  - Redis Host명을 ClusterIP 타입의 Service 객체로 했는가? 
    'kubectl get svc | grep redis' 명령으로 재확인 
  - Database Host명을 ClusterIP타입의 Service 객체로 했는가?
    'kubectl get svc | grep {서비스명}' 명령으로 재확인 
  - Secret 매니페스트에서 'data' 대신 'stringData'를 사용 했는가?  
  - JWT_SECRET을 openssl 명령으로 생성해서 지정했는가?
  - 매니페스트 파일 안에 환경변수를 사용하지 않고 실제 값을 지정 했는가?
  - Image Pull Secret에 USERNAME과 PASSWORD의 실제 값을 매니페스트에 지정 했는가?
  - Image명이 '{IMG_REG}/{IMG_ORG}/{서비스명}:latest' 형식인지 재확인 
  - 보안이 필요한 환경변수는 Secret 매니페스트로 지정했는가?
  - REDIS_DATABASE는 각 서비스마다 다르게 지정했는가?
  - ConfigMap과 Secret은 'env'대신에 'envFrom'을 사용하였는가?
  - (중요) 실행 프로파일 매핑 테이블로 누락된 환경변수 체크  
    - **필수**: 각 서비스의 실행 프로파일({서비스명}/.run/{서비스명}.run.xml)에 정의된 **전체 환경변수를 빠짐없이 체크**
    - **체크 방법**: 
      1. 각 {서비스명}.run.xml 파일에서 `<entry key="환경변수명" value="값"/>` 형태로 정의된 **모든** 환경변수 추출
      2. 추출된 환경변수 **전체**를 대상으로 매핑 테이블 작성 (일부만 하면 안됨)
      3. 서비스명 | 환경변수 | 지정 객체명 | 환경변수값 컬럼으로 **전체 환경변수** 체크
    - **매핑 테이블 예시** (전체 환경변수 기준):
      ```
      user-service | SERVER_PORT | cm-user-service | 8081
      user-service | DB_HOST | secret-user-service | user-db-service  
      user-service | DB_PASSWORD | secret-user-service | tripgen_user_123
      user-service | REDIS_DATABASE | cm-user-service | 0
      user-service | JWT_SECRET | secret-common | (base64 encoded)
      user-service | CACHE_TTL | cm-user-service | 1800
      location-service | SERVER_PORT | cm-location-service | 8082
      location-service | GOOGLE_API_KEY | secret-location-service | (base64 encoded)
      location-service | REDIS_DATABASE | cm-location-service | 1
      ai-service | CLAUDE_API_KEY | secret-ai-service | (base64 encoded)
      ai-service | SERVER_PORT | cm-ai-service | 8084
      ... (실행프로파일의 모든 환경변수 나열)
      ```
    - **주의**: 일부 환경변수만 체크하면 누락 발생, 반드시 **실행프로파일 전체** 환경변수 대상으로 수행
    - 누락된 환경변수가 발견되면 해당 ConfigMap/Secret에 추가 

- 배포 가이드 작성
  - 배포가이드 검증 결과
  - 사전확인 방법 가이드  
    - namespace 존재 확인   
      ```
      kubectl get ns {네임스페이스}  
      ``` 
  - 매니페스트 적용 가이드
    ```
    kubectl apply -f deployment/k8s -R
    ``` 
  - 객체 생성 확인 가이드


[결과파일]
- 배포방법 가이드: deployment/k8s/deploy-k8s-guide.md
- 공통 매니페스트 파일: deployment/k8s/common/*
- 서비스별 매니페스트 파일: deployment/k8s/{서비스명}/*

