# 여행 일정 생성 서비스 - 패키지 구조도

## 프로젝트 구조 (멀티 모듈)

```
tripgen/
├── tripgen-common/                          # 공통 모듈
│   └── src/
│       └── main/
│           └── java/
│               └── com/
│                   └── unicorn/
│                       └── tripgen/
│                           └── common/
│                               ├── dto/
│                               │   ├── ApiResponse.java
│                               │   ├── PageRequest.java
│                               │   ├── PageResponse.java
│                               │   ├── SortDirection.java
│                               │   └── ErrorResponse.java
│                               ├── exception/
│                               │   ├── BusinessException.java
│                               │   ├── ResourceNotFoundException.java
│                               │   ├── ValidationException.java
│                               │   ├── ExternalApiException.java
│                               │   └── ConcurrentModificationException.java
│                               ├── util/
│                               │   ├── DateTimeUtils.java
│                               │   ├── StringUtils.java
│                               │   ├── JsonUtils.java
│                               │   └── ValidationUtils.java
│                               ├── config/
│                               │   ├── BaseConfig.java
│                               │   ├── CacheConfig.java
│                               │   ├── RestTemplateConfig.java
│                               │   └── ObjectMapperConfig.java
│                               ├── constant/
│                               │   ├── CacheKeys.java
│                               │   ├── ErrorCodes.java
│                               │   └── ApiConstants.java
│                               └── interfaces/
│                                   ├── Auditable.java
│                                   ├── Cacheable.java
│                                   ├── Identifiable.java
│                                   └── Versionable.java
│
├── tripgen-profile/                         # 프로파일 서비스 (레이어드 아키텍처)
│   └── src/
│       └── main/
│           └── java/
│               └── com/
│                   └── unicorn/
│                       └── tripgen/
│                           └── profile/
│                               ├── controller/
│                               │   ├── MemberController.java
│                               │   ├── TripController.java
│                               │   └── TransportController.java
│                               ├── service/
│                               │   ├── MemberService.java
│                               │   ├── MemberServiceImpl.java
│                               │   ├── TripService.java
│                               │   ├── TripServiceImpl.java
│                               │   ├── TransportService.java
│                               │   ├── TransportServiceImpl.java
│                               │   └── LocationService.java
│                               ├── repository/
│                               │   ├── MemberRepository.java
│                               │   ├── TripRepository.java
│                               │   └── TransportSettingRepository.java
│                               ├── domain/
│                               │   ├── Member.java
│                               │   ├── Trip.java
│                               │   ├── TransportSetting.java
│                               │   ├── Location.java
│                               │   ├── Accommodation.java
│                               │   ├── HealthStatus.java
│                               │   ├── PreferenceType.java
│                               │   └── TransportType.java
│                               ├── dto/
│                               │   ├── request/
│                               │   │   ├── MemberRequest.java
│                               │   │   ├── TripRequest.java
│                               │   │   ├── LocationRequest.java
│                               │   │   ├── AccommodationRequest.java
│                               │   │   └── TransportSettingRequest.java
│                               │   ├── response/
│                               │   │   ├── MemberResponse.java
│                               │   │   ├── TripResponse.java
│                               │   │   ├── LocationResponse.java
│                               │   │   ├── AccommodationResponse.java
│                               │   │   └── TransportSettingResponse.java
│                               │   └── internal/
│                               │       ├── MemberDto.java
│                               │       ├── TripDto.java
│                               │       └── TransportSettingDto.java
│                               └── mapper/
│                                   ├── MemberMapper.java
│                                   ├── TripMapper.java
│                                   └── TransportSettingMapper.java
│
├── tripgen-location/                        # 장소 서비스 (클린 아키텍처)
│   ├── tripgen-location-biz/               # 비즈니스 로직 모듈
│   │   └── src/
│   │       └── main/
│   │           └── java/
│   │               └── com/
│   │                   └── unicorn/
│   │                       └── tripgen/
│   │                           └── location/
│   │                               ├── domain/
│   │                               │   ├── Place.java
│   │                               │   ├── Location.java
│   │                               │   ├── PlaceDetails.java
│   │                               │   ├── Contact.java
│   │                               │   ├── BusinessHours.java
│   │                               │   ├── TimeSlot.java
│   │                               │   ├── Review.java
│   │                               │   ├── Photo.java
│   │                               │   ├── PopularTime.java
│   │                               │   ├── RegionInfo.java
│   │                               │   ├── PlaceCategory.java
│   │                               │   ├── PriceLevel.java
│   │                               │   ├── TransportMode.java
│   │                               │   └── Season.java
│   │                               ├── usecase/
│   │                               │   ├── SearchNearbyPlacesUseCase.java
│   │                               │   ├── GetPlaceDetailsUseCase.java
│   │                               │   ├── ValidatePlaceInfoUseCase.java
│   │                               │   ├── GetRegionalRecommendationsUseCase.java
│   │                               │   ├── SearchMultilingualPlacesUseCase.java
│   │                               │   ├── PlaceRepository.java
│   │                               │   ├── PlaceSearchPort.java
│   │                               │   ├── PlaceValidationPort.java
│   │                               │   ├── TranslationPort.java
│   │                               │   └── RegionDataPort.java
│   │                               ├── service/
│   │                               │   ├── PlaceSearchService.java
│   │                               │   ├── PlaceDetailService.java
│   │                               │   ├── PlaceValidationService.java
│   │                               │   ├── RegionalRecommendationService.java
│   │                               │   ├── PlaceCacheService.java
│   │                               │   ├── ReviewAnalyzer.java
│   │                               │   └── RecommendationEngine.java
│   │                               └── dto/
│   │                                   ├── NearbySearchRequest.java
│   │                                   ├── PlaceSummaryDto.java
│   │                                   ├── PlaceDetailsDto.java
│   │                                   ├── LocationDto.java
│   │                                   ├── ValidationRequest.java
│   │                                   ├── ValidationResponse.java
│   │                                   ├── RegionalRecommendationRequest.java
│   │                                   ├── RecommendationResponse.java
│   │                                   ├── MultilingualSearchRequest.java
│   │                                   ├── MultilingualSearchResponse.java
│   │                                   ├── SearchCriteria.java
│   │                                   ├── SortCriteria.java
│   │                                   ├── TimeOfDay.java
│   │                                   ├── Weather.java
│   │                                   └── DataSource.java
│   │
│   └── tripgen-location-infra/             # 인프라 모듈
│       └── src/
│           └── main/
│               └── java/
│                   └── com/
│                       └── unicorn/
│                           └── tripgen/
│                               └── location/
│                                   ├── controller/
│                                   │   ├── LocationController.java
│                                   │   └── LocationControllerAdvice.java
│                                   ├── gateway/
│                                   │   ├── McpPlaceSearchAdapter.java
│                                   │   ├── McpPlaceValidationAdapter.java
│                                   │   ├── McpTranslationAdapter.java
│                                   │   ├── McpRegionDataAdapter.java
│                                   │   ├── PlaceRepositoryImpl.java
│                                   │   ├── McpClient.java
│                                   │   ├── CircuitBreaker.java
│                                   │   └── CircuitBreakerState.java
│                                   ├── entity/
│                                   │   ├── PlaceEntity.java
│                                   │   ├── PlaceDetailsEntity.java
│                                   │   └── PlaceJpaRepository.java
│                                   └── config/
│                                       ├── LocationServiceConfig.java
│                                       ├── McpApiConfig.java
│                                       └── CacheConfiguration.java
│
└── tripgen-itinerary/                      # 일정 서비스 (클린 아키텍처 + CQRS + Saga)
    ├── tripgen-itinerary-biz/              # 비즈니스 로직 모듈
    │   └── src/
    │       └── main/
    │           └── java/
    │               └── com/
    │                   └── unicorn/
    │                       └── tripgen/
    │                           └── itinerary/
    │                               ├── domain/
    │                               │   ├── Itinerary.java
    │                               │   ├── DailyActivity.java
    │                               │   ├── Coordinate.java
    │                               │   ├── Attachment.java
    │                               │   ├── PhotoAttachment.java
    │                               │   ├── MemoAttachment.java
    │                               │   ├── Route.java
    │                               │   ├── RouteStep.java
    │                               │   ├── ItineraryStatus.java
    │                               │   ├── PlaceCategory.java
    │                               │   ├── AttachmentType.java
    │                               │   ├── TransportType.java
    │                               │   ├── ItineraryPreferences.java
    │                               │   ├── MealTimes.java
    │                               │   ├── DomainEvent.java
    │                               │   ├── ItineraryGeneratedEvent.java
    │                               │   └── ActivityAddedEvent.java
    │                               ├── usecase/
    │                               │   ├── command/
    │                               │   │   ├── GenerateItineraryUseCase.java
    │                               │   │   ├── UpdateItineraryUseCase.java
    │                               │   │   ├── DeleteItineraryUseCase.java
    │                               │   │   ├── AddActivityUseCase.java
    │                               │   │   ├── AttachPhotoUseCase.java
    │                               │   │   ├── CreateMemoUseCase.java
    │                               │   │   ├── GenerateItineraryCommand.java
    │                               │   │   ├── UpdateItineraryCommand.java
    │                               │   │   ├── DeleteItineraryCommand.java
    │                               │   │   ├── AddActivityCommand.java
    │                               │   │   ├── AttachPhotoCommand.java
    │                               │   │   ├── CreateMemoCommand.java
    │                               │   │   ├── GenerateItineraryResult.java
    │                               │   │   ├── UpdateItineraryResult.java
    │                               │   │   ├── AddActivityResult.java
    │                               │   │   ├── AttachPhotoResult.java
    │                               │   │   └── CreateMemoResult.java
    │                               │   ├── query/
    │                               │   │   ├── GetItineraryUseCase.java
    │                               │   │   ├── GetItinerariesUseCase.java
    │                               │   │   ├── GetPlaceDetailsUseCase.java
    │                               │   │   ├── GetRouteDetailsUseCase.java
    │                               │   │   ├── GetAttachmentsUseCase.java
    │                               │   │   ├── GetItineraryQuery.java
    │                               │   │   ├── GetItinerariesQuery.java
    │                               │   │   ├── GetPlaceDetailsQuery.java
    │                               │   │   ├── GetRouteDetailsQuery.java
    │                               │   │   └── GetAttachmentsQuery.java
    │                               │   └── port/
    │                               │       ├── ItineraryCommandPort.java
    │                               │       ├── ItineraryQueryPort.java
    │                               │       ├── ItineraryRepository.java
    │                               │       ├── ActivityRepository.java
    │                               │       ├── AttachmentRepository.java
    │                               │       ├── RouteRepository.java
    │                               │       ├── ProfileServicePort.java
    │                               │       ├── LocationServicePort.java
    │                               │       ├── AIServicePort.java
    │                               │       ├── FileStoragePort.java
    │                               │       ├── EventPublisher.java
    │                               │       └── CachePort.java
    │                               ├── service/
    │                               │   ├── GenerateItineraryService.java
    │                               │   ├── UpdateItineraryService.java
    │                               │   ├── AttachmentService.java
    │                               │   ├── ItineraryQueryService.java
    │                               │   ├── PlaceQueryService.java
    │                               │   ├── AIItineraryGenerationService.java
    │                               │   ├── RouteCalculationService.java
    │                               │   ├── JobQueueService.java
    │                               │   └── ItinerarySagaOrchestrator.java
    │                               └── dto/
    │                                   ├── ItineraryGenerateRequest.java
    │                                   ├── ItineraryUpdateRequest.java
    │                                   ├── PlaceRequest.java
    │                                   ├── MemoRequest.java
    │                                   ├── ItineraryResponse.java
    │                                   ├── PlaceResponse.java
    │                                   ├── PlaceDetailResponse.java
    │                                   ├── AttachmentResponse.java
    │                                   ├── PhotoAttachmentResponse.java
    │                                   ├── MemoAttachmentResponse.java
    │                                   ├── CoordinateDto.java
    │                                   ├── PreferencesDto.java
    │                                   ├── MealTimesDto.java
    │                                   ├── TripProfile.java
    │                                   ├── MemberPreference.java
    │                                   ├── PlaceInfo.java
    │                                   ├── AIItineraryRequest.java
    │                                   └── AIItineraryResponse.java
    │
    └── tripgen-itinerary-infra/           # 인프라 모듈
        └── src/
            └── main/
                └── java/
                    └── com/
                        └── unicorn/
                            └── tripgen/
                                └── itinerary/
                                    ├── controller/
                                    │   ├── ItineraryController.java
                                    │   ├── PlaceController.java
                                    │   ├── RouteController.java
                                    │   └── AttachmentController.java
                                    ├── gateway/
                                    │   ├── ProfileServiceClient.java
                                    │   ├── LocationServiceClient.java
                                    │   ├── MCPGateway.java
                                    │   └── S3StorageAdapter.java
                                    ├── repository/
                                    │   ├── ItineraryEntity.java
                                    │   ├── ActivityEntity.java
                                    │   ├── AttachmentEntity.java
                                    │   ├── RouteEntity.java
                                    │   ├── ItineraryJpaRepository.java
                                    │   ├── ActivityJpaRepository.java
                                    │   ├── AttachmentJpaRepository.java
                                    │   ├── RouteJpaRepository.java
                                    │   ├── ItineraryRepositoryAdapter.java
                                    │   ├── ActivityRepositoryAdapter.java
                                    │   ├── AttachmentRepositoryAdapter.java
                                    │   ├── ItineraryMapper.java
                                    │   ├── ActivityMapper.java
                                    │   └── AttachmentMapper.java
                                    ├── config/
                                    │   ├── ItineraryServiceConfig.java
                                    │   ├── AsyncConfig.java
                                    │   ├── CacheConfig.java
                                    │   ├── CircuitBreakerConfig.java
                                    │   ├── SecurityConfig.java
                                    │   ├── JobQueueConfig.java
                                    │   └── SagaConfig.java
                                    └── infrastructure/
                                        ├── RedisEventPublisher.java
                                        ├── RedisCacheAdapter.java
                                        ├── JobQueueImpl.java
                                        └── SagaRepositoryImpl.java
```

## 프로젝트 빌드 구조

### Root Project (build.gradle)
```
tripgen/
├── build.gradle                # Root build configuration
├── settings.gradle             # Multi-module settings
├── gradle.properties           # Gradle properties
└── gradlew                     # Gradle wrapper
```

### Module Dependencies
```
tripgen-profile → tripgen-common
tripgen-location-biz → tripgen-common
tripgen-location-infra → tripgen-location-biz, tripgen-common
tripgen-itinerary-biz → tripgen-common
tripgen-itinerary-infra → tripgen-itinerary-biz, tripgen-common
```

## 아키텍처 패턴별 구조 특징

### 1. 프로파일 서비스 (레이어드 아키텍처)
- **Controller**: REST API 엔드포인트
- **Service**: 비즈니스 로직 (인터페이스 + 구현체)
- **Repository**: 데이터 접근 계층
- **Domain**: 엔티티 및 Enum
- **DTO**: 요청/응답/내부 전송 객체
- **Mapper**: 엔티티-DTO 변환

### 2. 장소 서비스 (클린 아키텍처)
- **Domain**: 순수 비즈니스 엔티티
- **UseCase**: 비즈니스 유스케이스 (인터페이스)
- **Service**: UseCase 구현체
- **Port**: 외부 의존성 인터페이스
- **Gateway**: Port 구현체 (어댑터)
- **Controller**: REST API 엔드포인트

### 3. 일정 서비스 (클린 아키텍처 + CQRS + Saga)
- **Domain**: 도메인 모델 및 이벤트
- **Command/Query**: CQRS 패턴 유스케이스
- **Service**: 비즈니스 로직 구현
- **Saga**: 분산 트랜잭션 관리
- **Job Queue**: 비동기 작업 처리
- **Infrastructure**: 외부 시스템 어댑터