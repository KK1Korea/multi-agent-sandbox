# current_task.md

## [작업 버전]
v0.9.5 : Skeptic 필수 WebSearch(턴당 1+), research_queue 자동 업데이트, Fail_Log 비대칭 폐기, v0.9.4 벤치마크 완료
v0.9.4 : Advocate 재설계 — 방향 앵커({CURRENT_DIRECTION}), Partial Acceptance Protocol(Accept→Redirect→Propose), 프로젝트 추진자 역할
v0.9.3 : cpas-manager 플러그인 분리, masterlog-review → project-review 독립, ET 사용자 승인, stale check, current_task 버전 추적
v0.9.2 : Data-Filter 3분할, Opus 벤치마크 2회 완료 (388K/524K 토큰), 볼륨 분할 규칙, API 비용 추산
v0.9.1 : Data-Filter 3분할 초안, 기존 data-filter.md 레거시 보존
v0.9.0 : Observer 제거, 2-level 아키텍처, Cowork_CPAS 분리, 서브에이전트 도구 실증
v0.6.0 : Observer 루프 제어 첫 벤치마크 → 실패 (미스폰 [17])
v0.5.0 : 열세 감지 + 확장사고 활성화, 메모리 경계 주입
v0.4.0 : Haiku 데이터 필터, masterlog-review 스킬, workspace-init
v0.3.0 : 시스템 개입 제거, 고정 섹션 구조
v0.2.0 : 태그 스펙트럼 확장 (R,C,A:1-13 / S:1-19), D Ref 태그
v0.1.0 : 초기 플러그인 — Advocate/Skeptic/Observer 프롬프트, 5축 태그 시스템

## [현재 상황]
Phase A — Cowork_CPAS v0.9.5 벤치마크 3회 완료, research_queue 기반 검증 단계 진입

## [지금 해야 할 일]
1. [RQ-1] ET + Fail_Log context vs CPAS 직접 비교 — CPAS 고유 가치 분리 (HIGH)
2. [RQ-2] 포트폴리오 내 혼합 증거 결정 비율 측정 (HIGH)
3. [RQ-4] 하위 모델(Sonnet/Haiku) 토의 에이전트 품질 하한선 벤치마크 (MEDIUM)
4. [RQ-5] CPAS 재포지셔닝 결정: Choice A (12주 결과 추적) vs Choice B (결정 문서화 도구) (MEDIUM)

## [로그 현황]
- True_Log: [1][3][4][5][7][10][11][13][14][15][17][19][20][21][22] (15건)
- Fail_Log: [16][18] (2건)
- Dummy_Log: [6][8][9][12] (4건)
- MasterLog: [2][23][24][25][26][27] (6건 — [2][23][24][27] 확정, [25][26] 구상)
- Research Queue: RQ-1~RQ-5 (5건 — HIGH 2, MEDIUM 3)

## [진행도]
Phase A: ████████████████████ 95%
  - 설계: ████████████████████ 100% (Cowork_CPAS v0.9.5 — Skeptic WebSearch 필수 포함)
  - 플러그인 패키징: ████████████████████ 100% (cpas-sandbox v0.9.5 + cpas-manager v1.0)
  - 벤치마크: ████████████████████ 100% (3회 완료 — 외부1, 내부1, v0.9.4 비교1)
  - 데이터 품질: ████████████████░░░░ 80% (True_Log 감사 완료, project-review 분리)
  - 튜닝: ████████████░░░░░░░░ 60% (ET 승인제, Advocate 재설계, Skeptic WebSearch — 하위 모델 미착수)
  - 검증: ████░░░░░░░░░░░░░░░░ 20% (research_queue 5건 등록, RQ-1/RQ-2 미착수)

## [최종 갱신] 2026-03-14 세션 #8
