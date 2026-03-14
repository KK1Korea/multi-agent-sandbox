# current_task.md

## [작업 버전]
v0.9.6 : Skeptic 태그 미출력 수정 완료 (OUTPUT FORMAT 주입), plugin.json 누락 방지 (build-plugin.sh + plugin-meta-backup.json), GitHub repo v0.9.6 동기화
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
Phase A — Cowork_CPAS v0.9.6, RQ-1 초회 실험 완료, RQ-2 D-2/D-5 완료 (mixed 25% + 쟁점 재정의: mixed→clear 전환), RQ-5 부분 해결

## [지금 해야 할 일]
1. [RQ-1] 결론 확정 대기 — 초회 실험 완료, CPAS 고유 가치 = "깊이 기반 결론 신뢰성" 잠정 도출. 추가 주제로 재검증 필요 (HIGH)
2. [RQ-2] D-5(conflicted), D-2(mixed) 완료. TTS 12건 중 mixed 3건(25%, 기준선 도달). 단 D8/D9 미검증 → 하락 리스크. CPAS 내부 정상 경로([28])에서도 mixed 1건 확인. 추가 발견: RQ-1~5 자체가 내부 경로 mixed 증거 (결론 미도출 = mixed 정의). 쟁점 재정의: "mixed 비율 충분한가?" → **"CPAS가 mixed → clear 전환 가능한가?"**. 현재 전환 증거 3건(D-5, D-2, [28]) 전부 성공, 단 내부 경로 n=1. 자연 축적 데이터로 전환율 정밀화 필요 (HIGH)
3. [RQ-4] 하위 모델(Sonnet/Haiku) 토의 에이전트 품질 하한선 벤치마크 (MEDIUM)
4. [RQ-5] 부분 해결 — Choice B 기본 경로, RQ-1 결과에 따라 Choice A 전환. 20주 순차 계획 ($99K) 합의 (MEDIUM)
5. [v0.9.6] Skeptic 태그 미출력 수정 — 완료 (DONE)
6. ~~[D-3] ASMR 토의~~ — 취소. 외부 데이터 수동 주입 방식의 신뢰도 한계로 추가 토의 중단. 정상 스킬 경로로 데이터 자연 축적 후 재검토 (CANCELLED)
7. [태그 누락] D-2/D-5 토의에서 Advocate 태그 라인 간헐적 누락 관측 (T5, T7, T9 등). v0.9.6 OUTPUT FORMAT 주입으로 개선했으나 100% 해결되지 않음. 프롬프트 수준 추가 강화 또는 오케스트레이터 후처리(태그 미출력 시 내용 기반 추정 삽입) 검토 필요 (LOW)

## [로그 현황]
- True_Log: [1][2][3][4][5][7][10][11][13][14][15][17][19][20][21][22][23][24][27] (19건)
- Fail_Log: [16][18] (2건)
- Dummy_Log: [6][8][9][12][29][30] (6건) — [29][30]은 D-5/D-2 토의 상세 원본 (TTS 외부 데이터)
- MasterLog: [25][26][28][29→RQ-2종합] (4건 — 전부 [구상]) — [29] 번호 재사용: RQ-2 측정 종합
- Research Queue: RQ-1~RQ-5 (5건 — HIGH 2, MEDIUM 3)

## [진행도]
Phase A: ████████████████████ 97%
  - 설계: ████████████████████ 100% (Cowork_CPAS v0.9.6 — Skeptic WebSearch 필수 포함)
  - 플러그인 패키징: ████████████████████ 100% (cpas-sandbox v0.9.6 + cpas-manager v1.0)
  - 벤치마크: ████████████████████ 100% (4회 완료 — 외부1, 내부1, v0.9.4 비교1, RQ-1 비교1)
  - 데이터 품질: ████████████████░░░░ 80% (True_Log 감사 완료, project-review 분리)
  - 튜닝: ████████████░░░░░░░░ 60% (ET 승인제, Advocate 재설계, Skeptic WebSearch — 태그 미출력 수정 완료, 하위 모델 미착수)
  - 검증: ██████████████░░░░░░ 55% (RQ-1 초회 완료, RQ-2 D-2/D-5 완료+D-3 취소, RQ-5 부분 해결, RQ-4 미착수)

## [최종 갱신] 2026-03-15 세션 #11
