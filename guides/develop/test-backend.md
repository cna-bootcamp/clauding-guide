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
  - 설정 Manifest(src/main/resources/application*.yml)와 실행 프로파일({service-name}.run.xml 내부에 있음)의 일치여부 검사 및 수정   
- 실행:
  - 'curl'명령을 이용한 테스트 및 오류 수정
  - 서비스 의존관계를 고려하여 테스트 순서 결정 
  - 순서에 따라 순차적으로 각 서비스의 Controller에서 API 스펙 확인 후 API 테스트 
  - API경로와 DTO클래스를 확인하여 정확한 request data 구성  
  - 소스 수정 후 테스트 절차 
    - 컴파일 및 오류 수정: {프로젝트 루트}/gradlew {service-name}:compileJava
    - 컴파일 성공 후 서비스 재시작 요청: 서비스 시작은 인간에게 요청 
    - 만약 직접 서비스를 실행하려면 '<서비스 시작 방법>'으로 수행  
  - 서비스 중지는 '<서비스 중지 방법>'을 참조 수행  
  - 설정 Manifest 수정 시 민감 정보는 기본값으로 지정하지 않고 '<실행프로파일 작성 가이드>'를 참조하여 실행 프로파일에 값을 지정함 
  - 실행 결과 로그는 'logs' 디렉토리 하위에 생성 
  - 결과: test-backend.md
<실행프로파일 작성 가이드>
- {service-name}/.run/{service-name}.run.xml 파일로 작성
- Kubernetes에 배포된 데이터베이스의 LoadBalancer Service 확인:
  - kubectl get svc -n {namespace} | grep LoadBalancer 명령으로 LoadBalancer IP 확인
  - 각 서비스별 데이터베이스의 LoadBalancer External IP를 DB_HOST로 사용
  - 캐시(Redis)의 LoadBalancer External IP를 REDIS_HOST로 사용
<서비스 시작 방법>
- 'IntelliJ서비스실행기'를 'tools' 디렉토리에 다운로드  
- python 또는 python3 명령으로 백그라우드로 실행하고 결과 로그를 분석  
  nohup python3 tools/run-intellij-service-profile.py {service-name} > logs/{service-name}.log 2>&1 & echo "Started {service-name} with PID: $!" 
- 서비스 실행은 다른 방법 사용하지 말고 **반드시 python 프로그램 이용**
<서비스 중지 방법>
- Window
  - netstat -ano | findstr :{PORT}
  - powershell "Stop-Process -Id {Process number} -Force"
- Linux/Mac
  - netstat -ano | grep {PORT}
  - kill -9 {Process number}
  
[결과파일]
- develop/dev/test-backend.md