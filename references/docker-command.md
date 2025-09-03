# Docker 명령어

## 목차
- [Docker 명령어](#docker-명령어)
  - [목차](#목차)
  - [핵심 명령어: 이미지 빌드/푸시/컨테이너 실행](#핵심-명령어-이미지-빌드푸시컨테이너-실행)
  - [**컨테이너 중지/시작/삭제**](#컨테이너-중지시작삭제)
  - [**이미지 지우기**](#이미지-지우기)
  - [**중지된 컨테이너 정리**](#중지된-컨테이너-정리)
  - [**컨테이너로 명령 실행 하기**](#컨테이너로-명령-실행-하기)
  - [**파일 복사하기**](#파일-복사하기)
  - [**이미지 압축하기/압축파일에서 이미지 로딩하기**](#이미지-압축하기압축파일에서-이미지-로딩하기)
  - [**불필요한 이미지 정리**](#불필요한-이미지-정리)
  - [**컨테이너간 통신**](#컨테이너간-통신)

---

## 핵심 명령어: 이미지 빌드/푸시/컨테이너 실행


| [Top](#목차) |

---

## **컨테이너 중지/시작/삭제**  
각 컨테이너를 중지해 보십시오.   
```
docker stop lifesub-web member mysub recommend
```
컨테이너가 중지되면 프로세스가 사라지는게 아니라 중지만 됩니다.   
중지된 컨테이너 프로세스를 보려면 ?   
네, docker ps -a 로 보면 됩니다.   
해볼까요? 어라! 아무것도 안보이네요.  
```
docker ps -a 
```
  
왜 그럴까요?   
컨테이너 실행할 때 옵션을 찬찬히 볼까요?   
```
docker run -d --name member --rm -p 8081:8081 \
....

```

어떤 옵션 때문에 컨테이너 중지 시 바로 프로세스가 삭제되었는지 찾으셨나요?  
  
'--rm'옵션 때문입니다.  
이 옵션을 지우고 다시 실행하고 다시 중지 해 봅시다.  
```
docker run -d --name member -p 8081:8081 \
-e POSTGRES_HOST=${POSTGRES_HOST} \
-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
-e ALLOWED_ORIGINS=http://${VM_HOST}:18080 \
--network lifesub-network \
member:latest

docker run -d --name mysub -p 8082:8082 \
-e POSTGRES_HOST=${POSTGRES_HOST} \
-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
-e ALLOWED_ORIGINS=http://${VM_HOST}:18080 \
--network lifesub-network \
mysub:latest

docker run -d --name recommend -p 8083:8083 \
-e POSTGRES_HOST=${POSTGRES_HOST} \
-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
-e ALLOWED_ORIGINS=http://${VM_HOST}:18080 \
--network lifesub-network \
recommend:latest

docker run -d --name lifesub-web -p 18080:18080 \
lifesub-web:latest
```

```
docker stop lifesub-web member mysub recommend
docker ps -a
```
이젠 'EXIT'상태의 컨테이너가 보일겁니다.   
  

중지된 컨테이너를 다시 시작해 봅시다.   
```
docker start lifesub-web member mysub recommend
docker ps
```

잘 다시 실행되죠?  

  
다시 중지시키고 이번엔 완전히 삭제 해 봅시다.  
```
docker stop lifesub-web member mysub recommend
docker ps -a
```

docker rm으로 영구 삭제 합니다.  
```
docker rm lifesub-web member mysub recommend
docker ps -a
```

| [Top](#목차) |

---

## **이미지 지우기**  
4개 이미지가 더 이상 필요 없다고 가정해 봅시다.  
이미지를 지우려면 docker rmi 명령을 사용하면 됩니다.   
이미지를 정리 안하면 스토리지를 차지하기 때문에 정기적으로 지우는게 좋습니다.  
member, mysub은 다음 실습에 사용하므로 나머지 이미지만 삭제해 봅시다.  
```
docker rmi lifesub-web recommend
docker images 
```

docker tag를 사용해서 만든 이미지가 있으면 잘 안지워질때가 있습니다.   
이때는 '--force'옵션을 추가하시면 됩니다.   

| [Top](#목차) |

---

## **중지된 컨테이너 정리**  
일일히 컨테이너나 이미지를 정리하는게 번거로울 수 있습니다.   
일괄적으로 처리하는 명령이 있습니다.  
먼저 중지된 컨테이너들을 모두 한꺼번에 삭제하는 명령은?  
docker container prune 입니다.   
테스트를 위해 '--rm'옵션 없이 컨테이너를 실행하고 중지하십시오.   
```
docker run -d --name member -p 8081:8081 \
-e POSTGRES_HOST=${POSTGRES_HOST} \
-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
-e ALLOWED_ORIGINS=http://${VM_HOST}:18080 \
--network lifesub-network \
member:latest

docker run -d --name mysub -p 8082:8082 \
-e POSTGRES_HOST=${POSTGRES_HOST} \
-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
-e ALLOWED_ORIGINS=http://${VM_HOST}:18080 \
--network lifesub-network \
mysub:latest

docker stop member mysub
docker ps -a
```

```
docker container prune
```

이제 정지된 컨테이너가 모두 삭제되었을겁니다.  
```
docker ps -a
```

| [Top](#목차) |

---

## **컨테이너로 명령 실행 하기**  
컨테이너 안에 원하는 파일이 있는지, 환경변수는 잘 생성되었는지 보고 싶을 수 있습니다.  
이때 컨테이너 내부로 명령을 보내야 하는데 이때 docker exec 를 사용합니다.  
우선 member서비스를 다시 실행하고 테스트 해 보죠.  
```
docker run -d --name member -p 8081:8081 \
-e POSTGRES_HOST=${POSTGRES_HOST} \
-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
-e ALLOWED_ORIGINS=http://${VM_HOST}:18080 \
--network lifesub-network \
member:latest
```

docker exec -it {container name / id} {command} 
```
docker exec -it member env
docker exec -it member ls -al /
```

이걸 응용해서 컨테이너 안으로 들어갈 수도 있습니다.   
'bash'를 지원 안하면 'sh'을 사용하십시오.   
```
docker exec -it member bash
ls -al
```

| [Top](#목차) |

---

## **파일 복사하기**  
컨테이너 내부로 파일을 복사하거나, 반대로 컨테이너 내의 파일을 밖으로 복사할 수 있습니다.  
docker cp {소스 경로} {타겟경로}의 문법으로 사용하며, 컨테이너의 경로는 {컨테이너명/id:경로}형식으로 지정합니다.   
```
cd ~/workspace/lifesub

docker exec -it member mkdir -p /tmp
docker cp member/build.gradle member:/tmp/build.gradle
docker exec -it member ls -al /tmp
```

반대로 컨테이너 안의 파일을 복사해 볼까요?
```
docker cp member:/home/k8s/app.jar ./member.jar
ls -al
```

| [Top](#목차) |

---

## **이미지 압축하기/압축파일에서 이미지 로딩하기**  
폐쇄망안으로 컨테이너 이미지를 반입할 때 많이 사용합니다.   
인터넷망에서 이미지를 압축파일로 만들어 반입한 후 내부망에서 이미지를 압축파일로 부터 로딩하는 방법입니다.  
```
docker save mysub:latest -o mysub.tar
ls -al mysub.tar
```

```
docker rmi mysub
docker images mysub 
```

```
docker load -i mysub.tar
docker images mysub
```

| [Top](#목차) |

---

## **불필요한 이미지 정리**  
더 이상 안 사용하는 이미지를 남기면 스토리지만 낭비됩니다.  
그렇다고 일일히 찾기도 힘들죠.  
이때 쓸 수 있는 명령이 docker image prune -a 입니다.  
이미지를 사용하는 컨테이너가 있으면 안되기 때문에 모든 컨테이너를 삭제합니다.  
```
docker stop $(docker ps -q)
```

```
docker container prune
```

```
docker images
docker image prune -a
docker images
```

| [Top](#목차) |

---

## **컨테이너간 통신**  
서버 사이드에서 컨테이너 간 통신을 위해 가상의 통신망을 이용할 수 있습니다.  
docker의 network 객체로 가상의 통신망을 만들고 컨테이너 실행 시   
동일한 network 객체를 사용하면 컨테이너간 컨테이너 이름으로 통신할 수 있게 됩니다.   
member 서비스의 database를 K8S에 배포한 DB를 사용하지 않고,  
Docker 컨테이너로 실행한 DB를 사용하도록 해 보겠습니다.   

Database배포 전에 생성한 컨테이너간 통신을 위한 네트워크 객체를 확인합니다.  
```
docker network ls
```

POSTGRES_HOST는 k8s의 DB pod가 아니라 위에서 실행한 container 이름으로 지정합니다.   
```
docker run -d --name member -p 8081:8081 \
-e POSTGRES_HOST=postgres-lifesub \
-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
-e ALLOWED_ORIGINS=http://${VM_HOST}:18080 \
--network lifesub-network \
member:latest
```

웹 브라우저를 열고 member 서비스의 swagger page를 엽니다.  
http://localhost:8081/swagger-ui.html   


| [Top](#목차) |

