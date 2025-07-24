openapi: 3.0.3
info:
  title: 여행 일정 서비스 API
  description: AI 기반 일정 생성, 장소 정보 관리, 경로 계산 및 사진/메모 첨부 기능을 제공하는 RESTful API
  version: 1.0.0
  contact:
    name: TripGen API Support
    email: api@tripgen.com
servers:
  - url: http://localhost:8082
    description: 개발 서버
  - url: https://api.tripgen.com/itinerary
    description: 운영 서버
tags:
  - name: itineraries
    description: 일정 생성 및 관리
  - name: places
    description: 장소 상세 정보 관리
  - name: routes
    description: 이동 경로 및 시간 계산
  - name: attachments
    description: 사진 및 메모 관리

paths:
  /api/itinerary/trips/{tripId}/itineraries:
    get:
      x-user-story: RQ-ITIN-001
      x-controller: ItineraryController
      tags:
        - itineraries
      summary: 여행 일정 목록 조회
      description: 특정 여행의 모든 일정을 조회합니다
      operationId: getItineraries
      parameters:
        - $ref: '#/components/parameters/TripId'
        - name: date
          in: query
          description: 특정 날짜의 일정만 조회
          schema:
            type: string
            format: date
            example: "2024-07-02"
      responses:
        '200':
          description: 성공적으로 조회됨
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Itinerary'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
    
    post:
      x-user-story: RQ-ITIN-001
      x-controller: ItineraryController
      tags:
        - itineraries
      summary: AI 기반 일정 자동 생성
      description: 여행 정보와 멤버 특성을 고려하여 일일 상세 일정을 자동으로 생성합니다
      operationId: generateItinerary
      parameters:
        - $ref: '#/components/parameters/TripId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ItineraryGenerateRequest'
            example:
              date: "2024-07-02"
              additionalRequirements: "오후 3시쯤 카페에서 휴식 시간을 갖고 싶어요. 가급적 대중교통으로 이동 가능한 곳으로 추천해주세요. 매운 음식은 피해주세요."
              preferences:
                startTime: "09:00"
                endTime: "21:00"
                includeBreaks: true
                mealTimes:
                  breakfast: "08:00"
                  lunch: "12:00"
                  dinner: "18:00"
      responses:
        '201':
          description: 일정이 성공적으로 생성됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Itinerary'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'

  /api/itinerary/trips/{tripId}/itineraries/{itineraryId}:
    get:
      x-user-story: RQ-ITIN-001
      x-controller: ItineraryController
      tags:
        - itineraries
      summary: 특정 일정 상세 조회
      description: ID로 특정 일정의 상세 정보를 조회합니다
      operationId: getItineraryById
      parameters:
        - $ref: '#/components/parameters/TripId'
        - $ref: '#/components/parameters/ItineraryId'
      responses:
        '200':
          description: 성공적으로 조회됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Itinerary'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
    
    put:
      x-user-story: RQ-ITIN-001
      x-controller: ItineraryController
      tags:
        - itineraries
      summary: 일정 수정
      description: 생성된 일정을 수동으로 편집합니다
      operationId: updateItinerary
      parameters:
        - $ref: '#/components/parameters/TripId'
        - $ref: '#/components/parameters/ItineraryId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ItineraryUpdateRequest'
      responses:
        '200':
          description: 일정이 성공적으로 수정됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Itinerary'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
    
    delete:
      x-user-story: RQ-ITIN-001
      x-controller: ItineraryController
      tags:
        - itineraries
      summary: 일정 삭제
      description: 특정 일정을 삭제합니다
      operationId: deleteItinerary
      parameters:
        - $ref: '#/components/parameters/TripId'
        - $ref: '#/components/parameters/ItineraryId'
      responses:
        '204':
          description: 일정이 성공적으로 삭제됨
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'

  /api/itinerary/trips/{tripId}/itineraries/{itineraryId}/places:
    get:
      x-user-story: RQ-ITIN-002
      x-controller: PlaceController
      tags:
        - places
      summary: 일정 내 장소 목록 조회
      description: 특정 일정에 포함된 모든 장소를 조회합니다
      operationId: getPlacesInItinerary
      parameters:
        - $ref: '#/components/parameters/TripId'
        - $ref: '#/components/parameters/ItineraryId'
      responses:
        '200':
          description: 성공적으로 조회됨
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Place'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
    
    post:
      x-user-story: RQ-ITIN-002
      x-controller: PlaceController
      tags:
        - places
      summary: 일정에 장소 추가
      description: 일정에 새로운 장소를 추가합니다
      operationId: addPlaceToItinerary
      parameters:
        - $ref: '#/components/parameters/TripId'
        - $ref: '#/components/parameters/ItineraryId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/PlaceRequest'
      responses:
        '201':
          description: 장소가 성공적으로 추가됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Place'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'

  /api/itinerary/places/{placeId}:
    get:
      x-user-story: RQ-ITIN-002
      x-controller: PlaceController
      tags:
        - places
      summary: 장소 상세 정보 조회
      description: MCP를 통해 검증된 최신 장소 정보를 조회합니다
      operationId: getPlaceById
      parameters:
        - $ref: '#/components/parameters/PlaceId'
        - name: refresh
          in: query
          description: 실시간 정보 갱신 여부
          schema:
            type: boolean
            default: false
      responses:
        '200':
          description: 성공적으로 조회됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PlaceDetail'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
    
    put:
      x-user-story: RQ-ITIN-002
      x-controller: PlaceController
      tags:
        - places
      summary: 장소 정보 수정
      description: 장소 정보를 수정합니다
      operationId: updatePlace
      parameters:
        - $ref: '#/components/parameters/PlaceId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/PlaceUpdateRequest'
      responses:
        '200':
          description: 장소 정보가 성공적으로 수정됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Place'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
    
    delete:
      x-user-story: RQ-ITIN-002
      x-controller: PlaceController
      tags:
        - places
      summary: 장소 삭제
      description: 일정에서 특정 장소를 삭제합니다
      operationId: deletePlace
      parameters:
        - $ref: '#/components/parameters/PlaceId'
      responses:
        '204':
          description: 장소가 성공적으로 삭제됨
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'

  /api/itinerary/trips/{tripId}/routes/calculate:
    post:
      x-user-story: RQ-ITIN-003
      x-controller: RouteController
      tags:
        - routes
      summary: 경로 계산 및 최적화
      description: 장소 간 이동 경로와 시간을 계산하고 최적화합니다
      operationId: calculateRoutes
      parameters:
        - $ref: '#/components/parameters/TripId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/RouteCalculateRequest'
      responses:
        '200':
          description: 경로가 성공적으로 계산됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/RouteCalculateResponse'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'

  /api/itinerary/routes/{routeId}:
    get:
      x-user-story: RQ-ITIN-003
      x-controller: RouteController
      tags:
        - routes
      summary: 경로 상세 정보 조회
      description: 특정 경로의 상세 정보를 조회합니다
      operationId: getRouteById
      parameters:
        - $ref: '#/components/parameters/RouteId'
        - name: realtime
          in: query
          description: 실시간 교통 정보 반영 여부
          schema:
            type: boolean
            default: false
      responses:
        '200':
          description: 성공적으로 조회됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/RouteDetail'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'

  /api/itinerary/places/{placeId}/attachments:
    get:
      x-user-story: RQ-ITIN-004
      x-controller: AttachmentController
      tags:
        - attachments
      summary: 장소 첨부 파일 목록 조회
      description: 특정 장소의 모든 첨부 파일을 조회합니다
      operationId: getAttachments
      parameters:
        - $ref: '#/components/parameters/PlaceId'
        - name: type
          in: query
          description: 첨부 파일 유형 필터
          schema:
            type: string
            enum: [PHOTO, MEMO]
      responses:
        '200':
          description: 성공적으로 조회됨
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Attachment'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'
    
    post:
      x-user-story: RQ-ITIN-004
      x-controller: AttachmentController
      tags:
        - attachments
      summary: 사진 업로드
      description: 장소에 사진을 업로드합니다
      operationId: uploadPhoto
      parameters:
        - $ref: '#/components/parameters/PlaceId'
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              required:
                - file
              properties:
                file:
                  type: string
                  format: binary
                  description: 업로드할 이미지 파일
                caption:
                  type: string
                  maxLength: 200
                  description: 사진 설명
      responses:
        '201':
          description: 사진이 성공적으로 업로드됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PhotoAttachment'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'
        '413':
          description: 파일 크기 초과
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
        '500':
          $ref: '#/components/responses/InternalServerError'

  /api/itinerary/places/{placeId}/memos:
    post:
      x-user-story: RQ-ITIN-004
      x-controller: AttachmentController
      tags:
        - attachments
      summary: 메모 작성
      description: 장소에 텍스트 메모를 작성합니다
      operationId: createMemo
      parameters:
        - $ref: '#/components/parameters/PlaceId'
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/MemoRequest'
      responses:
        '201':
          description: 메모가 성공적으로 작성됨
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/MemoAttachment'
        '400':
          $ref: '#/components/responses/BadRequest'
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'

  /api/itinerary/attachments/{attachmentId}:
    delete:
      x-user-story: RQ-ITIN-004
      x-controller: AttachmentController
      tags:
        - attachments
      summary: 첨부 파일 삭제
      description: 특정 첨부 파일을 삭제합니다
      operationId: deleteAttachment
      parameters:
        - $ref: '#/components/parameters/AttachmentId'
      responses:
        '204':
          description: 첨부 파일이 성공적으로 삭제됨
        '404':
          $ref: '#/components/responses/NotFound'
        '500':
          $ref: '#/components/responses/InternalServerError'

components:
  parameters:
    TripId:
      name: tripId
      in: path
      required: true
      description: 여행 고유 ID (프로파일 서비스의 Trip ID)
      schema:
        type: string
        format: uuid
        example: "550e8400-e29b-41d4-a716-446655440001"
    
    ItineraryId:
      name: itineraryId
      in: path
      required: true
      description: 일정 고유 ID
      schema:
        type: string
        format: uuid
        example: "550e8400-e29b-41d4-a716-446655440003"
    
    PlaceId:
      name: placeId
      in: path
      required: true
      description: 장소 고유 ID
      schema:
        type: string
        format: uuid
        example: "550e8400-e29b-41d4-a716-446655440004"
    
    RouteId:
      name: routeId
      in: path
      required: true
      description: 경로 고유 ID
      schema:
        type: string
        format: uuid
        example: "550e8400-e29b-41d4-a716-446655440005"
    
    AttachmentId:
      name: attachmentId
      in: path
      required: true
      description: 첨부 파일 고유 ID
      schema:
        type: string
        format: uuid
        example: "550e8400-e29b-41d4-a716-446655440006"

  schemas:
    Itinerary:
      type: object
      required:
        - id
        - tripId
        - date
        - dayNumber
        - places
        - createdAt
        - updatedAt
      properties:
        id:
          type: string
          format: uuid
          description: 일정 고유 ID
          example: "550e8400-e29b-41d4-a716-446655440003"
        tripId:
          type: string
          format: uuid
          description: 여행 ID
          example: "550e8400-e29b-41d4-a716-446655440001"
        date:
          type: string
          format: date
          description: 일정 날짜
          example: "2024-07-02"
        dayNumber:
          type: integer
          description: 여행 중 며칠째
          minimum: 1
          example: 2
        title:
          type: string
          description: 일정 제목
          example: "제주 동부 투어"
        places:
          type: array
          description: 방문 장소 목록 (시간순)
          items:
            $ref: '#/components/schemas/Place'
        totalDistance:
          type: number
          format: double
          description: 총 이동 거리 (km)
          example: 45.7
        totalDuration:
          type: integer
          description: 총 소요 시간 (분)
          example: 480
        createdAt:
          type: string
          format: date-time
          description: 생성 일시
          example: "2024-01-15T09:00:00Z"
        updatedAt:
          type: string
          format: date-time
          description: 수정 일시
          example: "2024-01-15T10:30:00Z"

    ItineraryGenerateRequest:
      type: object
      required:
        - date
      properties:
        date:
          type: string
          format: date
          description: 일정을 생성할 날짜
          example: "2024-07-02"
        additionalRequirements:
          type: string
          maxLength: 1000
          description: 사용자가 자유롭게 입력하는 추가 요구사항 (자연어)
          example: "오후 3시쯤 카페에서 휴식 시간을 갖고 싶어요. 가급적 대중교통으로 이동 가능한 곳으로 추천해주세요. 매운 음식은 피해주세요."
        preferences:
          type: object
          description: 일정 생성 선호 옵션
          properties:
            startTime:
              type: string
              pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
              description: 일정 시작 시간
              default: "09:00"
              example: "09:00"
            endTime:
              type: string
              pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
              description: 일정 종료 시간
              default: "21:00"
              example: "21:00"
            includeBreaks:
              type: boolean
              description: 휴식 시간 포함 여부
              default: true
            mealTimes:
              type: object
              description: 식사 시간 설정
              properties:
                breakfast:
                  type: string
                  pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
                  default: "08:00"
                lunch:
                  type: string
                  pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
                  default: "12:00"
                dinner:
                  type: string
                  pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
                  default: "18:00"

    ItineraryUpdateRequest:
      type: object
      properties:
        title:
          type: string
          description: 일정 제목
          example: "제주 동부 투어"
        places:
          type: array
          description: 수정된 방문 장소 목록
          items:
            type: object
            required:
              - placeId
              - order
              - startTime
              - endTime
            properties:
              placeId:
                type: string
                format: uuid
                description: 장소 ID
              order:
                type: integer
                description: 방문 순서
                minimum: 1
              startTime:
                type: string
                pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
                description: 방문 시작 시간
              endTime:
                type: string
                pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
                description: 방문 종료 시간

    Place:
      type: object
      required:
        - id
        - name
        - address
        - location
        - order
        - startTime
        - endTime
        - createdAt
        - updatedAt
      properties:
        id:
          type: string
          format: uuid
          description: 장소 고유 ID
          example: "550e8400-e29b-41d4-a716-446655440004"
        name:
          type: string
          description: 장소명
          example: "성산일출봉"
        recommendReason:
          type: string
          description: 추천 이유
          example: "UNESCO 세계자연유산으로 지정된 제주의 대표 명소"
        address:
          type: string
          description: 도로명 주소
          example: "제주특별자치도 서귀포시 성산읍 성산리 1"
        location:
          $ref: '#/components/schemas/Coordinate'
        order:
          type: integer
          description: 방문 순서
          minimum: 1
          example: 1
        startTime:
          type: string
          pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
          description: 방문 시작 시간
          example: "09:00"
        endTime:
          type: string
          pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
          description: 방문 종료 시간
          example: "10:30"
        duration:
          type: integer
          description: 체류 시간 (분)
          example: 90
        category:
          type: string
          description: 장소 카테고리
          enum: [TOURIST_ATTRACTION, RESTAURANT, CAFE, SHOPPING, ACTIVITY, ACCOMMODATION, OTHER]
          example: "TOURIST_ATTRACTION"
        createdAt:
          type: string
          format: date-time
          description: 생성 일시
          example: "2024-01-15T09:00:00Z"
        updatedAt:
          type: string
          format: date-time
          description: 수정 일시
          example: "2024-01-15T10:30:00Z"

    PlaceDetail:
      allOf:
        - $ref: '#/components/schemas/Place'
        - type: object
          required:
            - mapSearchKeyword
            - rating
            - phone
            - businessHours
            - parking
            - lastVerified
          properties:
            mapSearchKeyword:
              type: string
              description: 지도 앱 검색어
              example: "성산일출봉"
            rating:
              type: object
              description: 평점 정보
              properties:
                google:
                  type: number
                  format: float
                  minimum: 0
                  maximum: 5
                  example: 4.6
                kakao:
                  type: number
                  format: float
                  minimum: 0
                  maximum: 5
                  example: 4.5
                reviewCount:
                  type: integer
                  example: 12543
            phone:
              type: string
              description: 연락처
              example: "064-783-0959"
            businessHours:
              type: object
              description: 영업 시간
              properties:
                status:
                  type: string
                  enum: [OPEN, CLOSED, TEMPORARILY_CLOSED]
                  example: "OPEN"
                todayHours:
                  type: string
                  example: "07:30 - 20:00"
                weeklyHours:
                  type: array
                  items:
                    type: object
                    properties:
                      day:
                        type: string
                        enum: [MON, TUE, WED, THU, FRI, SAT, SUN]
                      hours:
                        type: string
                        example: "07:30 - 20:00"
                      isOpen:
                        type: boolean
            parking:
              type: object
              description: 주차 정보
              properties:
                available:
                  type: boolean
                  example: true
                name:
                  type: string
                  example: "성산일출봉 공영주차장"
                searchKeyword:
                  type: string
                  example: "성산일출봉 주차장"
                fee:
                  type: string
                  example: "소형 1,000원/대, 대형 2,000원/대"
            congestion:
              type: string
              description: 혼잡도
              enum: [LOW, MEDIUM, HIGH, VERY_HIGH]
              example: "MEDIUM"
            lastVerified:
              type: string
              format: date-time
              description: 정보 검증 시각
              example: "2024-01-15T10:30:00Z"

    PlaceRequest:
      type: object
      required:
        - name
        - address
        - location
        - order
        - startTime
        - endTime
        - category
      properties:
        name:
          type: string
          description: 장소명
          example: "성산일출봉"
        recommendReason:
          type: string
          description: 추천 이유
          example: "UNESCO 세계자연유산으로 지정된 제주의 대표 명소"
        address:
          type: string
          description: 도로명 주소
          example: "제주특별자치도 서귀포시 성산읍 성산리 1"
        location:
          $ref: '#/components/schemas/Coordinate'
        order:
          type: integer
          description: 방문 순서
          minimum: 1
          example: 1
        startTime:
          type: string
          pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
          description: 방문 시작 시간
          example: "09:00"
        endTime:
          type: string
          pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
          description: 방문 종료 시간
          example: "10:30"
        category:
          type: string
          description: 장소 카테고리
          enum: [TOURIST_ATTRACTION, RESTAURANT, CAFE, SHOPPING, ACTIVITY, ACCOMMODATION, OTHER]
          example: "TOURIST_ATTRACTION"

    PlaceUpdateRequest:
      type: object
      properties:
        recommendReason:
          type: string
          description: 추천 이유
        order:
          type: integer
          description: 방문 순서
          minimum: 1
        startTime:
          type: string
          pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
          description: 방문 시작 시간
        endTime:
          type: string
          pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$"
          description: 방문 종료 시간

    Coordinate:
      type: object
      required:
        - latitude
        - longitude
      properties:
        latitude:
          type: number
          format: double
          description: 위도
          example: 33.4580
        longitude:
          type: number
          format: double
          description: 경도
          example: 126.9425

    RouteCalculateRequest:
      type: object
      required:
        - date
        - places
      properties:
        date:
          type: string
          format: date
          description: 경로 계산 날짜
          example: "2024-07-02"
        places:
          type: array
          description: 경로 계산할 장소 ID 목록 (순서대로)
          minItems: 2
          items:
            type: string
            format: uuid
          example: ["550e8400-e29b-41d4-a716-446655440004", "550e8400-e29b-41d4-a716-446655440005"]
        transportType:
          type: string
          description: 이동 수단 (지정하지 않으면 여행 기본 설정 사용)
          enum: [PUBLIC_TRANSPORT, PRIVATE_CAR, WALKING, BICYCLE, TAXI]
          example: "PRIVATE_CAR"
        optimization:
          type: object
          description: 경로 최적화 옵션
          properties:
            optimize:
              type: boolean
              description: 경로 최적화 여부
              default: false
            avoidTolls:
              type: boolean
              description: 유료도로 회피
              default: false
            avoidHighways:
              type: boolean
              description: 고속도로 회피
              default: false

    RouteCalculateResponse:
      type: object
      required:
        - totalDistance
        - totalDuration
        - routes
      properties:
        totalDistance:
          type: number
          format: double
          description: 총 이동 거리 (km)
          example: 45.7
        totalDuration:
          type: integer
          description: 총 이동 시간 (분)
          example: 85
        routes:
          type: array
          description: 구간별 경로 정보
          items:
            $ref: '#/components/schemas/Route'
        alternativeRoutes:
          type: array
          description: 대체 경로 옵션
          items:
            type: object
            properties:
              description:
                type: string
                example: "해안도로 경유"
              totalDistance:
                type: number
                format: double
                example: 52.3
              totalDuration:
                type: integer
                example: 90

    Route:
      type: object
      required:
        - id
        - fromPlaceId
        - toPlaceId
        - distance
        - duration
        - transportType
      properties:
        id:
          type: string
          format: uuid
          description: 경로 고유 ID
          example: "550e8400-e29b-41d4-a716-446655440005"
        fromPlaceId:
          type: string
          format: uuid
          description: 출발 장소 ID
        toPlaceId:
          type: string
          format: uuid
          description: 도착 장소 ID
        distance:
          type: number
          format: double
          description: 이동 거리 (km)
          example: 12.5
        duration:
          type: integer
          description: 이동 시간 (분)
          example: 20
        transportType:
          type: string
          description: 이동 수단
          enum: [PUBLIC_TRANSPORT, PRIVATE_CAR, WALKING, BICYCLE, TAXI]
          example: "PRIVATE_CAR"

    RouteDetail:
      allOf:
        - $ref: '#/components/schemas/Route'
        - type: object
          properties:
            polyline:
              type: string
              description: 경로 폴리라인 (인코딩된 문자열)
              example: "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
            steps:
              type: array
              description: 상세 경로 단계
              items:
                type: object
                properties:
                  instruction:
                    type: string
                    example: "우회전하여 1132번 지방도 진입"
                  distance:
                    type: number
                    format: double
                    example: 2.3
                  duration:
                    type: integer
                    example: 3
            trafficInfo:
              type: object
              description: 실시간 교통 정보
              properties:
                congestionLevel:
                  type: string
                  enum: [SMOOTH, NORMAL, SLOW, CONGESTED]
                  example: "NORMAL"
                delayMinutes:
                  type: integer
                  description: 교통 지연 시간 (분)
                  example: 5

    Attachment:
      type: object
      required:
        - id
        - placeId
        - type
        - createdAt
      properties:
        id:
          type: string
          format: uuid
          description: 첨부 파일 고유 ID
          example: "550e8400-e29b-41d4-a716-446655440006"
        placeId:
          type: string
          format: uuid
          description: 장소 ID
        type:
          type: string
          description: 첨부 파일 유형
          enum: [PHOTO, MEMO]
          example: "PHOTO"
        createdAt:
          type: string
          format: date-time
          description: 생성 일시
          example: "2024-01-15T09:00:00Z"

    PhotoAttachment:
      allOf:
        - $ref: '#/components/schemas/Attachment'
        - type: object
          required:
            - fileName
            - fileSize
            - mimeType
            - url
            - thumbnailUrl
          properties:
            fileName:
              type: string
              description: 파일명
              example: "sunset_view.jpg"
            fileSize:
              type: integer
              description: 파일 크기 (bytes)
              example: 2048576
            mimeType:
              type: string
              description: MIME 타입
              example: "image/jpeg"
            url:
              type: string
              format: uri
              description: 원본 이미지 URL
              example: "https://storage.tripgen.com/photos/550e8400-e29b-41d4-a716-446655440006.jpg"
            thumbnailUrl:
              type: string
              format: uri
              description: 썸네일 URL
              example: "https://storage.tripgen.com/photos/550e8400-e29b-41d4-a716-446655440006_thumb.jpg"
            caption:
              type: string
              description: 사진 설명
              maxLength: 200
              example: "성산일출봉에서 본 일출"
            metadata:
              type: object
              description: 이미지 메타데이터
              properties:
                width:
                  type: integer
                  example: 1920
                height:
                  type: integer
                  example: 1080
                takenAt:
                  type: string
                  format: date-time
                  description: 촬영 일시
                location:
                  $ref: '#/components/schemas/Coordinate'

    MemoAttachment:
      allOf:
        - $ref: '#/components/schemas/Attachment'
        - type: object
          required:
            - content
          properties:
            content:
              type: string
              description: 메모 내용
              maxLength: 500
              example: "일출을 보기 위해 새벽 5시에 출발했습니다. 날씨가 맑아서 정말 아름다운 일출을 볼 수 있었어요! 🌅"
            updatedAt:
              type: string
              format: date-time
              description: 수정 일시
              example: "2024-01-15T10:30:00Z"

    MemoRequest:
      type: object
      required:
        - content
      properties:
        content:
          type: string
          description: 메모 내용
          minLength: 1
          maxLength: 500
          example: "일출을 보기 위해 새벽 5시에 출발했습니다. 날씨가 맑아서 정말 아름다운 일출을 볼 수 있었어요! 🌅"

    ErrorResponse:
      type: object
      required:
        - timestamp
        - status
        - error
        - message
        - path
      properties:
        timestamp:
          type: string
          format: date-time
          description: 오류 발생 시간
          example: "2024-01-15T10:30:00Z"
        status:
          type: integer
          description: HTTP 상태 코드
          example: 400
        error:
          type: string
          description: 오류 유형
          example: "Bad Request"
        message:
          type: string
          description: 오류 메시지
          example: "시작 시간은 종료 시간보다 이전이어야 합니다"
        path:
          type: string
          description: 요청 경로
          example: "/api/itinerary/trips/550e8400-e29b-41d4-a716-446655440001/itineraries"

  responses:
    BadRequest:
      description: 잘못된 요청
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    
    NotFound:
      description: 리소스를 찾을 수 없음
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    
    InternalServerError:
      description: 서버 내부 오류
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'

  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - BearerAuth: []