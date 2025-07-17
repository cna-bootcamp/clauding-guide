// build.gradle
plugins {
    id 'org.springframework.boot' version '3.4.0' apply false
    id 'io.spring.dependency-management' version '1.1.4' apply false
    id 'java'
}

subprojects {
    apply plugin: 'java'
    apply plugin: 'org.springframework.boot'
    apply plugin: 'io.spring.dependency-management'
    
    group = 'com.telecom.cms'
    version = '0.0.1-SNAPSHOT'
    sourceCompatibility = '21'
    
    repositories {
        mavenCentral()
    }
    
    dependencies {
        // Spring Boot Starters
        implementation 'org.springframework.boot:spring-boot-starter'
        implementation 'org.springframework.boot:spring-boot-starter-web'
        implementation 'org.springframework.boot:spring-boot-starter-validation'
        implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
        implementation 'org.springframework.boot:spring-boot-starter-security'
        implementation 'org.springframework.boot:spring-boot-starter-actuator'
        
        // Database
        runtimeOnly 'org.postgresql:postgresql'
        
        // Swagger
        implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.4.0'
        
        // JWT
        implementation 'io.jsonwebtoken:jjwt-api:0.11.5'
        runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.11.5'
        runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.11.5'
        
        // Lombok
        compileOnly 'org.projectlombok:lombok'
        annotationProcessor 'org.projectlombok:lombok'
        
        // Test
        testImplementation 'org.springframework.boot:spring-boot-starter-test'
        testImplementation 'org.springframework.security:spring-security-test'
    }
    
    test {
        useJUnitPlatform()
    }
}

// File: cms/authentication/build.gradle
dependencies {
    implementation project(':common')
    
    // Azure AD B2C 인증 관련 (필요시)
    implementation 'com.azure:azure-security-keyvault-keys:4.6.3'
}
bootJar {
    archiveFileName = "authentication.jar"
}

// File: cms/authentication/build/resources/main/application.yml
server:
  port: ${SERVER_PORT:8080}
  servlet:
    context-path: /
  allowed-origins: ${ALLOWED_ORIGINS:http://localhost:3000}

spring:
  application:
    name: authentication-service
  datasource:
    url: jdbc:postgresql://${POSTGRES_HOST:localhost}:${POSTGRES_PORT:5432}/${POSTGRES_DB:authdb}
    username: ${POSTGRES_USER:postgres}
    password: ${POSTGRES_PASSWORD:postgres}
  jpa:
    hibernate:
      ddl-auto: ${JPA_DDL_AUTO:update}
    show-sql: ${JPA_SHOW_SQL:true}
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

jwt:
  secret-key: ${JWT_SECRET_KEY:defaultSecretKey}
  access-token-validity: ${JWT_ACCESS_TOKEN_VALIDITY:3600000}
  refresh-token-validity: ${JWT_REFRESH_TOKEN_VALIDITY:86400000}

springdoc:
  swagger-ui:
    path: /swagger-ui.html
    operations-sorter: method
  api-docs:
    path: /api-docs

logging:
  level:
    com.telecom.cms.authentication: ${LOG_LEVEL:DEBUG}
    org.springframework.security: ${LOG_LEVEL_SECURITY:INFO}


// File: cms/authentication/src/main/resources/application.yml
server:
  port: ${SERVER_PORT:8080}
  servlet:
    context-path: /
  allowed-origins: ${ALLOWED_ORIGINS:http://localhost:3000}

spring:
  application:
    name: authentication-service
  datasource:
    url: jdbc:postgresql://${POSTGRES_HOST:localhost}:${POSTGRES_PORT:5432}/${POSTGRES_DB:authdb}
    username: ${POSTGRES_USER:postgres}
    password: ${POSTGRES_PASSWORD:postgres}
  jpa:
    hibernate:
      ddl-auto: ${JPA_DDL_AUTO:update}
    show-sql: ${JPA_SHOW_SQL:true}
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

jwt:
  secret-key: ${JWT_SECRET_KEY:defaultSecretKey}
  access-token-validity: ${JWT_ACCESS_TOKEN_VALIDITY:3600000}
  refresh-token-validity: ${JWT_REFRESH_TOKEN_VALIDITY:86400000}

springdoc:
  swagger-ui:
    path: /swagger-ui.html
    operations-sorter: method
  api-docs:
    path: /api-docs

logging:
  level:
    com.telecom.cms.authentication: ${LOG_LEVEL:DEBUG}
    org.springframework.security: ${LOG_LEVEL_SECURITY:INFO}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/AuthenticationApplication.java
package com.telecom.cms.authentication;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 인증/인가 서비스의 메인 애플리케이션 클래스입니다.
 * 
 * @author cms-team
 * @version 1.0
 */
@SpringBootApplication
public class AuthenticationApplication {

    public static void main(String[] args) {
        SpringApplication.run(AuthenticationApplication.class, args);
    }
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/dto/LogoutRequest.java
package com.telecom.cms.authentication.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 로그아웃 요청 DTO 클래스입니다.
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "로그아웃 요청")
public class LogoutRequest {
    
    @Schema(description = "토큰", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    private String token;
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/dto/LoginRequest.java
package com.telecom.cms.authentication.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 로그인 요청 DTO 클래스입니다.
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "로그인 요청")
public class LoginRequest {
    
    @Schema(description = "사용자 ID", example = "admin")
    private String username;
    
    @Schema(description = "비밀번호", example = "password123")
    private String password;
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/dto/LoginResponse.java
package com.telecom.cms.authentication.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 로그인 응답 DTO 클래스입니다.
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "로그인 응답")
public class LoginResponse {
    
    @Schema(description = "인증 토큰", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    private String token;
    
    @Schema(description = "사용자 역할", example = "ADMIN")
    private String userRole;
    
    @Schema(description = "토큰 만료 시간", example = "2023-06-01T12:00:00")
    private LocalDateTime expiryTime;
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/dto/LogoutResponse.java
package com.telecom.cms.authentication.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 로그아웃 응답 DTO 클래스입니다.
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "로그아웃 응답")
public class LogoutResponse {
    
    @Schema(description = "결과 메시지", example = "로그아웃 되었습니다.")
    private String message;
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/repository/UserRepository.java
package com.telecom.cms.authentication.repository;

import com.telecom.cms.authentication.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * 사용자 정보 저장소 인터페이스입니다.
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * 사용자 ID로 사용자 정보를 조회합니다.
     *
     * @param username 사용자 ID
     * @return 사용자 정보
     */
    Optional<User> findByUsername(String username);
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/config/SecurityConfig.java
package com.telecom.cms.authentication.config;

import com.telecom.cms.authentication.service.TokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Spring Security 설정 클래스입니다.
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final TokenProvider tokenProvider;

    @Value("${server.allowed-origins}")
    private String allowedOrigins;

    /**
     * 보안 필터 체인을 구성합니다.
     *
     * @param http HttpSecurity 객체
     * @return 구성된 SecurityFilterChain
     * @throws Exception 보안 설정 중 오류 발생 시
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**", "/swagger-ui/**", "/swagger-ui.html", "/api-docs/**", "/actuator/**").permitAll()
                .anyRequest().authenticated()
            );
        
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // 콤마로 구분된 허용 오리진 목록을 파싱하고 각 항목의 앞뒤 공백 제거
        List<String> origins = Arrays.stream(allowedOrigins.split(","))
                .map(String::trim)
                .filter(origin -> !origin.isEmpty())  // 빈 문자열 필터링
                .collect(Collectors.toList());

        configuration.setAllowedOriginPatterns(origins); // 대신 setAllowedOriginPatterns 사용
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("authorization", "content-type", "x-auth-token"));
        configuration.setExposedHeaders(Arrays.asList("x-auth-token"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    /**
     * 비밀번호 인코더를 제공합니다.
     *
     * @return BCryptPasswordEncoder 인스턴스
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/config/SwaggerConfig.java
package com.telecom.cms.authentication.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Swagger 설정 클래스입니다.
 */
@Configuration
public class SwaggerConfig {

    /**
     * Swagger OpenAPI 구성을 제공합니다.
     *
     * @return OpenAPI 인스턴스
     */
    @Bean
    public OpenAPI openAPI() {
        String securitySchemeName = "bearerAuth";
        return new OpenAPI()
                .info(new Info()
                        .title("인증/인가 서비스 API")
                        .description("통신사 구독 서비스의 인증/인가 API 문서")
                        .version("v1.0.0"))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .components(new Components()
                        .addSecuritySchemes(securitySchemeName,
                                new SecurityScheme()
                                        .name(securitySchemeName)
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")));
    }
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/config/DataInitializationConfig.java
package com.telecom.cms.authentication.config;

import com.telecom.cms.authentication.domain.Role;
import com.telecom.cms.authentication.domain.User;
import com.telecom.cms.authentication.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * 샘플 사용자 데이터를 생성하는 설정 클래스입니다.
 */
@Slf4j
@Configuration
@RequiredArgsConstructor
public class DataInitializationConfig {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * 애플리케이션 시작 시 샘플 사용자 데이터를 생성합니다.
     *
     * @return CommandLineRunner 인스턴스
     */
    @Bean
    public CommandLineRunner initializeData() {
        return args -> {
            log.info("Initializing sample user data...");

            // 일반 사용자 생성 (user01 ~ user05)
            for (int i = 1; i <= 5; i++) {
                String username = String.format("user%02d", i);
                createUserIfNotExists(username, "P@ssw0rd$", Role.USER);
            }

            // 관리자 생성 (admin01)
            createUserIfNotExists("admin01", "P@ssw0rd$", Role.ADMIN);

            log.info("Sample user data initialization completed.");
        };
    }

    /**
     * 사용자가 존재하지 않는 경우 새로 생성합니다.
     *
     * @param username 사용자 ID
     * @param password 비밀번호
     * @param role 역할
     */
    private void createUserIfNotExists(String username, String password, Role role) {
        if (!userRepository.findByUsername(username).isPresent()) {
            User user = new User(username, passwordEncoder.encode(password));
            user.addRole(role);

            if (role == Role.ADMIN) {
                // 관리자는 USER 역할도 가지도록 함
                user.addRole(Role.USER);
            }

            userRepository.save(user);
            log.info("Created user: {}, role: {}", username, role);
        } else {
            log.info("User already exists: {}", username);
        }
    }
}

// File: cms/authentication/src/main/java/com/telecom/cms/authentication/controller/AuthController.java
package com.telecom.cms.authentication.controller;

import com.telecom.cms.authentication.dto.LoginRequest;
import com.telecom.cms.authentication.dto.LoginResponse;
import com.telecom.cms.authentication.dto.LogoutRequest;
import com.telecom.cms.authentication.dto.LogoutResponse;
import com.telecom.cms.authentication.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 인증 관련 API 컨트롤러입니다.
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@Tag(name = "인증 API", description = "로그인 및 로그아웃 API")
public class AuthController {

    private final AuthService authService;
    
    /**
     * 사용자 로그인을 처리합니다.
     *
     * @param request 로그인 요청 정보
     * @return 로그인 응답 정보 (토큰 포함)
     */
    @PostMapping("/login")
    @Operation(summary = "사용자 로그인", description = "사용자 ID와 비밀번호로 로그인합니다.")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }
    
    /**
     * 사용자 로그아웃을 처리합니다.
     *
     * @param request 로그아웃 요청 정보
     * @return 로그아웃 응답 정보
     */
    @PostMapping("/logout")
    @Operation(summary = "사용자 로그아웃", description = "사용자 토큰을 무효화하여 로그아웃합니다.")
    public ResponseEntity<LogoutResponse> logout(@RequestBody LogoutRequest request) {
        LogoutResponse response = authService.logout(request);
        return ResponseEntity.ok(response);
    }
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/service/AuthService.java
package com.telecom.cms.authentication.service;

import com.telecom.cms.authentication.dto.LoginRequest;
import com.telecom.cms.authentication.dto.LoginResponse;
import com.telecom.cms.authentication.dto.LogoutRequest;
import com.telecom.cms.authentication.dto.LogoutResponse;

/**
 * 인증 관련 서비스 인터페이스입니다.
 */
public interface AuthService {
    
    /**
     * 사용자 로그인을 처리합니다.
     *
     * @param request 로그인 요청 정보
     * @return 로그인 응답 정보 (토큰 포함)
     */
    LoginResponse login(LoginRequest request);
    
    /**
     * 사용자 로그아웃을 처리합니다.
     *
     * @param request 로그아웃 요청 정보
     * @return 로그아웃 응답 정보
     */
    LogoutResponse logout(LogoutRequest request);
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/service/TokenProvider.java
package com.telecom.cms.authentication.service;

import com.telecom.cms.authentication.domain.User;
import io.jsonwebtoken.*;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * JWT 토큰 생성 및 검증을 담당하는 클래스입니다.
 */
@Component
public class TokenProvider {

    @Getter
    @Value("${jwt.access-token-validity}")
    private long tokenValidityInMilliseconds;
    
    private final SecretKey key;
    private final JwtParser jwtParser;
    private final Set<String> blacklistedTokens = Collections.newSetFromMap(new ConcurrentHashMap<>());
    
    public TokenProvider(@Value("${jwt.secret-key}") String secretKey) {
        this.key = new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), SignatureAlgorithm.HS256.getJcaName());
        this.jwtParser = Jwts.parserBuilder().setSigningKey(key).build();
    }
    
    /**
     * 사용자 정보를 기반으로 JWT 토큰을 생성합니다.
     *
     * @param user 사용자 정보
     * @return 생성된 JWT 토큰
     */
    public String createToken(User user) {
        Date now = new Date();
        Date validity = new Date(now.getTime() + tokenValidityInMilliseconds);
        
        return Jwts.builder()
                .setSubject(user.getUsername())
                .claim("roles", user.getRoles())
                .setIssuedAt(now)
                .setExpiration(validity)
                .signWith(key)
                .compact();
    }
    
    /**
     * JWT 토큰의 유효성을 검사합니다.
     *
     * @param token 검증할 JWT 토큰
     * @return 토큰 유효 여부
     */
    public boolean validateToken(String token) {
        if (blacklistedTokens.contains(token)) {
            return false;
        }
        
        try {
            jwtParser.parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
    
    /**
     * JWT 토큰으로부터 사용자 ID를 추출합니다.
     *
     * @param token JWT 토큰
     * @return 사용자 ID
     */
    public String getUsernameFromToken(String token) {
        return jwtParser.parseClaimsJws(token).getBody().getSubject();
    }
    
    /**
     * 토큰을 무효화합니다(로그아웃).
     *
     * @param token 무효화할 토큰
     */
    public void invalidateToken(String token) {
        blacklistedTokens.add(token);
    }
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/service/AuthServiceImpl.java
package com.telecom.cms.authentication.service;

import com.telecom.cms.authentication.domain.User;
import com.telecom.cms.authentication.dto.LoginRequest;
import com.telecom.cms.authentication.dto.LoginResponse;
import com.telecom.cms.authentication.dto.LogoutRequest;
import com.telecom.cms.authentication.dto.LogoutResponse;
import com.telecom.cms.authentication.exception.InvalidCredentialsException;
import com.telecom.cms.authentication.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.stream.Collectors;

/**
 * 인증 관련 서비스 구현 클래스입니다.
 */
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenProvider tokenProvider;
    
    /**
     * 사용자 로그인을 처리합니다.
     *
     * @param request 로그인 요청 정보
     * @return 로그인 응답 정보 (토큰 포함)
     * @throws InvalidCredentialsException 사용자 인증 실패 시
     */
    @Override
    @Transactional
    public LoginResponse login(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new InvalidCredentialsException("사용자 ID 또는 비밀번호가 잘못되었습니다."));
        
        validateCredentials(user, request.getPassword());
        
        String token = tokenProvider.createToken(user);
        String userRole = user.getRoles().stream()
                .map(Enum::name)
                .collect(Collectors.joining(","));
        
        LocalDateTime expiryTime = LocalDateTime.now().plusSeconds(
                tokenProvider.getTokenValidityInMilliseconds() / 1000);
        
        return new LoginResponse(token, userRole, expiryTime);
    }
    
    /**
     * 사용자 로그아웃을 처리합니다.
     *
     * @param request 로그아웃 요청 정보
     * @return 로그아웃 응답 정보
     */
    @Override
    @Transactional
    public LogoutResponse logout(LogoutRequest request) {
        tokenProvider.invalidateToken(request.getToken());
        return new LogoutResponse("로그아웃 되었습니다.");
    }
    
    /**
     * 사용자 자격 증명을 검증합니다.
     *
     * @param user 사용자 정보
     * @param password 입력된 비밀번호
     * @throws InvalidCredentialsException 비밀번호가 일치하지 않을 때
     */
    private void validateCredentials(User user, String password) {
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new InvalidCredentialsException("사용자 ID 또는 비밀번호가 잘못되었습니다.");
        }
    }
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/domain/User.java
package com.telecom.cms.authentication.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

/**
 * 사용자 정보를 관리하는 엔티티 클래스입니다.
 */
@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String username;
    
    @Column(nullable = false)
    private String password;
    
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Enumerated(EnumType.STRING)
    @Column(name = "role")
    private Set<Role> roles = new HashSet<>();
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    /**
     * 사용자 객체를 생성합니다.
     *
     * @param username 사용자 ID
     * @param password 암호화된 비밀번호
     */
    public User(String username, String password) {
        this.username = username;
        this.password = password;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 사용자 역할을 추가합니다.
     *
     * @param role 추가할 역할
     */
    public void addRole(Role role) {
        this.roles.add(role);
        this.updatedAt = LocalDateTime.now();
    }
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/domain/Role.java
package com.telecom.cms.authentication.domain;

/**
 * 사용자의 역할을 정의하는 열거형입니다.
 */
public enum Role {
    USER,
    ADMIN
}


// File: cms/authentication/src/main/java/com/telecom/cms/authentication/exception/InvalidCredentialsException.java
package com.telecom.cms.authentication.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * 사용자 인증 실패 시 발생하는 예외 클래스입니다.
 */
@ResponseStatus(HttpStatus.UNAUTHORIZED)
public class InvalidCredentialsException extends RuntimeException {
    
    public InvalidCredentialsException(String message) {
        super(message);
    }
}



