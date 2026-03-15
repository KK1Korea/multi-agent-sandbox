# current_task.md

## [작업 버전]
v0.9.11 : 내부 데이터 무결성 검사(Internal Data Integrity Check). 교환 간 {FILTERED_DATA} 대비 내부 인용 존재 여부 확인. 양방향 대칭 + 자정작용 우선 + 내용 불간섭. 원인: v0.9.4 Accept→Redirect→Propose가 Advocate의 인용 검증 능력 약화 → Skeptic 환각(Episode) Type-X 미감지 ([33]). Haiku 필터 무관 확인.
v0.9.10 : Skeptic/Advocate 태그 프리앰블 누락 수정. O-2-1에 "CRITICAL — NO PREAMBLE" 강제 + "Your first character must be [" 리마인더. 원인: 도구 호출(WebSearch) 후 프리앰블이 태그를 밀어냄 — Skeptic 메타 질문으로 진단. 양쪽 에이전트 적용.
v0.9.9 : 태그 비대칭화 + D-temperature 1-13축 표준화. Advocate R 1-19 확장 (주제 추적 세분화), Skeptic C 1-19 확장 (반증/검증 범위 확장), Skeptic A 앵커 역할 맞춤 재정의 (Rebuttal Intensity), Advocate A 앵커 유지 (Assertion Strength). 역할별 태그 프로토콜 분리. D-temperature 1-13축 표준화: 상승형(R,A) 1~5/3~9/7~13, 하강형(C) 9~13/5~11/1~7 — M구간 7칸으로 넓혀 좁은 스케일 표현력 확보. D-Q 공세 추격 단계 추가 (세션당 ≤1회, 최후의 진술 전용). 한글 프롬프트 v0.9.9 동기화 완료.
v0.9.8 : 2세션 16턴 구조 (탐색전 8T + 공방전 8T), 최후의 진술 세션당 2턴, 세션 1 결론→세션 2 주입, S≤4 불균형 감지 1턴으로 강화, Skeptic O-1-2 WebSearch 필수 명시
v0.9.7 : 8턴 포맷 (6T+최후의진술 2T), Output Example→Condition 포맷, Skeptic WebSearch Condition 강화, 한글 프롬프트 v0.9.7 동기화
v0.9.6 : Skeptic 태그 미출력 수정 완료 (OUTPUT FORMAT 주입), plugin.json 누락 방지 (build-plugin.sh + plugin-meta-backup.json), GitHub repo v0.9.6 동기화
v0.9.5 : Skeptic 필수 WebSearch(턴당 1+), research_queue 자동 업데이트, Fail_Log 비대칭 폐기, v0.9.4 벤치마크 완료
v0.9.4 : Advocate 재설계 — 방향 앵커({CURRENT_DIRECTION}), Partial Acceptance Protocol(Accept→Redirect→Propose), 프로젝트 추진자 역할
v0.9.3 : cpas-manager 플러그인 분리, masterlog-review → project-review 독립, 불균형 개입 사용자 승인, stale check, current_task 버전 추적
v0.9.2 : Data-Filter 3분할, Opus 벤치마크 2회 완료 (388K/524K 토큰), 볼륨 분할 규칙, API 비용 추산
v0.9.1 : Data-Filter 3분할 초안, 기존 data-filter.md 레거시 보존
v0.9.0 : Observer 제거, 2-level 아키텍처, Cowork_CPAS 분리, 서브에이전트 도구 실증
v0.6.0 : Observer 루프 제어 첫 벤치마크 → 실패 (미스폰 [17])
v0.5.0 : 열세 감지 + 불균형 보고, 메모리 경계 주입
v0.4.0 : Haiku 데이터 필터, masterlog-review 스킬, workspace-init
v0.3.0 : 시스템 개입 제거, 고정 섹션 구조
v0.2.0 : 태그 스펙트럼 확장 (R,C,A:1-13 / S:1-19), D Ref 태그
v0.1.0 : 초기 플러그인 — Advocate/Skeptic/Observer 프롬프트, 5축 태그 시스템

## [현재 상황]
Phase A — Cowork_CPAS v0.9.11 [구상], 내부 데이터 무결성 검사 추가 (Haiku 필터 무관 확인, v0.9.4 역할 비대칭 보정). Skeptic 태그 누락 원인 진단+수정 완료 (프리앰블 문제). RQ-1 4차+Opus 단독 비교 완료 (구조적 속성 확정, CPAS 고유 가치 4항목). RQ-9 재정의 + 3-track 설계 합의 + v0.9.11 부분 해결. RQ-2 D-2/D-5 + [30] 합의, RQ-5 부분 해결, RQ-7 Path B 확정([31])

## [지금 해야 할 일]
1. [RQ-1] 4차 실험 + Opus 단독 비교 완료 (MasterLog [33]). **양측 합의: 양방향 교차 교정은 구조적 속성** ("구조적 vs 우연" 논쟁 종결). **미합의: 충분성 범위** — Advocate: 도메인별 조건부, Skeptic: 복잡도 의존적 보편 열화. 3-track 테스트 설계 합의(Track A/B/C). Skeptic 자체 환각(T10,12,14)=Type-X 증거. **Opus 단독 4차 비교: 결론 방향 일치** (3차 불일치→4차 일치). CPAS 우위=반론 공방 검증+Type-X 자기발견+3-track 구체 설계. Opus 단독 고유=E_structural 분류+Semantically Rich Specs. R축 패턴 4회 연속 일관(CPAS=깊이 R-1~4, Opus 단독=넓이 R-3~6). CPAS 고유 가치 최종: (1) R축 수렴 강제력, (2) 양방향 교차 교정(구조적 확정), (3) 반론 검증 robustness, (4) Type-X 자기발견. (HIGH — 구조적 속성 확정, 충분성 미해결)
2. [RQ-2] D-5(conflicted), D-2(mixed) 완료. TTS 12건 중 mixed 3건(25%, 기준선 도달). 단 D8/D9 미검증 → 하락 리스크. CPAS 내부 정상 경로([28])에서도 mixed 1건 확인. 추가 발견: RQ-1~5 자체가 내부 경로 mixed 증거 (결론 미도출 = mixed 정의). 쟁점 재정의: "mixed 비율 충분한가?" → **"CPAS가 mixed → clear 전환 가능한가?"**. 현재 전환 증거 3건(D-5, D-2, [28]) 전부 성공, 단 내부 경로 n=1. 자연 축적 데이터로 전환율 정밀화 필요 (HIGH)
3. [RQ-7] 토의 완료 (MasterLog [31]) — Self red-teaming 전 형태 기각, Path B (사후 블랙박스 모니터링) 확정. 남은 과제: Path B n=5 실증, between-episode 피드백 검증, defensive fabrication 빈도. (MEDIUM — 방향 확정, 실증 미완)
3-1. [RQ-9] 재정의 완료 (MasterLog [33]) + **v0.9.11 부분 해결 (MasterLog [34])** — "인용 검증 메커니즘" → **"교차 교정 작동 범위 및 최적 모니터링 아키텍처 검증"**. 3-track 테스트 설계 합의 (Track A/B/C). **내부 데이터 무결성 검사 즉시 적용** — Haiku 필터 무관 확인, Skeptic citation format contamination(순수 환각) 진단, v0.9.4 역할 비대칭(Accept→Redirect→Propose→인용 검증 약화) 보정. 오케스트레이터 교환 간 {FILTERED_DATA} 대조, 양방향 대칭, 자정작용 우선. 사용자 확인 필요: 테스트 규모(축소 vs 풀), salience flags 포함 여부. (HIGH — 즉시 적용 안전장치 완료, 3-track 실행 미착수)
4. [RQ-4] 하위 모델(Sonnet/Haiku) 토의 에이전트 품질 하한선 벤치마크 (MEDIUM)
5. [RQ-5] 부분 해결 — Choice B 기본 경로, RQ-1 결과에 따라 Choice A 전환. 20주 순차 계획 ($99K) 합의 (MEDIUM)
6. [v0.9.6] Skeptic 태그 미출력 수정 — 완료 (DONE)
7. ~~[D-3] ASMR 토의~~ — 취소. 외부 데이터 수동 주입 방식의 신뢰도 한계로 추가 토의 중단. 정상 스킬 경로로 데이터 자연 축적 후 재검토 (CANCELLED)
8. [태그 누락] **원인 진단 완료 (세션 #15)**: Skeptic 메타 질문으로 확인 — 도구 호출(WebSearch 등) 후 프리앰블("Now I'll construct...")이 태그 라인보다 먼저 출력됨. 기본 작동 모드(투명성/show your work)가 O-2-1 태그 지시보다 우선순위 높아서 발생. **수정 적용**: O-2-1에 "CRITICAL — NO PREAMBLE" 강제 + "Your first character must be [" 리마인더. Advocate/Skeptic 양쪽 적용. github-repo 반영 완료, 로컬 플러그인은 읽기 전용 → 다음 빌드 시 반영. 검증 필요: 다음 sandbox 토의에서 Skeptic 태그 출력 확인 (MEDIUM)

## [로그 현황]
- True_Log: [1][2][3][4][5][7][10][11][13][14][15][17][19][20][21][22][23][24][27][31][32][34] (22건)
- Fail_Log: [16][18] (2건)
- Dummy_Log: [6][8][9][12][29][30] (6건) — [29][30]은 D-5/D-2 토의 상세 원본 (TTS 외부 데이터)
- MasterLog: [25][26][28][29→RQ-2종합][30][31][33][34] (8건 — 전부 [구상]) — [29] 번호 재사용: RQ-2 측정 종합, [30] RQ-2 토의, [31] RQ-7 토의, [33] RQ-1+RQ-9 구조적 속성 토의, [34] 내부 데이터 무결성 검사 설계
- Research Queue: RQ-1~RQ-9 (9건 — HIGH 3, MEDIUM 4) + RQ-10/11 후보

## [진행도]
Phase A: ████████████████████ 97%
  - 설계: ████████████████████ 100% (Cowork_CPAS v0.9.11 — 데이터 무결성 검사, NO PREAMBLE, 2세션 16턴, 비대칭 태그, D-temperature 표준화, D-Q)
  - 플러그인 패키징: ████████████████████ 100% (cpas-sandbox v0.9.11 + cpas-manager v1.0)
  - 벤치마크: ████████████████████ 100% (8회 완료 — 외부1, 내부1, v0.9.4 비교1, RQ-1 비교3, RQ-7 토의1, RQ-1+9 토의1)
  - 데이터 품질: ████████████████░░░░ 80% (True_Log 감사 완료, project-review 분리)
  - 튜닝: ███████████████░░░░░ 75% (불균형 개입 사용자 승인, Advocate 재설계, Skeptic WebSearch, 태그 프리앰블 수정, 데이터 무결성 검사 — 하위 모델 미착수)
  - 검증: ██████████████████░░ 78% (RQ-1 4차 완료, RQ-2 완료+D-3 취소, RQ-5 부분 해결, RQ-7 Path B 확정, RQ-9 재정의+3-track+v0.9.11 부분 해결, RQ-4 미착수)

## [최종 갱신] 2026-03-15 세션 #16 (v0.9.11 — 데이터 무결성 검사)
