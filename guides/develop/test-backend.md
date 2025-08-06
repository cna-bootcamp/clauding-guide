# 백엔드 테스트 가이드 
  
[요청사항]  
- <테스트원칙>을 준용하여 수행
- <테스트순서>에 따라 수행
- [결과파일] 안내에 따라 파일 작성 

[가이드]
<테스트원칙>
- 설정 Manifest(src/main/resources/application*.yml)의 각 항목의 값은 하드코딩하지 않고 환경변수 처리 
- Kubernetes에 배포된 데이터베이스는 LoadBalacer유형의 Service를 만들어 연결   
<테스트순서>
- 준비:
  - 데이터베이스설치결과서, 캐시설치결과서, MQ설치결과서에 대한 분석 및 이해  
- 실행:
  - 실행 및 오류 수정
    - 각 서비스별를 서브에이젼트로 병렬 수행   
    - '<실행프로파일 작성 가이드>'에 따라 서비스 실행프로파일 작성
    - 서비스 실행 및 오류 수정 
      - 'IntelliJ서비스실행기'를 'tools' 디렉토리에 다운로드  
      - python 또는 python3 명령으로 백그라우드로 실행하고 결과 로그를 분석  
        nohup python3 tools/run-intellij-service-profile.py {service-name} > debug/{service-name}.log 2>&1 & echo "Started {service-name} with PID: $!" 
      - 서비스 실행은 다른 방법 사용하지 말고 **반드시 python 프로그램 이용** 
    - 오류 수정 후 필요 시 실행파일의 환경변수를 올바르게 변경  
  - 'curl'명령을 이용한 테스트 및 오류 수정
    - 서비스 의존관계를 고려하여 테스트 순서 결정 
    - 순서에 따라 순차적으로 각 서비스의 Controller에서 API 스펙 확인 후 API 테스트 
    - DTO클래스를 확인하여 정확한 request data 구성  
    - 테스트 데이터는 영어 이용 
    - 서비스 재시작 시에는 '<서비스 중지 방법>'을 참조하여 중지 후 재시작
    - 모든 API를 테스트하고 필요 시 소스를 수정하여 오류를 해결  
    - 모든 오류가 해결될때까지 오류 수정과 웹브라우저에서 확인 과정을 반복  
    - 완료 후 서비스 중지 
  - 결과: test-backend.md
<서비스 중지 방법>
- Window
  - netstat -ano | findstr :{PORT}
  - powershell "Stop-Process -Id {Process number} -Force"
- Linux/Mac
  - netstat -ano | grep {PORT}
  - kill -9 {Process number}
<실행프로파일 작성 가이드>
- .idea/workspace.xml에 작성
- Kubernetes에 배포된 데이터베이스는 LoadBalacer유형의 Service가 이미 있는지 검사. 없으면 생성. 
- 그 외 백킹 서비스 연결 확인 
- 배포된 객체에 접근하여 인증 정보까지 정확히 확인 
- application.yml에 사용된 환경변수 읽기. 만약 하드코딩 되어 있으면 환경변수로 변환  
- application.yaml의 환경변수와 일치하도록 환경변수 설정 
- 백킹서비스 연결 확인 결과를 바탕으로 정확한 값을 지정  
- 이미 있으면 덮어씀 
- 예시
```
<component name="RunManager">
<configuration name="user-service" type="GradleRunConfiguration"       
factoryName="Gradle">
<ExternalSystemSettings>
  <option name="env">
	<map>
	  <entry key="{환경변수Key}" value="{환경변수 value}" />
	  ...
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
	  <option value="{service-name}:bootRun" />
	</list>
  </option>
  <option name="vmOptions" />
</ExternalSystemSettings>
<ExternalSystemDebugServerProcess>true</ExternalSystemDebugServe     
rProcess>
<ExternalSystemReattachDebugProcess>true</ExternalSystemReattach     
DebugProcess>
<DebugAllEnabled>false</DebugAllEnabled>
<RunAsTest>false</RunAsTest>
<method v="2" />
</configuration>
```

[참고자료]
- 데이터베이스설치결과서
- 캐시설치결과서
- MQ설치결과서
  
[결과파일]
- develop/dev/test-backend.md