# 백엔드 개발 가이드 

[요청사항]  
- <개발원칙>을 준용하여 개발
- <개발순서>에 따라 아래 3단계로 개발
  - '0. 준비'를 수행하고 완료 후 다음 단계 진행여부를 사용자에게 확인  
  - '1. common 모듈 개발'을 수행하고 완료 후 다음 단계 진행여부를 사용자에게 확인   
  - '2. 각 서비스별 구현'은 사용자와 함께 각 서비스를 개발  
    
[가이드]     
<개발원칙>
- '개발주석표준'에 맞게 주석 작성
- API설계서와 일관성 있게 설계. Controller에 API를 누락하지 말고 모두 개발
- '외부시퀀스설계서'와 '내부시퀀스설계서'와 일치되도록 개발 
- 각 서비스별 지정된 {설계 아키텍처 패턴}을 적용하여 개발
  - Layered 아키텍처 적용 시 Service레이어에 Interface 사용 
  - Clean아키텍처 적용 시 Port/Adapter라는 용어 대신 Clean 아키텍처에 맞는 용어 사용
- 백킹서비스 연동은 '데이터베이스설치결과서', '캐시설치결과서', 'MQ설치결과서'를 기반으로 개발  
- 빌드도구는 Gradle 사용   
- 설정 Manifest(src/main/resources/application*.yml) 작성 시 '[설정 Manifest 표준]' 준용  
  
<개발순서>
- 0. 준비:
  - 참고자료 분석 및 이해 
  - '패키지구조표준'의 예시를 참조하여 모든 클래스와 파일이 포함된 패키지 구조도를 작성 
    - plantuml 스크립트가 아니라 트리구조 텍스트로 작성
    - 결과파일: develop/dev/package-structure.md   
  - settings.gralde 파일 작성
  - build.gradle 작성
    - '<Build.gradle 구성 최적화>' 가이드대로 최상위와 각 서비스별 build.gradle 작성 
    - '[루트 build.gradle 표준]'대로 최상위 build.gradle 작성
      - SpringBoot 3.3.0, Java 21 사용 
      - common을 제외한 각 서비스에서 공통으로 사용되는 설정과 Dependency는 루트 build.gradle에 지정   
    - 서비스별 build.gradle 작성
      - 최상위 build.gradle에 정의한 설정은 각 마이크로서비스의 build.gradle에 중복하여 정의하지 않도록 함   
      - 각 서비스의 실행 jar 파일명은 서비스명과 동일하게 함 
  - 각 서비스별 설정 파일 작성 
    - 설정 Manifest(application.yml) 작성: '[설정 Manifest 표준]' 준용   
  
- 1. common 모듈 개발 
  - 각 서비스에서 공통으로 사용되는 클래스를 개발
  - 외부(웹브라우저, 데이터베이스, Message Queue, 외부시스템)와의 인터페이스를 위한 클래스는 포함하지 않음  
  - 개발 완료 후 컴파일 및 에러 해결: {프로젝트 루트}/gradlew common:compileJava
  
- 2. 각 서비스별 개발  
  - 사용자가 제공한 서비스의 유저스토리, 외부시퀀스설계서, 내부시퀀스설계서, API설계서 파악 
  - 기존 개발 결과 파악 
  - API 설계서의 각 API를 순차적으로 개발 
    - Controller -> Service -> Data 레이어순으로 순차적으로 개발  
    - 컴파일 및 에러 해결: {프로젝트 루트}/gradlew {service-name}:compileJava
    - 컴파일까지만 하고 서버 실행은 하지 않음 
  - 모든 API개발 후 아래 수행
    - 컴파일 및 에러 해결: {프로젝트 루트}/gradlew {service-name}:compileJava 
    - 빌드 및 에러 해결: {프로젝트 루트}/gradlew {service-name}:build 
  - SecurityConfig 클래스 작성: '<SecurityConfig 예제>' 참조 
  - JWT 인증 처리 클래스 작성: '<JWT 인증처리 예제>' 참조 
  - Swagger Config 클래스 작성: '<SwaggerConfig 예제>' 참조 
  - 테스트 코드 작성은 하지 않음     
  
<Build.gradle 구성 최적화>
- **중앙 버전 관리**: 루트 build.gradle의 `ext` 블록에서 모든 외부 라이브러리 버전 통일 관리
- **Spring Boot BOM 활용**: Spring Boot/Cloud에서 관리하는 라이브러리는 버전 명시 불필요 (자동 호환성 보장)
- **Common 모듈 설정**: `java-library` + Spring Boot 플러그인 조합, `bootJar` 비활성화로 일반 jar 생성
- **서비스별 최적화**: 공통 의존성(API 문서화, 테스트 등)은 루트에서 일괄 적용
- **JWT 버전 통일**: 라이브러리 버전 변경시 API 호환성 확인 필수 (`parserBuilder()` → `parser()`)
- **dependency-management 적용**: 모든 서브프로젝트에 Spring BOM 적용으로 버전 충돌 방지
  
[참고자료]
- 유저스토리
- API설계서
- 외부시퀀스설계서
- 내부시퀀스설계서
- 데이터베이스설치결과서
- 캐시설치결과서
- MQ설치결과서
- 테스트코드표준
- 패키지구조표준
   
---
  
[설정 Manifest 표준]
- common모듈은 작성하지 않음 
- application.yml에 작성 
- 하드코딩하지 않고 환경변수 사용
  특히, 데이터베이스, MQ 등의 연결 정보는 반드시 환경변수로 변환해야 함: '<DB/Redis 설정 예제>' 참조   
- spring.application.name은 서비스명과 동일하게 함
- Redis Database는 각 서비스마다 다르게 설정  
- 민감한 정보의 디폴트값은 생략하거나 간략한 값으로 지정
- JWT Secret Key는 모든 서비스가 동일해야 함 
- '[JWT,CORS,Actuaotr,OpenAPI Documentation,Loggings 표준]'을 준수하여 설정
   
[JWT, CORS, Actuaotr,OpenAPI Documentation,Loggings 표준]
```
# JWT 
jwt:
  secret: ${JWT_SECRET:}
  access-token-validity: ${JWT_ACCESS_TOKEN_VALIDITY:1800}  
  refresh-token-validity: ${JWT_ACCESS_TOKEN_VALIDITY:86400} 

# CORS Configuration
cors:
  allowed-origins: ${CORS_ALLOWED_ORIGINS:http://localhost:*}

# Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
      base-path: /actuator
  endpoint:
    health:
      show-details: always
      show-components: always
  health:
    livenessState:
      enabled: true
    readinessState:
      enabled: true

# OpenAPI Documentation
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
    tags-sorter: alpha
    operations-sorter: alpha
  show-actuator: false

# Logging
logging:
  level:
    {서비스 패키지 경로}: ${LOG_LEVEL_APP:DEBUG}
    org.springframework.web: ${LOG_LEVEL_WEB:INFO}
    org.hibernate.SQL: ${LOG_LEVEL_SQL:DEBUG}
    org.hibernate.type: ${LOG_LEVEL_SQL_TYPE:TRACE}
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: ${LOG_FILE_PATH:logs/{서비스명}.log}

```
  
[루트 build.gradle 표준]
```
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.3.0' apply false
    id 'io.spring.dependency-management' version '1.1.6' apply false
    id 'io.freefair.lombok' version '8.10' apply false
}

group = 'com.unicorn.{시스템명}'
version = '1.0.0'

allprojects {
    repositories {
        mavenCentral()
        gradlePluginPortal()
    }
}

subprojects {
    apply plugin: 'java'
    apply plugin: 'io.freefair.lombok'

    java {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    configurations {
        compileOnly {
            extendsFrom annotationProcessor
        }
    }

    tasks.named('test') {
        useJUnitPlatform()
    }
    
    // Common versions for all subprojects
    ext {
        jjwtVersion = '0.12.5'
        springdocVersion = '2.5.0'
        mapstructVersion = '1.5.5.Final'
        commonsLang3Version = '3.14.0'
        commonsIoVersion = '2.16.1'
        hypersistenceVersion = '3.7.3'
        openaiVersion = '0.18.2'
        feignJacksonVersion = '13.1'
    }
}

// Configure all subprojects with Spring dependency management
subprojects {
    apply plugin: 'io.spring.dependency-management'

    dependencyManagement {
        imports {
            mavenBom "org.springframework.cloud:spring-cloud-dependencies:2023.0.2"
        }
    }
}

// Configure only service modules (exclude common)
configure(subprojects.findAll { it.name != 'common' }) {
    apply plugin: 'org.springframework.boot'

    dependencies {
        // Common module dependency
        implementation project(':common')
        
        // Actuator for health checks and monitoring
        implementation 'org.springframework.boot:spring-boot-starter-actuator'
        
        // API Documentation (common across all services)
        implementation "org.springdoc:springdoc-openapi-starter-webmvc-ui:${springdocVersion}"
        
        // Testing
        testImplementation 'org.springframework.boot:spring-boot-starter-test'
        testImplementation 'org.springframework.security:spring-security-test'
        testImplementation 'org.testcontainers:junit-jupiter'
        testImplementation 'org.mockito:mockito-junit-jupiter'
        
        // Configuration Processor
        annotationProcessor 'org.springframework.boot:spring-boot-configuration-processor'
    }
}

// Java version consistency check for all modules
tasks.register('checkJavaVersion') {
    doLast {
        println "Java Version: ${System.getProperty('java.version')}"
        println "Java Home: ${System.getProperty('java.home')}"
    }
}

// Clean task for all subprojects
tasks.register('cleanAll') {
    dependsOn subprojects.collect { it.tasks.named('clean') }
    description = 'Clean all subprojects'
}

// Build task for all subprojects
tasks.register('buildAll') {
    dependsOn subprojects.collect { it.tasks.named('build') }
    description = 'Build all subprojects'
}
```
  
<DB/Redis 설정 예제>
```
spring:
  datasource:
    url: jdbc:${DB_KIND:postgresql}://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:phonebill_auth}
    username: ${DB_USERNAME:phonebill_user}
    password: ${DB_PASSWORD:phonebill_pass}
    driver-class-name: org.postgresql.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      leak-detection-threshold: 60000      
  # JPA 설정
  jpa:
    show-sql: ${SHOW_SQL:true}
    properties:
      hibernate:
        format_sql: true
        use_sql_comments: true
    hibernate:
      ddl-auto: ${DDL_AUTO:update}
      
  # Redis 설정
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}
      timeout: 2000ms
      lettuce:
        pool:
          max-active: 8
          max-idle: 8
          min-idle: 0
          max-wait: -1ms
      database: ${REDIS_DATABASE:0}
  
```
  
<SecurityConfig 예제>
```
/**
 * Spring Security 설정
 * JWT 기반 인증 및 API 보안 설정
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenProvider jwtTokenProvider;
    
    @Value("${cors.allowed-origins:http://localhost:3000,http://localhost:8080,http://localhost:8081,http://localhost:8082,http://localhost:8083,http://localhost:8084}")
    private String allowedOrigins;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // Actuator endpoints
                        .requestMatchers("/actuator/**").permitAll()
                        // Swagger UI endpoints - context path와 상관없이 접근 가능하도록 설정
                        .requestMatchers("/swagger-ui/**", "/swagger-ui.html", "/v3/api-docs/**", "/swagger-resources/**", "/webjars/**").permitAll()
                        // Health check
                        .requestMatchers("/health").permitAll()
                        // All other requests require authentication
                        .anyRequest().authenticated()
                )
                .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider), 
                                UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // 환경변수에서 허용할 Origin 패턴 설정
        String[] origins = allowedOrigins.split(",");
        configuration.setAllowedOriginPatterns(Arrays.asList(origins));
        
        // 허용할 HTTP 메소드
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        
        // 허용할 헤더
        configuration.setAllowedHeaders(Arrays.asList(
            "Authorization", "Content-Type", "X-Requested-With", "Accept", 
            "Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"
        ));
        
        // 자격 증명 허용
        configuration.setAllowCredentials(true);
        
        // Pre-flight 요청 캐시 시간
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```
  
<JWT 인증처리 예제>

1) JwtAuthenticationFilter     
```
/**
 * JWT 인증 필터
 * HTTP 요청에서 JWT 토큰을 추출하여 인증을 수행
 */
@Slf4j
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                  HttpServletResponse response, 
                                  FilterChain filterChain) throws ServletException, IOException {
        
        String token = jwtTokenProvider.resolveToken(request);
        
        if (StringUtils.hasText(token) && jwtTokenProvider.validateToken(token)) {
            String userId = jwtTokenProvider.getUserId(token);
            String username = null;
            String authority = null;
            
            try {
                username = jwtTokenProvider.getUsername(token);
            } catch (Exception e) {
                log.debug("JWT에 username 클레임이 없음: {}", e.getMessage());
            }
            
            try {
                authority = jwtTokenProvider.getAuthority(token);
            } catch (Exception e) {
                log.debug("JWT에 authority 클레임이 없음: {}", e.getMessage());
            }
            
            if (StringUtils.hasText(userId)) {
                // UserPrincipal 객체 생성 (username과 authority가 없어도 동작)
                UserPrincipal userPrincipal = UserPrincipal.builder()
                    .userId(userId)
                    .username(username != null ? username : "unknown")
                    .authority(authority != null ? authority : "USER")
                    .build();
                
                UsernamePasswordAuthenticationToken authentication = 
                    new UsernamePasswordAuthenticationToken(
                        userPrincipal, 
                        null, 
                        Collections.singletonList(new SimpleGrantedAuthority(authority != null ? authority : "USER"))
                    );
                
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authentication);
                
                log.debug("인증된 사용자: {} ({})", userPrincipal.getUsername(), userId);
            }
        }
        
        filterChain.doFilter(request, response);
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return path.startsWith("/actuator") || 
               path.startsWith("/swagger-ui") || 
               path.startsWith("/v3/api-docs") || 
               path.equals("/health");
    }
}
```
  
1) JwtTokenProvider
```
/**
 * JWT 토큰 제공자
 * JWT 토큰의 생성, 검증, 파싱을 담당
 */
@Slf4j
@Component
public class JwtTokenProvider {

    private final SecretKey secretKey;
    private final long tokenValidityInMilliseconds;

    public JwtTokenProvider(@Value("${jwt.secret}") String secret,
                           @Value("${jwt.access-token-validity:3600}") long tokenValidityInSeconds) {
        this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.tokenValidityInMilliseconds = tokenValidityInSeconds * 1000;
    }

    /**
     * HTTP 요청에서 JWT 토큰 추출
     */
    public String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }

    /**
     * JWT 토큰 유효성 검증
     */
    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                .setSigningKey(secretKey)
                .build()
                .parseClaimsJws(token);
            return true;
        } catch (SecurityException | MalformedJwtException e) {
            log.debug("Invalid JWT signature: {}", e.getMessage());
        } catch (ExpiredJwtException e) {
            log.debug("Expired JWT token: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            log.debug("Unsupported JWT token: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            log.debug("JWT token compact of handler are invalid: {}", e.getMessage());
        }
        return false;
    }

    /**
     * JWT 토큰에서 사용자 ID 추출
     */
    public String getUserId(String token) {
        Claims claims = Jwts.parser()
            .setSigningKey(secretKey)
            .build()
            .parseClaimsJws(token)
            .getBody();
        
        return claims.getSubject();
    }

    /**
     * JWT 토큰에서 사용자명 추출
     */
    public String getUsername(String token) {
        Claims claims = Jwts.parser()
            .setSigningKey(secretKey)
            .build()
            .parseClaimsJws(token)
            .getBody();
        
        return claims.get("username", String.class);
    }

    /**
     * JWT 토큰에서 권한 정보 추출
     */
    public String getAuthority(String token) {
        Claims claims = Jwts.parser()
            .setSigningKey(secretKey)
            .build()
            .parseClaimsJws(token)
            .getBody();
        
        return claims.get("authority", String.class);
    }

    /**
     * 토큰 만료 시간 확인
     */
    public boolean isTokenExpired(String token) {
        try {
            Claims claims = Jwts.parser()
                .setSigningKey(secretKey)
                .build()
                .parseClaimsJws(token)
                .getBody();
            
            return claims.getExpiration().before(new Date());
        } catch (Exception e) {
            return true;
        }
    }

    /**
     * 토큰에서 만료 시간 추출
     */
    public Date getExpirationDate(String token) {
        Claims claims = Jwts.parser()
            .setSigningKey(secretKey)
            .build()
            .parseClaimsJws(token)
            .getBody();
        
        return claims.getExpiration();
    }
}
```

1) UserPrincipal
```
/**
 * 인증된 사용자 정보
 * JWT 토큰에서 추출된 사용자 정보를 담는 Principal 객체
 */
@Getter
@Builder
@RequiredArgsConstructor
public class UserPrincipal {
    
    /**
     * 사용자 고유 ID
     */
    private final String userId;
    
    /**
     * 사용자명
     */
    private final String username;
    
    /**
     * 사용자 권한
     */
    private final String authority;
    
    /**
     * 사용자 ID 반환 (별칭)
     */
    public String getName() {
        return userId;
    }
    
    /**
     * 관리자 권한 여부 확인
     */
    public boolean isAdmin() {
        return "ADMIN".equals(authority);
    }
    
    /**
     * 일반 사용자 권한 여부 확인
     */
    public boolean isUser() {
        return "USER".equals(authority) || authority == null;
    }
}
```

<SwaggerConfig 예제>
```
/**
 * Swagger/OpenAPI 설정
 * AI Service API 문서화를 위한 설정
 */
@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(apiInfo())
                .addServersItem(new Server()
                        .url("http://localhost:8084")
                        .description("Local Development"))
                .addServersItem(new Server()
                        .url("{protocol}://{host}:{port}")
                        .description("Custom Server")
                        .variables(new io.swagger.v3.oas.models.servers.ServerVariables()
                                .addServerVariable("protocol", new io.swagger.v3.oas.models.servers.ServerVariable()
                                        ._default("http")
                                        .description("Protocol (http or https)")
                                        .addEnumItem("http")
                                        .addEnumItem("https"))
                                .addServerVariable("host", new io.swagger.v3.oas.models.servers.ServerVariable()
                                        ._default("localhost")
                                        .description("Server host"))
                                .addServerVariable("port", new io.swagger.v3.oas.models.servers.ServerVariable()
                                        ._default("8084")
                                        .description("Server port"))))
                .addSecurityItem(new SecurityRequirement().addList("Bearer Authentication"))
                .components(new Components()
                        .addSecuritySchemes("Bearer Authentication", createAPIKeyScheme()));
    }

    private Info apiInfo() {
        return new Info()
                .title("AI Service API")
                .description("AI 기반 시간별 상세 일정 생성 및 장소 추천 정보 API")
                .version("1.0.0")
                .contact(new Contact()
                        .name("TripGen Development Team")
                        .email("dev@tripgen.com"));
    }

    private SecurityScheme createAPIKeyScheme() {
        return new SecurityScheme()
                .type(SecurityScheme.Type.HTTP)
                .bearerFormat("JWT")
                .scheme("bearer");
    }
}
```
  