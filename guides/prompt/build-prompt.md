# 개발 프롬프트

## 백킹서비스 설치 프롬프트 
### 데이터베이스 
1.설치 가이드 작성 
```
/sc:document --persona-devops --think --uc -c7 --wave-mode auto --wave-strategy systematic --focus architecture

"백킹서비스 설치 가이드"에 따라 데이터베이스 설치 방법을 안내해 주십시오.
```

2.설치 수행 요청
```
/sc:implement --persona-devops --think --uc -c7 --wave-mode auto --wave-strategy systematic

[요구사항]
- 데이터베이스 설치 가이드에 따라 실제 설치 수행
- 현재 OS에 맞게 설치
- AKS에 설치
  - azure login이 이미 되어 있음
  - AKS: aks-digitalgarage-01
- 설치 후 SQL Client(예: DBeaver)에서 접근 방법 안내 
[참고자료]
- build/backing-service/database 하위 파일 
```

