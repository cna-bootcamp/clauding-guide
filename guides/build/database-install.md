# 데이터베이스설치가이드 

[요청사항]  
- 제공된 {설치대상환경}에만 설치 
- 데이터베이스설치계획서에 따라 병렬로 설치 
- 캐시설치계획서에 따라 병렬로 설치 
- 현재 OS에 맞게 설치
- 설치 후 데이터베이스 종류에 맞게 연결 방법 안내
- 설치 대상 클라우드 플랫폼은 이미 로그인되어 있고 Kubernetes도 연결되어 있음  
- '[결과파일]' 안내에 따라 파일 작성 

[참고자료]
- 데이터베이스설치계획서
- 캐시설치계획서

[결과파일]
- build/database/exec/db-exec-{service-name}-{설치대상환경}.md
- build/database/exec/cache-exec-{service-name}-{설치대상환경}.md
- {service-name}은 영어로 작성  
- {설치대상환경}은 dev 또는 prod로 함