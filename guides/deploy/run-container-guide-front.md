# 프론트엔드 컨테이너 실행방법 가이드

[요청사항]  
- 프론트엔드 서비스의 컨테이너 이미지를 컨테이너로 실행하는 방법 안내  
- 실제 컨테이너 실행은 하지 않음   
- '[결과파일]'에 수행할 명령어를 포함하여 컨테이너 실행 가이드 생성    

[작업순서]
- 실행정보 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인
  - {시스템명}: 대표 시스템명   
  - {ACR명}: 컨테이너 레지스트리 이름 
  - {VM.KEY파일}: VM 접속하는 Private Key파일 경로 
  - {VM.USERID}: VM 접속하는 OS 유저명
  - {VM.IP}: VM IP
  예시)
  ```
  [실행정보]
  - 시스템명: tripgen
  - ACR명: acrdigitalgarage01
  - VM
    - KEY파일: ~/home/bastion-dg0500
    - USERID: azureuser
    - IP: 4.230.5.6
  ``` 
  
- 서비스명 확인   
  package.json의 "name" 필드값이 서비스명임.  
  예시) 아래예에서는 'tripgen-front'가 서비스명임.  
  ```
  {
    "name": "tripgen-front",
    "private": true,
  ```

- VM 접속 방법 안내
  - Linux/Mac은 기본 터미널을 실행하고 Window는 Window Terminal을 실행하도록 안내   
  - 터미널에서 아래 명령으로 VM에 접속하도록 안내  
    최초 한번 Private key파일의 모드를 변경.  
    ```
    chmod 400 {VM.KEY파일}
    ``` 
    
    private key를 이용하여 접속.  
    ``` 
    ssh -i {VM.KEY파일} {VM.USERID}@{VM.IP}
    ``` 
  - 접속 후 docker login 방법 안내   
    ```
    docker login {ACR명}.azurecr.io -u {ID} -p {암호}
    ```

- 컨테이너 이미지 생성 방법 안내     
  'deployment/container/build-image.md' 파일을 열어 가이드대로 수행하도록 안내    

- 컨테이너 레지스트리 로그인 방법 안내     
  아래 명령으로 {ACR명}의 인증정보를 구합니다.  
  'username'이 ID이고 'passwords[0].value'가 암호임. 
  ```
  az acr credential show --name {ACR명}
  ```

  예시) ID=dg0200cr, 암호={암호}    
  ```
  $ az acr credential show --name dg0200cr 
  {
    "passwords": [
      {
        "name": "password",
        "value": "{암호}"
      },
      {
        "name": "password2",
        "value": "{암호2}"
      }
    ],
    "username": "dg0200cr"
  }
  ```
  
  아래와 같이 로그인 명령을 작성합니다.   
  ```
  docker login {ACR명}.azurecr.io -u {ID} -p {암호}
  ```

- 컨테이너 푸시 방법 안내   
  Docker Tag 명령으로 이미지를 tag하는 명령을 작성합니다.   
  ```
  docker tag {서비스명}:latest {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest 
  ```
  이미지 푸시 명령을 작성합니다.   
  ```
  docker push {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
  ```

- 런타임 환경변수 파일 생성 방법 안내      
  - public/runtime-env.js파일을 읽어 그 안의 설정을 모두 포함    
  예제)
  ```
  window.ENV = {
    // API Configuration
    API_BASE_URL: 'http://localhost:8080/api',
    AUTH_API_URL: 'http://localhost:8081/api', 
    LOCATION_API_URL: 'http://localhost:8082/api',
    TRIP_API_URL: 'http://localhost:8083/api',
    AI_API_URL: 'http://localhost:8084/api',
    
    // Environment
    NODE_ENV: 'development',
    
    // App Configuration
    APP_NAME: 'TripGen',
    APP_VERSION: '1.0.0'

    // API Timeout Configuration (ms)
    API_TIMEOUT: 30000
  };
  ```
  - 'localhost'를 {VM.IP}로 변경하여 '~/{서비스명}/public/runtime-env.js'파일로 생성하는 방법 안내  
   
- 컨테이너 실행 명령 생성    
  아래 명령으로 컨테이너를 실행하는 명령을 생성합니다.    
  shell 파일을 만들지 말고 command로 수행하는 방법 안내.        
  '-v'로 runtime-env.js파일을 볼륨 마운트하도록 명령어 작성.       
  ```
  SERVER_PORT=3000

  docker run -d --name {서비스명} --rm -p ${SERVER_PORT}:8080 \
  -v ~/{서비스명}/public/runtime-env.js:/usr/share/nginx/html/runtime-env.js 
  {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
  ```

- 실행된 컨테이너 확인 방법 작성    
  아래 명령으로 모든 서비스의 컨테이너가 실행 되었는지 확인하는 방법을 안내.     
  ```
  docker ps | grep {서비스명}
  ```

- 재배포 방법 작성
  - 컨테이너 이미지 재생성 
    로컬에서 아래 명령으로 재생성 
    ```
    /deploy-build-image-front 
    ```
  - 컨테이너 이미지 푸시  
    로컬에서 수행  
    ```
    docker tag {서비스명}:latest {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
    docker push {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
    ```     
  - 컨테이너 중지
    VM 접속 후 수행   
    ```
    docker stop {서비스명}
    ```
  - 컨테이너 이미지 삭제  
    ```
    docker rmi {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
    ``` 
  - 컨테이너 재실행 

[결과파일]
deployment/container/run-container-guide.md
