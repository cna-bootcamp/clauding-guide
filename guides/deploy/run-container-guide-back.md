# 백엔드 컨테이너 실행방법 가이드

[요청사항]  
- 백엔드 각 서비스들의 컨테이너 이미지를 컨테이너로 실행하는 가이드 작성  
- 실제 컨테이너 실행은 하지 않음   
- '[결과파일]'에 수행할 명령어를 포함하여 컨테이너 실행 가이드 생성    

[작업순서]
- 서비스명 확인   
  서비스명은 settings.gradle에서 확인 
  
  예시) include 'common'하위의 4개가 서비스명임.  
  ```
  rootProject.name = 'tripgen'

  include 'common'
  include 'user-service'
  include 'location-service'
  include 'ai-service'
  include 'trip-service'
  ```  
- 생성된 컨테이너 이미지 확인   
  아래 명령으로 모든 서비스의 컨테이너 이미 생성 확인  
  ```
  docker images | grep {서비스명}
  ``` 

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

- 컨테이너 실행 명령 생성    
  아래 명령으로 컨테이너를 실행하는 명령을 생성합니다.    
  shell 파일을 만들지 말고 command로 수행하는 방법 안내.        
  모든 환경변수에 대해 '-e' 파라미터로 환경변수값을 넘깁니다.     
  ```
  SERVER_PORT={환경변수의 SERVER_PORT값}

  docker run -d --name {서비스명} --rm -p ${SERVER_PORT}:${SERVER_PORT} \
  -e {환경변수 KEY}={환경변수 VALUE} 
  {서비스명}:latest
  ```

- 실행된 컨테이너 확인 방법 작성    
  아래 명령으로 모든 서비스의 컨테이너가 실행 되었는지 확인하는 방법을 안내.     
  ```
  docker ps | grep {서비스명}
  ```

[결과파일]
deployment/container/run-container-guide.md
