# 설계 프롬프트 가이드

## UI/UX 설계

```
/sc:design --persona-frontend --think --uc --wave-mode auto --wave-strategy systematic 

SVG Wireframe을 생성해주세요:

- **주요 화면**: design/Userstory.md를 꼼꼼히 이해하여 작성 
- 서브 에이젼트를 병렬로 실행하여 작업
- **SVG 요구사항**:
  - 반응형 레이아웃 (320px~1024px)
  - 컴포넌트별 분리된 wireframe
  - 사용자 플로우 다이어그램 포함 
- 결과파일: design/wireframe 폴더 하위에 생성  
```

## 클라우드 아키텍처 패턴 선정 
```
/sc:design --persona-architect --think-hard --seq --uc --wave-mode auto --wave-strategy systematic 

클라우드 아키텍처 패턴 적용 방안을 작성해 주세요:
- '클라우드 아키텍처 패턴 선정 가이드'를 준용하여 작성 
```

## 논리아키텍처 설계
```
/sc:design --persona-architect --think-hard --seq --c7 --uc --wave-mode auto --wave-strategy systematic 

논리 아키텍처를 설계해 주세요:
- [공통 설계 원칙](../design/common-principles.md)과 [논리아키텍처 설계 가이드](../design/architecture.md)를 준용하여 설계 

```

## API 설계
```
/sc:design --persona-architect --think-hard --seq --c7 --uc --wave-mode auto --wave-strategy systematic 

API를 설계해 주세요:
- [공통 설계 원칙](../design/common-principles.md)과 [API 설계 가이드](../design/api-design.md)를 준용하여 설계 

```

## 외부 시퀀스 설계
```
/sc:design --persona-architect --think-hard --seq --c7 --uc --wave-mode auto --wave-strategy systematic 

외부 시퀀스 설계를 해 주세요:
- [공통 설계 원칙](../design/common-principles.md)과 [외부 시퀀스 설계 가이드](../design/sequence-design.md)를 준용하여 설계 

```

## 내부 시퀀스 설계
```
/sc:design --persona-architect --think-hard --seq --c7 --uc --wave-mode auto --wave-strategy systematic 

내부 시퀀스 설계를 해 주세요:
- [공통 설계 원칙](../design/common-principles.md)과 [내부 시퀀스 설계 가이드](../design/sequence-design.md)를 준용하여 설계 

```

## 클래스 설계
```
/sc:design --persona-architect --think-hard --seq --c7 --uc --wave-mode auto --wave-strategy systematic 

클래스 설계를 해주세요:
- [공통 설계 원칙](../design/common-principles.md)과 [클래스 설계 가이드](../design/class-data-design.md)를 준용하여 설계
- 패키지 그룹: com.unicorn.tripgen
- 개발 아키텍처 패턴 
  - itinerary: Clean 
  - location: Clean
  - profile: Layered 
```

## 데이터 설계
```
/sc:design --persona-architect --think-hard --seq --c7 --uc --wave-mode auto --wave-strategy systematic 

데이터 설계를 해주세요:
- [공통 설계 원칙](../design/common-principles.md)과 [데이터 설계 가이드](../design/class-data-design.md)를 준용하여 설계

```

## 물리 아키텍처 설계
```
/sc:design --persona-architect --think-hard --seq --c7 --uc --wave-mode auto --wave-strategy systematic 

물리 아키텍처를 설계 해주세요:
- [공통 설계 원칙](../design/common-principles.md)과 [물리 아키텍처 설계 가이드](../design/architecture.md)를 준용하여 설계
- CLOUD: Azure Cloud 
```


