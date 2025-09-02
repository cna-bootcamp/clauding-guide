# 컨테이너이미지생성가이드

[요청사항]  
- 백엔드 각 서비스를의 컨테이너 이미지 생성

[작업순서]
- 백엔드 컨테이너 이미지 생성     
  - 작업 디렉토리로 이동  
    ```
    cd {백엔드 디렉토리}
    ```  
  - 서비스명 확인
    서비스명은 settings.gradle에서 확인 
    
    예시) include 'common'하위의 4개가 서비스명임.  
    ```
    rootProject.name = 'tripgen'

    include 'common'
    include 'user-service'
    include 'location-service'
    include 'ai-service'
    include 'trip-service'
    ```  

  - 실행Jar 파일 설정   
    실행Jar 파일명을 서비스명과 일치하도록 build.gradle에 설정 합니다.   
    ```
    bootJar {
        archiveFileName = '{서비스명}.jar'
    }
    ```

  - Dockerfile생성  
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

  - 컨테이너 이미지 생성   
    ```
    DOCKER_FILE=deployment/container/Dockerfile
    service={서비스명}

    docker build \
      --platform linux/amd64 \
      --build-arg BUILD_LIB_DIR="${서비스명}/build/libs" \
      --build-arg ARTIFACTORY_FILE="${서비스명}.jar" \
      -f ${DOCKER_FILE} \
      -t ${서비스명}:latest .
    ```
