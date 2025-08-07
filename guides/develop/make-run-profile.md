# 서비스실행파일작성가이드 
  
[요청사항]  
- <수행원칙>을 준용하여 수행
- <수행순서>에 따라 수행
- [결과파일] 안내에 따라 파일 작성 

[가이드]
<수행원칙>
- 설정 Manifest(src/main/resources/application*.yml)의 각 항목의 값은 하드코딩하지 않고 환경변수 처리 
- Kubernetes에 배포된 데이터베이스는 LoadBalacer유형의 Service를 만들어 연결   
- MQ 이용 시 'MQ설치결과서'의 연결 정보를 실행 프로파일의 환경변수로 등록 
<수행순서>
- 준비:
  - 데이터베이스설치결과서(develop/database/exec/db-exec-dev.md) 분석
  - 캐시설치결과서(develop/database/exec/cache-exec-dev.md) 분석  
  - MQ설치결과서(develop/mq/mq-exec-dev.md) 분석 - 연결 정보 확인
  - kubectl get svc -n tripgen-dev | grep LoadBalancer 실행하여 External IP 목록 확인
- 실행:
  - 각 서비스별를 서브에이젼트로 병렬 수행   
  - 설정 Manifest 수정
    - 하드코딩 되어 있는 값이 있으면 환경변수로 변환
    - 특히, 데이터베이스, MQ 등의 연결 정보는 반드시 환경변수로 변환해야 함     
    - 민감한 정보의 디퐅트값은 생략하거나 간략한 값으로 지정 
  - '<실행프로파일 작성 가이드>'에 따라 서비스 실행프로파일 작성
    - LoadBalancer External IP를 DB_HOST, REDIS_HOST로 설정
    - MQ 연결 정보를 application.yml의 환경변수명에 맞춰 설정
  - 서비스 실행 및 오류 수정 
    - 'IntelliJ서비스실행기'를 'tools' 디렉토리에 다운로드  
    - python 또는 python3 명령으로 백그라우드로 실행하고 결과 로그를 분석  
      nohup python3 tools/run-intellij-service-profile.py {service-name} > debug/{service-name}.log 2>&1 & echo "Started {service-name} with PID: $!" 
    - 서비스 실행은 다른 방법 사용하지 말고 **반드시 python 프로그램 이용** 
  - 오류 수정 후 필요 시 실행파일의 환경변수를 올바르게 변경  
  - 서비스 정상 시작 확인 후 서비스 중지 
  - 결과: {service-name}/.run
<서비스 중지 방법>
- Window
  - netstat -ano | findstr :{PORT}
  - powershell "Stop-Process -Id {Process number} -Force"
- Linux/Mac
  - netstat -ano | grep {PORT}
  - kill -9 {Process number}
<실행프로파일 작성 가이드>
- {service-name}/.run/{service-name}.run.xml 파일로 작성
- Kubernetes에 배포된 데이터베이스의 LoadBalancer Service 확인:
  - kubectl get svc -n {namespace} | grep LoadBalancer 명령으로 LoadBalancer IP 확인
  - 각 서비스별 데이터베이스의 LoadBalancer External IP를 DB_HOST로 사용
  - 캐시(Redis)의 LoadBalancer External IP를 REDIS_HOST로 사용
- MQ 연결 설정:
  - MQ설치결과서(develop/mq/mq-exec-dev.md)에서 연결 정보 확인
  - MQ 유형에 따른 연결 정보 설정 예시:
    - RabbitMQ: RABBITMQ_HOST, RABBITMQ_PORT, RABBITMQ_USERNAME, RABBITMQ_PASSWORD
    - Kafka: KAFKA_BOOTSTRAP_SERVERS, KAFKA_SECURITY_PROTOCOL
    - Azure Service Bus: SERVICE_BUS_CONNECTION_STRING
    - AWS SQS: AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
    - Redis (Pub/Sub): REDIS_HOST, REDIS_PORT, REDIS_PASSWORD
    - ActiveMQ: ACTIVEMQ_BROKER_URL, ACTIVEMQ_USER, ACTIVEMQ_PASSWORD
    - 기타 MQ: 해당 MQ의 연결에 필요한 호스트, 포트, 인증정보, 연결문자열 등을 환경변수로 설정
  - application.yml에 정의된 환경변수명 확인 후 매핑
- 백킹서비스 연결 정보 매핑:
  - 데이터베이스설치결과서에서 각 서비스별 DB 인증 정보 확인
  - 캐시설치결과서에서 각 서비스별 Redis 인증 정보 확인
  - LoadBalancer의 External IP를 호스트로 사용 (내부 DNS 아님)
- application.yaml의 환경변수와 일치하도록 환경변수 설정 
- application.yaml의 민감 정보는 기본값으로 지정하지 않고 실제 백킹서비스 정보로 지정
- 백킹서비스 연결 확인 결과를 바탕으로 정확한 값을 지정  
- 기존에 파일이 있으면 내용을 분석하여 항목 추가/수정/삭제  
- 예시
```
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="user-service" type="GradleRunConfiguration" factoryName="Gradle">
    <ExternalSystemSettings>
      <option name="env">
        <map>
          <entry key="ACCOUNT_LOCK_DURATION_MINUTES" value="30" />
          <entry key="CACHE_TTL" value="1800" />
          <entry key="DB_HOST" value="20.249.197.193" /> <!-- LoadBalancer External IP 사용 -->
          <entry key="DB_NAME" value="tripgen_user_db" />
          <entry key="DB_PASSWORD" value="tripgen_user_123" />
          <entry key="DB_PORT" value="5432" />
          <entry key="DB_USERNAME" value="tripgen_user" />
          <entry key="FILE_BASE_URL" value="http://localhost:8081" />
          <entry key="FILE_MAX_SIZE" value="5242880" />
          <entry key="FILE_UPLOAD_PATH" value="/app/uploads" />
          <entry key="JPA_DDL_AUTO" value="update" />
          <entry key="JPA_SHOW_SQL" value="true" />
          <entry key="JWT_ACCESS_TOKEN_EXPIRATION" value="86400" />
          <entry key="JWT_REFRESH_TOKEN_EXPIRATION" value="604800" />
          <entry key="JWT_SECRET" value="dev-jwt-secret-key-for-development-only" />
          <entry key="LOG_LEVEL_APP" value="DEBUG" />
          <entry key="LOG_LEVEL_ROOT" value="INFO" />
          <entry key="LOG_LEVEL_SECURITY" value="DEBUG" />
          <entry key="MAX_LOGIN_ATTEMPTS" value="5" />
          <entry key="PASSWORD_MIN_LENGTH" value="8" />
          <entry key="REDIS_DATABASE" value="0" />
          <entry key="REDIS_HOST" value="20.214.121.28" /> <!-- Redis LoadBalancer External IP 사용 -->
          <entry key="REDIS_PASSWORD" value="" />
          <entry key="REDIS_PORT" value="6379" />
          <entry key="SERVER_PORT" value="8081" />
          <entry key="SPRING_PROFILES_ACTIVE" value="dev" />
          <!-- MQ 사용하는 서비스의 경우 MQ 유형에 맞게 추가 -->
          <!-- Azure Service Bus 예시 -->
          <entry key="SERVICE_BUS_CONNECTION_STRING" value="Endpoint=sb://...;SharedAccessKeyName=...;SharedAccessKey=..." />
          <!-- RabbitMQ 예시 -->
          <entry key="RABBITMQ_HOST" value="20.xxx.xxx.xxx" />
          <entry key="RABBITMQ_PORT" value="5672" />
          <!-- Kafka 예시 -->
          <entry key="KAFKA_BOOTSTRAP_SERVERS" value="20.xxx.xxx.xxx:9092" />
          <!-- 기타 MQ의 경우 해당 MQ에 필요한 연결 정보를 환경변수로 추가 -->
        </map>
      </option>
      <option name="executionName" />
      <option name="externalProjectPath" value="$PROJECT_DIR$" />
      <option name="externalSystemIdString" value="GRADLE" />
      <option name="scriptParameters" value="" />
      <option name="taskDescriptions">
        <list />
      </option>
      <option name="taskNames">
        <list>
          <option value="user-service:bootRun" />
        </list>
      </option>
      <option name="vmOptions" />
    </ExternalSystemSettings>
    <ExternalSystemDebugServerProcess>true</ExternalSystemDebugServerProcess>
    <ExternalSystemReattachDebugProcess>true</ExternalSystemReattachDebugProcess>
    <EXTENSION ID="com.intellij.execution.ExternalSystemRunConfigurationJavaExtension">
      <extension name="net.ashald.envfile">
        <option name="IS_ENABLED" value="false" />
        <option name="IS_SUBST" value="false" />
        <option name="IS_PATH_MACRO_SUPPORTED" value="false" />
        <option name="IS_IGNORE_MISSING_FILES" value="false" />
        <option name="IS_ENABLE_EXPERIMENTAL_INTEGRATIONS" value="false" />
        <ENTRIES>
          <ENTRY IS_ENABLED="true" PARSER="runconfig" IS_EXECUTABLE="false" />
        </ENTRIES>
      </extension>
    </EXTENSION>
    <DebugAllEnabled>false</DebugAllEnabled>
    <RunAsTest>false</RunAsTest>
    <method v="2" />
  </configuration>
</component>
```

[참고자료]
- 데이터베이스설치결과서: develop/database/exec/db-exec-dev.md
  - 각 서비스별 DB 연결 정보 (사용자명, 비밀번호, DB명)
  - LoadBalancer Service External IP 목록
- 캐시설치결과서: develop/database/exec/cache-exec-dev.md  
  - 각 서비스별 Redis 연결 정보
  - LoadBalancer Service External IP 목록
- MQ설치결과서: develop/mq/mq-exec-dev.md
  - MQ 유형 및 연결 정보
  - 연결에 필요한 호스트, 포트, 인증 정보
  - LoadBalancer Service External IP (해당하는 경우)
