# 클래스 및 데이터 설계 가이드

## 클래스 설계 가이드 

[요청사항]
- 멀티프로젝트 구조로 설계 
- 각 서비스별 지정된 개발 아키텍처 패턴을 적용
- '패키지 구조 표준'을 준용
- Clean아키텍처 적용 시 Port/Adapter라는 용어 대신 Clean 아키텍처에 맞는 용어 사용
- API를 누락하지 말고 모두 반영할 것
- 클래스 간의 관계를 표현: Generalization, Realization, Dependency, Association, Aggregation, Composition
- 프라퍼티와 메소드를 모두 기술할 것
- 각 서비스별로 분리하여 각각 작성하고 common은 가장 나중에 작성 
- '패키지 구조 표준'의 예시를 참조하여 모든 클래스와 파일이 포함된 패키지 구조도를 제공
- 패키지 구조도는 plantuml 스크립트가 아니라 트리구조 텍스트로 작성  

[작성 방법]
- **서브 에이전트를 활용한 병렬 작성 필수**
- **3단계 하이브리드 접근법 적용**
- **마이크로서비스 아키텍처 기반 설계**

### 1단계: 공통 컴포넌트 설계 (순차적)
```
Agent 1: 공통 기반 설계
  - Common DTOs (서비스 간 공유 모델)
  - Shared Interfaces (공통 인터페이스)
  - Exception Classes (공통 예외)
  - Utility Classes (공통 유틸리티)
  - 결과: design/backend/class/common-base.txt
```

### 2단계: 서비스별 병렬 설계 (병렬 실행)
```
Agent 2~N: 각 서비스별 독립 설계
  - Entity Classes (도메인 모델)
  - Repository Interfaces/Classes (데이터 접근)
  - Service Classes (비즈니스 로직)
  - Controller Classes (API 엔드포인트)
  - 각 서비스의 아키텍처 패턴 적용
  - 1단계 공통 컴포넌트 참조
  - 결과: design/backend/class/{service-name}.txt
```

**병렬 처리 기준**:
- 서비스 간 의존성이 없는 경우: 모든 서비스 동시 실행
- 의존성이 있는 경우: 의존성 그룹별로 묶어서 실행
  - 예: A→B 의존 시, A 완료 후 B 실행
  - 독립 서비스 C,D는 A,B와 병렬 실행

### 3단계: 통합 및 검증 (순차적)
```
Agent N+1: 통합 작업
  - 패키지 구조도 생성
  - 인터페이스 일치성 검증
  - 명명 규칙 통일성 확인
  - 의존성 검증
  - 크로스 서비스 참조 검증
  - 결과: design/backend/class/package-structure.txt
```

### 병렬 처리 실행 지침

#### 실행 방법
1. **1단계 완료 확인**: 공통 컴포넌트 설계 완료 후 진행
2. **2단계 동시 실행**: Task 도구로 여러 Agent를 동시에 실행
3. **공통 참조 명시**: 각 에이전트에게 1단계 결과물 경로 제공
4. **통합 검증**: 모든 병렬 작업 완료 후 전체 일관성 검증

#### 병렬 처리 원칙
- **독립성 보장**: 서비스 간 직접 참조 금지, 인터페이스만 참조
- **표준 준수**: 모든 서비스가 동일한 명명 규칙과 패턴 적용
- **비동기 통신**: 서비스 간 통신은 API 또는 메시지 큐 활용
- **데이터 격리**: 각 서비스는 독립적인 데이터 모델 보유

#### 의존성 관리 전략
```
# 의존성 없는 경우 (최적)
Agent 2: Service A
Agent 3: Service B  } 동시 실행
Agent 4: Service C

# 의존성 있는 경우
Agent 2: Service A (독립)
Agent 3: Service B → Service C (순차)  } 그룹별 실행
Agent 4: Service D (독립)
```

[참고자료]
- 유저스토리: Userstory.md
- 화면설계: design/wireframe 폴더의 화면설계 
- 아키텍처패턴: design/pattern/아키텍처패턴.txt
- 논리아키텍처: design/backend/논리아키텍처.txt
- API 설계서: design/backend/api/*.yaml
- 외부시퀀스 설계서: design/backend/sequence/outer/{플로우명}.txt
- 내부시퀀스 설계서: design/backend/sequence/outer/{서비스명}-{플로우명}.txt

[예시]
- 링크: https://cna-bootcamp.github.io/clauding-guide/samples/sample_시퀀스설계서.txt
- 패키지 구조 표준: https://cna-bootcamp.github.io/clauding-guide/standards/standard_package_structure.txt
  
[결과파일]
- design/backend/class/package-structure.txt
- design/backend/class/{service-name}.txt
- 서비스명은 영어로 작성 (예: profile, location, itinerary)
  
---

## 데이터 설계 가이드 

[요청사항]
- 클래스설계서의 각 서비스별 entity와 일치해야 함
- 각 서비스마다 데이터베이스를 분리하여야 함
- 마이크로서비스 원칙에 따른 데이터 독립성 보장
- 클래스 설계서의 각 서비스별 entity와 일치해야 함
- ERD는 별도 파일로 작성
- ERD의 plantuml script 문법 검사를 수행 
- 캐시 사용 시 캐시DB설계를 별도로 작성 
- 데이터설계 요약 파일을 별도로 작성 
[작성 방법]
- **서브 에이전트를 활용한 병렬 작성 권장**
- **서비스별 독립 데이터베이스 설계**
- **데이터 격리 원칙 준수**

### 병렬 처리 전략
```
Agent 1~N: 각 서비스별 데이터베이스 설계
  - 서비스별 독립적인 스키마 설계
  - Entity 클래스와 1:1 매핑
  - 서비스 간 데이터 공유 금지
  - FK 관계는 서비스 내부에서만 설정
```

### 데이터 독립성 원칙
- **데이터 소유권**: 각 서비스가 자신의 데이터 완전 소유
- **크로스 서비스 조인 금지**: 서비스 간 DB 조인 불가
- **이벤트 기반 동기화**: 필요시 이벤트/메시지로 데이터 동기화
- **캐시 활용**: 타 서비스 데이터는 캐시로만 참조 

[참고자료]
- 유저스토리: Userstory.md
- 화면설계: design/wireframe 폴더의 화면설계 
- 아키텍처패턴: design/pattern/아키텍처패턴.txt
- 논리아키텍처: design/backend/논리아키텍처.txt
- API 설계서: design/backend/api/*.yaml
- 외부시퀀스 설계서: design/backend/sequence/outer/{플로우명}.txt
- 내부시퀀스 설계서: design/backend/sequence/inner/{service-name}-{flow-name}.txt
- 클래스 설계서: design/backend/class/{service-name}.txt

[예시]
- 링크: https://cna-bootcamp.github.io/clauding-guide/samples/sample_데이터설계서.txt

[결과파일]
- 데이터설계서: design/backend/database/{서비스명}.txt
- ERD: design/backend/database/{서비스명}-erd.txt
- 캐시DB 설계: design/backend/database/cache.txt
- 데이터설계 요약: design/backend/database/database-design-summary.md
- 서비스명은 영어로 작성 