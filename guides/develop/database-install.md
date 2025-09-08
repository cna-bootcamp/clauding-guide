# 데이터베이스설치가이드 

[요청사항]  
- 제공된 {설치대상환경}에만 설치 
- 데이터베이스설치계획서에 따라 병렬로 설치 
- 캐시설치계획서에 따라 병렬로 설치 
- 현재 OS에 맞게 설치
- 설치 후 데이터베이스 종류에 맞게 연결 방법 안내
- 설치 대상 클라우드 플랫폼은 이미 로그인되어 있고 Kubernetes도 연결되어 있음  
- Kubernetes에 배포 manifest나 helm 설치를 위한 values.yaml은 develop/database/exec 디렉토리에 생성  
- Database나 Redis를 Kubernetes에 배포한 경우 로컬에서 연결하기 위한 LoadBalancer 타입의 서비스 객체 생성   
- '[결과파일]' 안내에 따라 파일 작성 
- 설치 결과 파일에는 설치 helm 명령, 설치 시 사용한 values.yaml 등을 포함하여 작성   

[참고자료]
- 데이터베이스설치계획서
- 캐시설치계획서

[결과파일]
- develop/database/exec/db-exec-{설치대상환경}.md
- develop/database/exec/cache-exec-{설치대상환경}.md
- {service-name}은 영어로 작성  
- {설치대상환경}은 dev 또는 prod로 함
