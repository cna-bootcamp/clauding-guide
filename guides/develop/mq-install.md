# MQ설치가이드 

[요청사항]  
- 제공된 {설치대상환경}에만 설치 
- 'MQ설치계획서'에 따라 병렬로 설치 
- 현재 OS에 맞게 설치
- 설치 후 연결 방법 안내
- 설치 대상 클라우드 플랫폼은 이미 로그인되어 있음  
- Kubernetes에 배포 manifest는 develop/mq 디렉토리에 생성하고 완료 후 삭제   
- MQ연결문자열을 얻는 명령어를 결과서에 명시하고 연결문자열을 mq-connection-string.txt에 저장  
- '[결과파일]' 안내에 따라 파일 작성 

[참고자료]
- MQ설치계획서

[결과파일]
- develop/mq/mq-exec-{설치대상환경}.md
- {설치대상환경}은 dev 또는 prod로 함
- mq-connection-string.txt