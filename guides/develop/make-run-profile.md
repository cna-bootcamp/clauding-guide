# 서비스실행파일작성가이드 
  
[요청사항]  
- <수행원칙>을 준용하여 수행
- <수행순서>에 따라 수행
- [결과파일] 안내에 따라 파일 작성 

[가이드]
<수행원칙>
- 설정 Manifest(src/main/resources/application*.yml)의 각 항목의 값은 하드코딩하지 않고 환경변수 처리 
- Kubernetes에 배포된 데이터베이스는 LoadBalacer유형의 Service를 만들어 연결   
- MQ 이용 시 'MQ설치결과서'의 MQ 연결 문자열을 실행 프로파일의 환경변수로 등록 
<수행순서>
- 준비:
  - 데이터베이스설치결과서, 캐시설치결과서, MQ설치결과서에 대한 분석 및 이해  
- 실행:
  - 각 서비스별를 서브에이젼트로 병렬 수행   
  - '<실행프로파일 작성 가이드>'에 따라 서비스 실행프로파일 작성
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
- {service-name}/.run 파일로 작성
- Kubernetes에 배포된 데이터베이스는 LoadBalacer유형의 Service가 이미 있는지 검사. 없으면 생성. 
- 그 외 백킹 서비스 연결 확인 
- 배포된 객체에 접근하여 인증 정보까지 정확히 확인 
- application.yml에 사용된 환경변수 읽기. 만약 하드코딩 되어 있으면 환경변수로 변환  
- application.yaml의 환경변수와 일치하도록 환경변수 설정 
- application.yaml의 민감 정보는 기본값으로 지정하지 않고 '<실행프로파일 작성 가이드>'를 참조하여 실행 프로파일에 값을 지정함 
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
          <entry key="DB_HOST" value="20.249.197.193" />
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
          <entry key="REDIS_HOST" value="20.214.121.28" />
          <entry key="REDIS_PASSWORD" value="" />
          <entry key="REDIS_PORT" value="6379" />
          <entry key="SERVER_PORT" value="8081" />
          <entry key="SPRING_PROFILES_ACTIVE" value="dev" />
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
- 데이터베이스설치결과서
- 캐시설치결과서
- MQ설치결과서
