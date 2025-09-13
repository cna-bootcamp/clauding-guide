# 프론트엔드 컨테이너이미지 작성가이드

[요청사항]  
- 프론트엔드 서비스의 컨테이너 이미지 생성
- 실제 빌드 수행 및 검증까지 완료
- '[결과파일]'에 수행한 명령어를 포함하여 컨테이너 이미지 작성 과정 생성 

[작업순서]
- 서비스명 구하기 
  package.json의 "name" 필드값이 서비스명임.  
  예시) 아래예에서는 'tripgen-front'가 서비스명임.  
  ```
  {
    "name": "tripgen-front",
    "private": true,
  ```
- package.json과 package-lock.json 일치   
  아래 명령을 수행합니다.     
  ```
  npm install
  ```
- nginx.conf 파일 생성   
  아래 내용으로 deployment/container/nginx.conf 파일 생성   
  ```
  server {
      listen 8080;
      server_name localhost;
      
      location / {
          root /usr/share/nginx/html;
          index index.html index.htm;
          try_files $uri $uri/ /index.html;
          
          # Cache static files
          location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
              expires 1y;
              add_header Cache-Control "public, no-transform";
          }
      }
      
      # Health check endpoint
      location /health {
          access_log off;
          return 200 'healthy\n';
          add_header Content-Type text/plain;
      }
      
      # Error pages
      error_page 500 502 503 504 /50x.html;
      location = /50x.html {
          root /usr/share/nginx/html;
      }
  }
  ```

- Dockerfile 생성   
  아래 내용으로 deployment/container/Dockerfile-frontend 생성  
  ```
  # Build stage
  FROM node:20-slim AS builder
  ARG PROJECT_FOLDER
  ENV NODE_ENV=development

  WORKDIR /app

  # Install dependencies
  COPY ${PROJECT_FOLDER}/package*.json ./
  RUN npm ci

  # Build application
  COPY ${PROJECT_FOLDER} .
  # Fix rollup optional dependencies issue
  RUN rm -rf node_modules package-lock.json && npm install
  RUN npm run build

  # Run stage
  FROM nginx:stable-alpine

  ARG BUILD_FOLDER
  ARG EXPORT_PORT

  # Create nginx user if it doesn't exist
  RUN adduser -S nginx || true

  # Copy build files
  COPY --from=builder /app/dist /usr/share/nginx/html

  # Copy and process nginx configuration
  COPY ${BUILD_FOLDER}/nginx.conf /etc/nginx/templates/default.conf.template

  # Add custom nginx settings
  RUN echo "client_max_body_size 100M;" > /etc/nginx/conf.d/client_max_body_size.conf && \
    echo "proxy_buffer_size 128k;" > /etc/nginx/conf.d/proxy_buffer_size.conf && \
    echo "proxy_buffers 4 256k;" > /etc/nginx/conf.d/proxy_buffers.conf && \
    echo "proxy_busy_buffers_size 256k;" > /etc/nginx/conf.d/proxy_busy_buffers_size.conf

  # Set permissions
  RUN chown -R nginx:nginx /usr/share/nginx/html && \
      chmod -R 755 /usr/share/nginx/html && \
      chown -R nginx:nginx /var/cache/nginx && \
      chown -R nginx:nginx /var/log/nginx && \
      chown -R nginx:nginx /etc/nginx/conf.d && \
      touch /var/run/nginx.pid && \
      chown -R nginx:nginx /var/run/nginx.pid

  USER nginx

  EXPOSE ${EXPORT_PORT}

  CMD ["nginx", "-g", "daemon off;"]
  ```

- 컨테이너 이미지 생성    
  아래 명령으로 각 서비스 빌드. shell 파일을 생성하지 말고 command로 수행.    
  ```
  DOCKER_FILE=deployment/container/Dockerfile-frontend

  docker build \
    --platform linux/amd64 \
    --build-arg PROJECT_FOLDER="." \
    --build-arg BUILD_FOLDER="deployment/container" \
    --build-arg EXPORT_PORT="8080" \
    -f ${DOCKER_FILE} \
    -t {서비스명}:latest .
  ```
- 생성된 이미지 확인   
  아래 명령으로 모든 서비스의 이미지가 빌드되었는지 확인   
  ```
  docker images | grep {서비스명}
  ```

[결과파일]
deployment/container/build-image.md
