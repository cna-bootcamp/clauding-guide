# 컨테이너이미지생성가이드

[요청사항]  
- 백엔드 각 서비스를의 컨테이너 이미지 생성
- 프론트엔드 서비스의 컨테이너 이미지 생성

[작업순서]
- 백엔드 컨테이너 이미지 생성     
  - 작업 디렉토리로 이동  
    ```
    cd {백엔드 디렉토리}
    ```  
1.1 실행Jar 파일 설정   
- 서비스명은 settings.gradle에서 확인 
- 실행Jar 파일명을 서비스명과 일치하도록 build.gradle에 설정 합니다.   
```
bootJar {
    archiveFileName = 'user-service.jar'
}
```

1.1 Dockerfile생성  
아래 내용으로 deployment/container/Dockerfile 생성  
```
# Build stage
FROM openjdk:23-oraclelinux8 AS builder
ARG BUILD_LIB_DIR
ARG ARTIFACTORY_FILE
COPY ${BUILD_LIB_DIR}/${ARTIFACTORY_FILE} app.jar

# Run stage
FROM openjdk:23-slim
ENV USERNAME k8s
ENV ARTIFACTORY_HOME /home/${USERNAME}
ENV JAVA_OPTS=""

# Add a non-root user
RUN adduser --system --group ${USERNAME} && \
    mkdir -p ${ARTIFACTORY_HOME} && \
    chown ${USERNAME}:${USERNAME} ${ARTIFACTORY_HOME}

WORKDIR ${ARTIFACTORY_HOME}
COPY --from=builder app.jar app.jar
RUN chown ${USERNAME}:${USERNAME} app.jar

USER ${USERNAME}

ENTRYPOINT [ "sh", "-c" ]
CMD ["java ${JAVA_OPTS} -jar app.jar"]
```

1.2 컨테이너 이미지 생성   

```
DOCKER_FILE=deployment/container/Dockerfile
service={service}

docker build \
  --platform linux/amd64 \
  --build-arg BUILD_LIB_DIR="${service}/build/libs" \
  --build-arg ARTIFACTORY_FILE="${service}.jar" \
  -f ${DOCKER_FILE} \
  -t ${service}:latest .
```