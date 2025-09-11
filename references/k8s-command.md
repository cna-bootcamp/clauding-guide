# 쿠버네티스 명령어 실습

## 목차  
- [쿠버네티스 명령어 실습](#쿠버네티스-명령어-실습)
  - [목차](#목차)
  - [로그인](#로그인)
  - [객체 생성 및 수정: kubectl apply](#객체-생성-및-수정-kubectl-apply)
  - [객체 리스트 조회: kubectl get](#객체-리스트-조회-kubectl-get)
  - [객체 정보 보기: kubectl describe](#객체-정보-보기-kubectl-describe)
  - [파드 로그 보기: kubectl logs \[-f\]](#파드-로그-보기-kubectl-logs--f)
  - [파드 내 명령 내리기: kubectl exec -it](#파드-내-명령-내리기-kubectl-exec--it)
  - [객체 수정: kubectl edit](#객체-수정-kubectl-edit)
  - [객체 삭제: kubectl delete](#객체-삭제-kubectl-delete)
  - [수동 스케일링: kubectl scale](#수동-스케일링-kubectl-scale)
  - [파드 재시작 하기: kubectl rollout](#파드-재시작-하기-kubectl-rollout)
  - [k8s 클러스터 외부에서 포트 Forward하여 파드 접근하기: kubectl port-forward](#k8s-클러스터-외부에서-포트-forward하여-파드-접근하기-kubectl-port-forward)
  - [유지보수 관련 명령: cordon, uncordon, drain, taint](#유지보수-관련-명령-cordon-uncordon-drain-taint)
  - [k9s](#k9s)


## 로그인
Window사용자는 Window 터미널의 'Git Bash' 터미널에서 작업하고 맥/리눅스 사용자는 기본 터미널에서 작업하십시오.    
실습은 주로 프론트엔드 서비스를 대상으로 하겠습니다.   
매니페스트 파일 편집은 vscode에서 하고 명령어는 터미널에서 하십시오.   

## 객체 생성 및 수정: kubectl apply    
프론트엔드 프로텍트 디렉토리로 이동합니다.  
```
cd ~/home/workspace/phonebill-front
```

vscode에서 오픈 합니다. 
```
code .
```

deployment/k8s/deployment.yaml 파일을 엽니다.  
  
replicas를 2로 수정하고 저장합니다.  
![](images/2025-09-11-14-31-43.png)  

현재 phonebill-front 파드의 갯수를 확인해 보세요.  1개만 있을 겁니다.  
```
k get po | grep phonebill-front
```

작업 편의를 위해 Deployment 매니페스트가 있는 디렉토리로 이동합니다.  
```
cd deployment/k8s
```

아래 명령으로 매니페스트 내용을 적용하고 2개로 늘어 나는지 확인 합니다.    
```
k apply -f deployment.yaml  
k get po 
```

| [Top](#목차) |

---

## 객체 리스트 조회: kubectl get 
생성된 모든 오브젝트들을 봅니다.  
```
kubectl get all
```

각 리소스 종류별로 오브젝트를 조회합니다.  
```
k get po
k get deploy
k get sts
k get svc
k get ing
k get cm
k get secret
k get pv
k get pvc
```

다른 네임스페이스의 오브젝트도 조회 해 봅니다. 
위 명령 끝에 '-n {조회할 네임스페이스명}'을 붙이면 됩니다.  
```
kubectl get po -n kube-system
```

오브젝트의 yaml 내용을 조회해 봅니다.   
```
kubectl get deploy phonebill-front -o yaml
```

yaml내용을 파일로 저장해 봅니다.  
```
kubectl get deploy phonebill-front -o yaml > tmp.yaml 
```

오브젝트의 label을 조회해 봅니다.  pod이름은 본인 것으로 변경해야 합니다.   
```
kubectl get deploy phonebill-front --show-labels
k get po
kubectl get po {pod명} --show-labels  
```

오브젝트의 좀 더 많은 정보를 '-o wide'를 붙여 확인합니다.   
```
kubectl get deploy phonebill-front -o wide --show-labels
kubectl get po node -o wide --show-labels  
```

모든 네임 스페이스에서 오브젝트 리스트를 확인 합니다.   
```
kubectl get po -A
kubectl get deploy -A
kubectl get svc -A
kubectl get ing -A
```

아래는 자주 사용하는 k8s 리소스입니다.  
![](images/2025-09-11-14-41-08.png)  

전체 리소스를 보려면 아래 명령으로 보면 됩니다.  
```
k api-resources
```

| [Top](#목차) |

---

## 객체 정보 보기: kubectl describe  
원하는 객체의 정보를 조회 합니다.   
```
k get po
kubectl describe po {pod명}
kubectl describe deploy phonebill-front
kubectl describe svc phonebill-front
```

가장 많이 사용 하게될 리소스는 pod 일 것입니다.   
파드가 제대로 실행 안 되었을 때 그 원인을 찾을 때 describe를 매우 많이 사용합니다.  

아래 예와 같이 'Events' 부분을 보고 문제를 해결해 나갑니다.   
이미지를 풀링 실패, Readiness Probe 실패, 런타임 실패로 재시작 등이 많이 나오는 유형입니다.  
```
% k get po | grep phonebill-front
phonebill-front-7774959b75-5lks4           0/1     Pending   0          4m
phonebill-front-7774959b75-nbcx5           1/1     Running   0          128m
% k describe po phonebill-front-7774959b75-5lks4

...

Events:
  Type     Reason             Age    From                Message
  ----     ------             ----   ----                -------
  Warning  FailedScheduling   4m18s  default-scheduler   0/13 nodes are available: 1 node(s) had untolerated taint {dedicated: aipool}, 1 node(s) had untolerated taint {dedicated: cicd}, 1 node(s) had untolerated taint {dedicated: sonarqube}, 3 Insufficient memory, 8 Insufficient cpu. preemption: 0/13 nodes are available: 10 No preemption victims found for incoming pod, 3 Preemption is not helpful for scheduling.
  Normal   NotTriggerScaleUp  4m15s  cluster-autoscaler  pod didn't trigger scale-up: 1 max node group size reached

```

| [Top](#목차) |

---

## 파드 로그 보기: kubectl logs [-f]
파드 로그를 확인해 봅니다.  
```
k get po 
kubectl logs phonebill-front-569f6b555d-jggww
```

'-f'옵션을 붙이면 log를 실시간 스트리밍할 수 있습니다.   

```
kubectl logs -f recommend-6c6f858486-bpz9l
```

deploy객체를 이용하여 관리하는 파드의 로그를 볼 수도 있습니다.   
파드명은 재생성하면 바뀌므로 파드가 1개일 때는 deploy를 이용 하기도 합니다.  
'/'로 구분하여 지정한다는거에 유의하세요.   
```
k logs -f deploy/phonebill-front 
```

그리고 웹 브라우저에서 로그인한 후 메인화면을 리프레시 해 보십시오.  
로그가 실시간으로 나오는 걸 확인할 수 있습니다.  

CTRL-C를 눌러 빠져 나오세요.  

만약 Pod안에 container가 2개 이상이면 '-c' 옵션으로 로그를 볼 컨테이너명을 지정해 줘야 합니다.   

| [Top](#목차) |

---

## 파드 내 명령 내리기: kubectl exec -it 

docker exec에서는 명령 앞에 아무것도 없었으나 kubectl은 '--'를 붙여줘야 수행됩니다.   
'--' 뒤에 파드 내에 내릴 명령을 입력하면 됩니다.   
```
k exec -it phonebill-front-569f6b555d-jggww -- ls -al /
```

아래 명령으로 파드 내부로 진입합니다.  
진입 후 pwd로 현재 위치를 확인해 보고,  '/usr/share/nginx/html' 디렉토리로 이동하여 파일을 확인해 봅니다.    
deployment/container/Dockerfile-frontend의 내용을 보면 이 디렉토리로 파일을 복사하는 걸 확인할 수 있고,    
실제 파일이 복사된걸 확인할 수 있습니다.   
```
# Copy build files
COPY --from=builder /app/dist /usr/share/nginx/html

```

```
kubectl exec -it phonebill-front-569f6b555d-jggww -- sh

pwd
cd /usr/share/nginx/html
ls -al
```

또한 runtime-env.js 파일도 보일겁니다.   
이는 deployment/k8s/deployment.yaml에서 볼륨 마운트를 했기 때문에 생긴겁니다.   
```
...
        volumeMounts:
        - name: runtime-config
          mountPath: /usr/share/nginx/html/runtime-env.js
          subPath: runtime-env.js
      volumes:
      - name: runtime-config
        configMap:
          name: cm-phonebill-front
```

exit를 입력하여 파드를 빠져 나옵니다.  


| [Top](#목차) |

---

## 객체 수정: kubectl edit
예제로 Service 객체를 수정해 보겠습니다.   
아래 명령으로 Service 'phonebill-front'의 편집 모드로 진입합니다.   
```
kubectl edit svc phonebill-front
```

맨 끝에 쯤 있는 type: ClusterIP를 type: NodePort로 변경합니다.  
ESC를 누르고 ':wq'를 눌러 저장하고 닫습니다.   

Service를 조회해 봅니다.  뭐가 달라졌나요?  
```
kubectl get svc
```

PORT(S)의 ':' 뒤에 있는 포트가 외부 포트입니다.  이 포트로 브라우저에서 접근해 보십시오.   
예를 들어 외부 포트가 31677이면 아래와 같이 접근할 수 있습니다.   
이때 Host는 k8s 노드중 아무 노드의 Public IP를 지정하면 됩니다.   
우리는 k8s 노드들이 외부에 오픈 안되어 있으므로 테스트는 못하겠네요.  
```
http://43.200.12.214:31677
```

| [Top](#목차) |

---

## 객체 삭제: kubectl delete  
파드를 삭제 해 보십시오.  
```
k get po | grep phonebill-front
kubectl delete po {phonebill-front 파드명}
```

파드를 지웠으니 이제 파드 갯수가 하나 줄어야 할겁니다.    
다시 한번 파드 리스트를 확인해 보세요.   
파드가 있습니다.  안 지워진걸까요? 누가 다시 만든걸까요?     
잘 보시면 파드이름이 그 전 파드와 다릅니다. 다시 만들어진겁니다.     
누가 다시 만들었을까요?  쿠버네티스 아키텍처에서 어떤 컴포넌트일까요?      
  
Controller Manager입니다.  
  

어떤 리소스가 다시 만든걸까요?  

Workload Controller입니다.  그 중에서도 phonebill-front 파드를 관리하는 Deployment 'phonebill-front'객체입니다.  

  
그럼 파드를 완전히 삭제하려면 어떻게 해야 할까요?    
파드를 배포한 워크로드 컨트롤러를 삭제해야 합니다.   
   
아래와 같이 deployment 객체를 지워 보십시오.   
```
kubectl delete deploy phonebill-front
```

이제 파드를 조회 해 보면 삭제되었을 겁니다.   

리소스유형을 지정하여 해당 리소스로 생성된 모든 객체를 삭제할 수 있습니다.   
아래 명령으로 모든 service객체를 삭제해 보십시오.  
```
kubectl delete svc --all
```
> 주의: Secret은 한꺼번에 삭제 하지 마세요.   
> 이렇게 한꺼번에 삭제하는 건 실수 할 수 있으니 가급적 사용하지 마세요.    

yaml 파일을 지정하여 그 파일에 정의된 객체를 한꺼번에 삭제할 수 있습니다.   
```
kubectl delete -f deployment.yaml
```

파드 객체 리스트를 조회해 보면 모두 사라진 걸 확인할 수 있을겁니다.   
```
k get po
```

파드가 잘 삭제 안될 경우가 있습니다.  
강제로 삭제하는 방법으로 '--force'와 '--grace-period=0'을 같이 쓰면 즉시 삭제 됩니다.  
```
k get po | grep phonebill-front
k delete phonebill-front-569f6b555d-jggww
k get po | grep phonebill-front 
k delete po phonebill-front-569f6b555d-jggww --force --grace-period=0
k get po | grep phonebill-front
```


다시 실습을 위해 지운 객체를 다시 생성합니다.   
바로 위 디렉토리로 이동하여 deployments와 services 디렉토리를 지정하여 생성해 봅니다.   
```
cd ..

k apply -f deployment.yaml

k apply -f service.yaml

```

| [Top](#목차) |

---

## 수동 스케일링: kubectl scale   
파드의 갯수를 수동으로 조정할 수 있습니다.  
```
k scale --replicas=2 deploy phonebill-front 
```

파드를 일시적으로 중단시키는 방법으로 응용할 수도 있습니다.  
```
k scale --replicas=0 deploy phonebill-front 
```

다시 원복 합니다.  
```
k scale --replicas=1 deploy phonebill-front 
```

| [Top](#목차) |

---

## 파드 재시작 하기: kubectl rollout 
파드를 관리하는 Workload Controller 객체를 이용하여 파드를 재시작 할 수 있습니다.   
```
k get po | grep phonebill-front
phonebill-front-555df65b6c-2rhxc        1/1     Running   0               83s
...

# deployment객체를 이용하여 파드를 재시작합니다.  
k rollout restart deploy phonebill-front
deployment.apps/phonebill-front restarted

# 파드명을 잘 보면 1번째는 기존 파드이고, 2번째 새로운 파드가 시작되었습니다.  
k get po | grep phonebill-front
phonebill-front-555df65b6c-2rhxc        1/1     Running   0               4m45s
phonebill-front-64945c6c44-x5228        0/1     Running   0               4s
...


```

| [Top](#목차) |

---

## k8s 클러스터 외부에서 포트 Forward하여 파드 접근하기: kubectl port-forward 
개발 시ㅣ 테스트 목적으로 클라이언트에서 파드를 접근하여야 할 경우가 자주 있습니다.  
파드는 서비스 리소스를 통해 접근 하므로 서비스를 포트 Forward 하면 됩니다.   
서비스의 유형이 어떤 것이든 모두 됩니다.

아래와 같이 phonebill-front 서비스를 포트 Forward 합니다.  
먼저 Service객체의 포트를 확인합니다.  
```
k get svc | grep front 
```

```
k port-forward svc/phonebill-front 3000:8080
```

웹브라우저에서 http://localhost:3000 으로 접근합니다.  


| [Top](#목차) |

---

## 유지보수 관련 명령: cordon, uncordon, drain, taint
각 명령어들은 쿠버네티스 노드 관리를 위한 kubectl 명령어들입니다.    

1.cordon/uncordon: 노드에 새로운 파드가 스케줄링되는 것을 방지하거나 방지 해제  
cordon 된 노드는 STATUS에 'SchedulingDisabled'라고 표시됩니다.     
```bash
ubuntu@dreamondal:~$ k get nodes
NAME                                STATUS   ROLES    AGE    VERSION
aks-nodepool1-18726331-vmss000000   Ready    <none>   2d9h   v1.30.9
aks-nodepool1-18726331-vmss000001   Ready    <none>   2d9h   v1.30.9
aks-nodepool1-18726331-vmss000006   Ready    <none>   18h    v1.30.9
aks-nodepool1-18726331-vmss000008   Ready    <none>   9h     v1.30.9

ubuntu@dreamondal:~$ k cordon aks-nodepool1-18726331-vmss000008
node/aks-nodepool1-18726331-vmss000008 cordoned
ubuntu@dreamondal:~$ k get nodes
NAME                                STATUS                     ROLES    AGE    VERSION
aks-nodepool1-18726331-vmss000000   Ready                      <none>   2d9h   v1.30.9
aks-nodepool1-18726331-vmss000001   Ready                      <none>   2d9h   v1.30.9
aks-nodepool1-18726331-vmss000006   Ready                      <none>   18h    v1.30.9
aks-nodepool1-18726331-vmss000008   Ready,SchedulingDisabled   <none>   9h     v1.30.9
```

uncordon 예시 입니다.  
```
ubuntu@dreamondal:~$ k uncordon aks-nodepool1-18726331-vmss000008
node/aks-nodepool1-18726331-vmss000008 uncordoned
ubuntu@dreamondal:~$ k get nodes
NAME                                STATUS   ROLES    AGE    VERSION
aks-nodepool1-18726331-vmss000000   Ready    <none>   2d9h   v1.30.9
aks-nodepool1-18726331-vmss000001   Ready    <none>   2d9h   v1.30.9
aks-nodepool1-18726331-vmss000006   Ready    <none>   18h    v1.30.9
aks-nodepool1-18726331-vmss000008   Ready    <none>   9h     v1.30.9
```

2.drain: 노드의 파드들을 다른 노드로 이동  
노드의 유지보수 준비를 위해 모든 파드를 내쫒는 명령입니다.  
실습하지는 마세요.  
```bash
# node1의 모든 파드를 다른 노드로 이동
kubectl drain node1 --ignore-daemonsets
```

3.taint: 노드에 테인트를 설정하여 파드 스케줄링 제어   
cordon처럼 노드에 모든 스케쥴링을 금지하는게 아니라 특정 조건에 해당하는 파드만 스케쥴링 하기 위한 목적으로 사용됩니다.  

아래 예에서 normal-pod는 node1에 스케줄링되지 않고, tolerating-pod는 스케줄링이 될 수 있습니다.  
테인트가 걸린 노드에 파드를 배포할 때는 'tolerations' 조건을 이용합니다.  
```
# 1. 노드에 테인트 설정
kubectl taint nodes node1 app=blue:NoSchedule

# 2. 톨러레이션이 없는 일반 파드
apiVersion: v1
kind: Pod
metadata:
  name: normal-pod
spec:
  containers:
  - name: nginx
    image: nginx

# 3. 톨러레이션이 있는 파드
apiVersion: v1
kind: Pod
metadata:
  name: tolerating-pod
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "app"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"
```

| [Top](#목차) |

---

## k9s
[k9s](https://k9scli.io/)는 쿠버네티스 클러스터 관리를 도와주는 편리한 툴입니다.   
![](images/2025-09-11-15-14-42.png)

아래 글에서 설치와 사용법을 익히십시오.  
https://happycloud-lee.tistory.com/237

| [Top](#목차) |

---



