# 백엔드 컨테이너이미지 작성가이드

[요청사항]  
- 백엔드 각 서비스를의 컨테이너 이미지 생성
- 실제 빌드 수행 및 검증까지 완료
- '[결과파일]'에 수행한 명령어를 포함하여 컨테이너 이미지 작성 과정 생성 

[작업순서]
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

- 실행Jar 빌드
  ```
  ./gradlew clean bootJar -x test
  ```
  
- Dockerfile 생성   
  아래 내용으로 deployment/container/Dockerfile-backend 생성  
  ```
  # Build stage
  FROM openjdk:23-oraclelinux8 AS builder
  ARG BUILD_LIB_DIR
  ARG ARTIFACTORY_FILE
  COPY ${BUILD_LIB_DIR}/${ARTIFACTORY_FILE} app.jar

  # Run stage
  FROM openjdk:23-slim
  ENV USERNAME=k8s
  ENV ARTIFACTORY_HOME=/home/${USERNAME}
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
  아래 명령으로 각 서비스 빌드. shell 파일을 생성하지 말고 command로 수행.   
  서브에이젼트를 생성하여 병렬로 수행.   
  ```
  DOCKER_FILE=deployment/container/Dockerfile-backend
  service={서비스명}

  docker build \
    --platform linux/amd64 \
    --build-arg BUILD_LIB_DIR="${서비스명}/build/libs" \
    --build-arg ARTIFACTORY_FILE="${서비스명}.jar" \
    -f ${DOCKER_FILE} \
    -t ${서비스명}:latest .
  ```
- 생성된 이미지 확인   
  아래 명령으로 모든 서비스의 이미지가 빌드되었는지 확인   
  ```
  docker images | grep {서비스명}
  ```

[결과파일]
deployment/container/build-image.md
