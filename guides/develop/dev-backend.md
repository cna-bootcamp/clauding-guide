# 백엔드 개발 가이드 

[요청사항]  
- <개발원칙>을 준용하여 개발
- <개발순서>에 따라 개발
- [결과파일] 안내에 따라 파일 작성 

[가이드]
<개발원칙>
- 'HighLevel아키텍처정의서 > 6.1.1 백엔드 기술스택'과 일치해야 함
- 'HighLevel아키텍처정의서 > 6.2 서비스별 개발 아키텍처 패턴'과 일치해야 함
- '개발주석표준'에 맞게 주석 작성
- API개발은 'API설계서'를 준용 
- '백엔드패키지구조도'와 동일하게 패키지와 클래스 구성  
- '외부시퀀스설계서'와 '내부시퀀스설계서'와 일치되도록 개발 
- 백킹서비스 연동은 '데이터베이스설치결과서', '캐시설치결과서', 'MQ설치결과서'를 기반으로 개발  
- 빌드도구는 Gradle 사용   
- 설정 Manifest(src/main/resources/application*.yml)의 각 항목값은 하드코딩하지 않고 환경변수 처리 
<개발순서>
- 준비:
  - 참고자료 분석 및 이해 
- 실행:  
  - common 모듈 개발  
  - 각 서비스별로 '<병렬처리>'가이드대로 동시 개발
    - 설정 Manifest(application.yml) 작성 
      - 하드코딩하지 않고 환경변수 사용
      - 특히, 데이터베이스, MQ 등의 연결 정보는 반드시 환경변수로 변환해야 함     
      - 민감한 정보의 디퐅트값은 생략하거나 간략한 값으로 지정
      - 개발모드(dev)와 운영모드(prod)로 나누어서 작성  
      - 개발모드의 DDL_AUTO값은 update로 함 
      - JWT Secret Key는 모든 서비스가 동일해야 함 
      - '[JWT,CORS,Actuaotr,OpenAPI Documentation,Loggings 표준]'을 준수하여 설정 
    - '<Build.gradle 구성 최적화>' 가이드대로 최상위와 각 서비스별 build.gradle 작성  
    - SecurityConfig 클래스 작성: '<SecurityConfig 예제>' 참조 
    - JWT 인증 처리 클래스 작성: '<JWT 인증처리 예제>' 참조 
    - Swagger Config 클래스 작성: '<SwaggerConfig 예제>' 참조 
    - 테스트 코드 작성은 하지 않음     
  - 개발 결과 설명: dev-backend.md
- 검토:
  - 컴파일 및 오류 수정:
    - '<병렬처리>'에 따라 동시 수행  
    - 컴파일 방법: {프로젝트 루트}/gradlew {service-name}:compileJava
  - 컴파일까지만 하고 서버 실행은 하지 않음 
<병렬처리>
- **의존성 분석 선행**: 병렬 처리 전 반드시 의존성 파악
- **순차 처리 필요시**: 무리한 병렬화보다는 안전한 순차 처리
- **검증 단계 필수**: 병렬 처리 후 통합 검증

<Build.gradle 구성 최적화>
- **중앙 버전 관리**: 루트 build.gradle의 `ext` 블록에서 모든 외부 라이브러리 버전 통일 관리
- **Spring Boot BOM 활용**: Spring Boot/Cloud에서 관리하는 라이브러리는 버전 명시 불필요 (자동 호환성 보장)
- **Common 모듈 설정**: `java-library` + Spring Boot 플러그인 조합, `bootJar` 비활성화로 일반 jar 생성
- **서비스별 최적화**: 공통 의존성(API 문서화, 테스트 등)은 루트에서 일괄 적용
- **JWT 버전 통일**: 라이브러리 버전 변경시 API 호환성 확인 필수 (`parserBuilder()` → `parser()`)
- **dependency-management 적용**: 모든 서브프로젝트에 Spring BOM 적용으로 버전 충돌 방지

[참고자료]
- 유저스토리
- HighLevel아키텍처정의서
- API설계서
- 외부시퀀스설계서
- 내부시퀀스설계서
- 클래스설계서
- 백엔드팩키지구조도
- 데이터베이스설치결과서
- 캐시설치결과서
- MQ설치결과서
- 테스트코드표준
  
[결과파일]
- develop/dev/dev-backend.md

---

[JWT, CORS, Actuaotr,OpenAPI Documentation,Loggings 표준]
```
# JWT 
security:
  jwt:
    secret: ${JWT_SECRET:}
    access-token-expiration: ${JWT_ACCESS_TOKEN_EXPIRATION:3600}  
    refresh-token-expiration: ${JWT_REFRESH_TOKEN_EXPIRATION:604800} 

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
    db:
      enabled: true
    redis:
      enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      service: {서비스명}

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

[예제]
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
                           @Value("${jwt.token-validity-in-seconds:3600}") long tokenValidityInSeconds) {
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

3) UserPrincipal
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
