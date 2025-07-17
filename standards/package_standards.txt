패키지 구조 표준

레이어드 아키텍처 패키지 구조

├── {SERVICE}
│   ├── domain
│   ├── service
│   ├── controller
│   ├── dto
│   ├── repository
│   │   ├── jpa
│   │   └── entity
│   ├── config
└── common
        ├── dto
        ├── util
        ├── response
        └── exception

Package명: 
- com.{ORG}.{ROOT}.{SERVICE}
예) com.unicorn.lifesub.mysub, com.unicorn.lifesub.common

변수: 
- ORG: 회사 또는 조직명
- ROOT: Root Project 명
- SERVICE: 서비스명으로 Root Project의 서브 프로젝트임


예시

com.unicorn.lifesub.member
 ├── MemberApplication.java
 ├── controller
 │   └── MemberController.java
 ├── dto
 │   ├── LoginRequest.java
 │   ├── LogoutRequest.java
 │   └── LogoutResponse.java  
 ├── service
 │   ├── MemberService.java
 │   └── MemberServiceImpl.java
 ├── domain
 │   └── Member.java
 ├── repository  
 │   ├── entity
 │   │   └── MemberEntity.java
 │   └── jpa
 │       └── MemberRepository.java
 └── config
     ├── SecurityConfig.java
     ├── DataLoader.java
     ├── SwaggerConfig.java
     └── jwt
         ├── JwtAuthenticationFilter.java
         ├── JwtTokenProvider.java
         └── CustomUserDetailsService.java


클린 아키텍처 패키지 구조 

├── {SERVICE}-biz
│   ├── usecase
│   │   ├── in
│   │   ├── out
│   ├── service
│   └── domain
│   └── dto
├── {SERVICE}-infra
│   ├── controller
│   ├── dto
│   ├── gateway
│   │   ├── repository
│   │   └── entity
│   └── config    


Package명: 
- com.{ORG}.{ROOT}.{SERVICE}.biz
- com.{ORG}.{ROOT}.{SERVICE}.biz
예) com.unicorn.lifesub.mysub.biz, com.unicorn.lifesub.common

변수: 
- ORG: 회사 또는 조직명
- ROOT: Root Project 명
- SERVICE: 서비스명으로 Root Project의 서브 프로젝트임

예시


com.unicorn.lifesub.mysub
 ├── biz
 │   ├── dto
 │   │   ├── CategoryResponse.java
 │   │   ├── ServiceListResponse.java
 │   │   ├── MySubResponse.java
 │   │   ├── SubDetailResponse.java
 │   │   └── TotalFeeResponse.java
 │   ├── service
 │   │   ├── FeeLevel.java
 │   │   └── MySubscriptionService.java
 │   ├── usecase
 │   │   ├── in
 │   │   │   ├── CancelSubscriptionUseCase.java
 │   │   │   ├── CategoryUseCase.java
 │   │   │   ├── MySubscriptionsUseCase.java
 │   │   │   ├── SubscribeUseCase.java
 │   │   │   ├── SubscriptionDetailUseCase.java
 │   │   │   └── TotalFeeUseCase.java
 │   │   └── out 
 │   │       ├── MySubscriptionReader.java
 │   │       ├── MySubscriptionWriter.java
 │   │       └── SubscriptionReader.java
 │   └── domain
 │       ├── Category.java
 │       ├── MySubscription.java
 │       └── Subscription.java
 └── infra  
     ├── MySubApplication.java 
     ├── controller
     │   ├── CategoryController.java
     │   ├── MySubController.java
     │   └── ServiceController.java
     ├── config
     │   ├── DataLoader.java
     │   ├── SecurityConfig.java
     │   ├── SwaggerConfig.java
     │   └── jwt
     │       ├── JwtAuthenticationFilter.java
     │       └── JwtTokenProvider.java
     └── gateway
         ├── entity
         │   ├── CategoryEntity.java   
         │   ├── MySubscriptionEntity.java
         │   └── SubscriptionEntity.java
         ├── repository
         │   ├── CategoryJpaRepository.java
         │   ├── MySubscriptionJpaRepository.java
         │   └── SubscriptionJpaRepository.java  
         ├── MySubscriptionGateway.java
         └── SubscriptionGateway.java


---

common 모듈 패키지 구조

├── common
    ├── dto
    ├── entity
    ├── config
    ├── util
    └── exception


com.unicorn.lifesub.common
 ├── dto
 │   ├── ApiResponse.java
 │   ├── JwtTokenDTO.java
 │   ├── JwtTokenRefreshDTO.java
 │   └── JwtTokenVerifyDTO.java
 ├── config
 │   └── JpaConfig.java
 ├── entity
 │   └── BaseTimeEntity.java        
 ├── aop  
 │   └── LoggingAspect.java
 └── exception
     ├── ErrorCode.java
     ├── InfraException.java
     └── BusinessException.java


