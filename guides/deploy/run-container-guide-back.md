# 백엔드 컨테이너 실행방법 가이드

[요청사항]  
- 백엔드 각 서비스들의 컨테이너 이미지를 컨테이너로 실행하는 가이드 작성  
- 실제 컨테이너 실행은 하지 않음   
- '[결과파일]'에 수행할 명령어를 포함하여 컨테이너 실행 가이드 생성    

[작업순서]
- 실행정보 확인   
  프롬프트의 '[실행정보]'섹션에서 아래정보를 확인  
  - {ACR명}: Azure 컨테이너 이미지 레지스트리 이름 
  - {VM.KEY파일}: VM 접속하는 Private Key파일 경로 
  - {VM.USERID}: VM 접속하는 OS 유저명
  - {VM.IP}: VM IP
  예시)
  ACR 이용시: 
  ```
  [실행정보]
  - ACR명: acrdigitalgarage01
  - VM
    - KEY파일: ~/home/bastion-dg0500
    - USERID: azureuser
    - IP: 4.230.5.6
  ``` 

  다른 컨테이너 이미지 레지스트리 이용 시: 
  ```
  [실행정보]
  - {IMG_REG}: docker.io
  - {IMG_ORG}: hiondal
  - {IMG_ID}: hiondal
  - {IMG_PW}: dckr_pat_0E1PBHpAMf_I02OvMZRddddd
  - VM
    - KEY파일: ~/home/bastion-dg0500
    - USERID: azureuser
    - IP: 4.230.5.6
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

- Git Repository 클론 안내       
  - workspace 디렉토리 생성 및 이동   
    ```
    mkdir -p ~/home/workspace 
    cd ~/home/workspace
    ```
  - 소스 Clone 
    ```
    git clone {원격 Git Repository 주소}
    ```   
    예)
    ```
    git clone https://github.com/cna-bootcamp/phonebill.git 
    ```
  - 프로젝트 디렉토리로 이동  
    ```
    cd {시스템명}
    ``` 

- 어플리케이션 빌드 및 컨테이너 이미지 생성 방법 안내      
  'deployment/container/build-image.md' 파일을 열어 가이드대로 수행하도록 안내    

- 컨테이너 레지스트리 로그인 방법 안내     
  - ACR 이용 시 : {ACR명}이 제공된 경우   
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
  - 다른 컨테이너 이미지 레지스트리 이용시: {IMG_REG}, {IMG_ORG}, {IMG_ID}, {IMG_PW} 제공 시 
    ```
    docker login {IMG_REG} -u {IMG_ID} -p {IMG_PW}
    ```

- 컨테이너 푸시 방법 안내   
  - ACR 이용 시 : 
    Docker Tag 명령으로 이미지를 tag하는 명령을 작성합니다.   
    ```
    docker tag {서비스명}:latest {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest 
    ```
    이미지 푸시 명령을 작성합니다.   
    ```
    docker push {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
    ```
  - 다른 컨테이너 이미지 레지스트리 이용시:
    Docker Tag 명령으로 이미지를 tag하는 명령을 작성합니다.   
    ```
    docker tag {서비스명}:latest {IMG_REG}/{IMG_ORG}/{서비스명}:latest 
    ```
    이미지 푸시 명령을 작성합니다.   
    ```
    docker push {IMG_REG}/{IMG_ORG}/{서비스명}:latest
    ```

- 컨테이너 실행 명령 생성    
  - 환경변수 확인    
    '{서비스명}/.run/{서비스명}.run.xml' 을 읽어 각 서비스의 환경변수 찾음.      
    "env.map"의 각 entry의 key와 value가 환경변수임.   
      
    예제) SERVER_PORT=8081, DB_HOST=20.249.137.175가 환경변수임 
    ```
    <component name="ProjectRunConfigurationManager">
      <configuration default="false" name="ai-service" type="GradleRunConfiguration" factoryName="Gradle">
        <ExternalSystemSettings>
          <option name="env">
            <map>
              <entry key="SERVER_PORT" value="8084" />
              <entry key="DB_HOST" value="20.249.137.175" />
    ```

  - 아래 명령으로 컨테이너를 실행하는 명령을 생성합니다.    
    - shell 파일을 만들지 말고 command로 수행하는 방법 안내.        
    - 모든 환경변수에 대해 '-e' 파라미터로 환경변수값을 넘깁니다.  
    - 중요) CORS 설정 환경변수에 프론트엔드 주소 추가   
      - 'ALLOWED_ORIGINS' 포함된 환경변수가 CORS 설정 환경변수임.  
      - 이 환경변수의 값에 'http://{VM.IP}:3000'번 추가  
    
    - ACR 이용시: 
      ```
      SERVER_PORT={환경변수의 SERVER_PORT값}

      docker run -d --name {서비스명} --rm -p ${SERVER_PORT}:${SERVER_PORT} \
      -e {환경변수 KEY}={환경변수 VALUE} 
      {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
      ```
    - 다른 컨테이너 이미지 레지스트리 이용시: 
      ```
      SERVER_PORT={환경변수의 SERVER_PORT값}

      docker run -d --name {서비스명} --rm -p ${SERVER_PORT}:${SERVER_PORT} \
      -e {환경변수 KEY}={환경변수 VALUE} 
      {IMG_REG}/{IMG_ORG}/{서비스명}:latest
      ```

- 실행된 컨테이너 확인 방법 작성    
  아래 명령으로 모든 서비스의 컨테이너가 실행 되었는지 확인하는 방법을 안내.     
  ```
  docker ps | grep {서비스명}
  ```
- 재배포 방법 작성 
  - 로컬에서 수정된 소스 푸시 
  - VM 접속 
  - 디렉토리 이동 및 소스 내려받기
    ```
    cd ~/home/workspace/{시스템명}
    ```

    ```
    git pull
    ```
  - 컨테이너 이미지 재생성 
    'deployment/container/build-image.md' 파일을 열어 가이드대로 수행

  - 컨테이너 이미지 푸시  
    - ACR 이용 시: 
      ```
      docker tag {서비스명}:latest {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
      docker push {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
      ```   
    - 다른 컨테이너 이미지 레지스트리 이용시: 
      ```
      docker tag {서비스명}:latest {IMG_REG}/{IMG_ORG}/{서비스명}:latest
      docker push {IMG_REG}/{IMG_ORG}/{서비스명}:latest
      ```   

  - 컨테이너 중지 
    ```
    docker stop {서비스명}
    ```
  - 컨테이너 이미지 삭제  
    - ACR 이용 시: 
      ```
      docker rmi {ACR명}.azurecr.io/{시스템명}/{서비스명}:latest
      ``` 
    - 다른 컨테이너 이미지 레지스트리 이용시:
      ```
      docker rmi {IMG_REG}/{IMG_ORG}/{서비스명}:latest
      ``` 

  - 컨테이너 재실행 
  
[결과파일]
deployment/container/run-container-guide.md
  