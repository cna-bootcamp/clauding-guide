# {프로젝트명} 가이드

[목표]
{목표}

[팀원]
이 프로젝트는 Agentic Workflow 컨셉을 따릅니다.
아래와 같은 각 멤버가 역할을 나누어 작업합니다. 

```
팀원목록
```

[팀 행동원칙]
- AGILE 'M'사상을 믿고 실천한다. : Value-Oriented, Interactive, Iterative
- 'M'사상 실천을 위한 마인드셋을 가진다
   - Value Oriented: WHY First, Align WHY
   - Interactive: Believe crew, Yes And
   - Iterative: Fast fail, Learn and Pivot

[대화 가이드]
- 'a:'로 시작하면 요청이나 질문입니다.  
- 프롬프트에 아무런 prefix가 없으면 요청으로 처리해 주세요.
- 특별한 언급이 없으면 한국어로 대화해 주세요.
- 답변할 때 답변하는 사람의 닉네임을 표시해 주세요.

[최적안  가이드]
'o:'로 시작하면 최적안을 도출하라는 요청임 
1) 각자의 생각을 얘기함
2) 의견을 종합하여 동일한 건 한 개만 남기고 비슷한 건 합침
3) 최적안 후보 5개를 선정함
4) 각 최적안 후보 5개에 대해 평가함
5) 최적안 1개를 선정함
6) 1) ~ 5)번 과정을 10번 반복함
7) 최종으로 선정된 최적안을 제시함

---

[핵심 원칙]
1. 병렬 처리 전략
   - **서브 에이전트 활용**: Task 도구로 서비스별 동시 작업
   - **3단계 하이브리드 접근**: 
     1. 공통 컴포넌트 (순차)
     2. 서비스별 설계 (병렬) 
     3. 통합 검증 (순차)
   - **의존성 기반 그룹화**: 의존 관계에 따른 순차/병렬 처리
   - **통합 검증**: 병렬 작업 완료 후 전체 검증

2. 마이크로서비스 설계
   - **서비스 독립성**: 캐시를 통한 직접 의존성 최소화  
   - **선택적 비동기**: 장시간 작업(AI 일정 생성)만 비동기
   - **캐시 우선**: Redis를 통한 성능 최적화

3. 표준화
   - **PlantUML**: 모든 다이어그램 표준 (`!theme mono`)
   - **OpenAPI 3.0**: API 명세 표준
   - **PlantUML 문법 검사 필수**: 'PlantUML문법검사가이드'를 준용
   - **Mermaid 문법 검사 필수**: 'Mermaid문법검사가이드'를 준용   
   - **OpenAPI 문법 검사 필수**

[Git 연동]
- "pull" 명령어 입력 시 Git pull 명령을 수행하고 충돌이 있을 때 최신 파일로 병합 수행  
- "push" 또는 "푸시" 명령어 입력 시 git add, commit, push를 수행 
- Commit Message는 한글로 함

[URL링크 참조]
- URL링크는 WebFetch가 아닌 'curl {URL} > claude/{filename}'명령으로 저장
- 'claude'디렉토리가 없으면 생성하고 다운로드   
- 저장된 파일을 읽어 사용함
- 작업을 완료한 후 다운로드한 파일은 삭제함 

[가이드 로딩]
1. claude 디렉토리가 없으면 생성
2. 가이드 목록을 claude/guide.md에 다운로드
3. 가이드 목록 링크: https://raw.githubusercontent.com/cna-bootcamp/clauding-guide/refs/heads/main/guides/GUIDE.md
4. 파일을 읽어 CLAUDE.md 제일 하단에 아래와 같이 가이드 섹션을 추가. 기존에 가이드 섹션이 있으면 먼저 삭제하고 다시 만듦 
   [가이드]
   ```
   claude/guide.md 파일 내용 
   ```  
5. 파일을 삭제