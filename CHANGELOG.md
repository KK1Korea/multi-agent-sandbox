# CHANGELOG — CPAS Plugins

플러그인 버전별 변경사항 기록. 최신이 위.

================================================================================

## cpas-manager v1.0.0 — 2026-03-14 세션 #7
- 신규 플러그인: 프로젝트 관리 전담 (cpas-sandbox에서 분리)
- project-review 스킬: MasterLog/True/Fail/Dummy 로그 분류 + 이동
- True_Log/Fail_Log 재평가 (구형 데이터 → Dummy 자동 이동)
- current_task.md 버전 추적 ([작업 버전] 섹션)
- 버전 기반 구형 데이터 탐지
- /review 커맨드

## cpas-sandbox v0.9.5 — 2026-03-14 세션 #8
- Skeptic: O-3-4 [Mandatory WebSearch] — 턴당 최소 1회 웹 검색 필수 (최신 데이터 주입 보장)
- sandbox-orchestrator: Research Queue 업데이트 단계 추가 (토의 후 필수)
  - [미검증 항목] + [분리 쟁점] → research_queue.md 자동 등록
  - 우선순위 체계 (HIGH/MEDIUM/LOW) + 성공 기준 포맷
- Fail_Log 비대칭 전략 명시적 폐기: 양쪽 동일 데이터 수신이 올바른 설계
  - Skeptic은 지적을 위해, Advocate는 진행을 위해 같은 데이터를 다르게 활용
- v0.9.4 벤치마크 완료: v0.9.2 동일 주제 재실행, Accept→Redirect→Propose 패턴 실증

## cpas-sandbox v0.9.4 — 2026-03-14 세션 #8
- Advocate 프롬프트 전면 재설계: "유연하고 능력있는 사원" 역할
  - O-1-4 [Project Direction Anchor]: current_task.md `[지금 해야 할 일]` 기반 방향 앵커
  - O-3-4 [Partial Acceptance Protocol]: Accept → Redirect → Propose 3단계 패턴
  - X-0 공리 갱신: 방어자 → 프로젝트 추진자
- sandbox-orchestrator: `{CURRENT_DIRECTION}` 컨텍스트 추가
  - Advocate에만 전달 (Skeptic 독립성 보장)
  - Advocate spawn 프롬프트에 방향 앵커 블록 삽입
  - Resume 프롬프트: "Address their concerns and drive the discussion forward."
- 토의 역학 변경: 무조건적 공방 → Advocate 방향 추진 + Skeptic 스트레스 테스트 → 정제된 결론

## cpas-sandbox v0.9.3 — 2026-03-14 세션 #7
- masterlog-review 스킬 제거 → cpas-manager 플러그인으로 이관
- sandbox-orchestrator: 확장사고 활성화 → 사용자 승인 필수 (비용 폭발 방지)
- sandbox-orchestrator Step 0.5: stale check → cpas-manager `/review` 권고로 변경
- sandbox-orchestrator Step 1: `{MEMORY_CONTEXT}`에 `[지금 해야 할 일]`만 포함 (버전/로그 현황 제외)

## v0.9.2 — 2026-03-14 세션 #5~#6
- Data-Filter 3분할: masterlog-filter + truelog-filter + faillog-filter (Haiku×3 병렬)
- 볼륨 분할 규칙: 1파일 = 최대 1500줄, 초과 시 Haiku 추가 배치
- sandbox-orchestrator Step 2 전면 개정 (병렬 필터 소환)
- 1차 벤치마크 (외부 주제): ~388K 토큰, 정상 완주
- 2차 벤치마크 (내부 주제): ~524K 토큰, ET 활성화 확인
- plugin.json v0.9.2

## v0.9.1 — 2026-03-14 세션 #5
- Data-Filter 3분할 초안 (masterlog-filter, truelog-filter, faillog-filter)
- 기존 data-filter.md → [LEGACY] 보존
- plugin.json v0.9.1

## v0.9.0 — 2026-03-14 세션 #4
- Observer 제거 → 오케스트레이터가 Phase 2 직접 제어 (Cowork_CPAS 아키텍처)
- sandbox-orchestrator SKILL.md 전면 개정 (v0.9)
- observer.md → [IDEAL ONLY] 표기 (Claude Code 3-level 전용)
- Cowork_CPAS.md v1.0 설계 문서 작성
- plugin.json v0.9.0

## v0.6.0 — 2026-03-14 세션 #3
- Observer 루프 제어 시도 → 실패 ([17] 미스폰)
- 열세 감지 + 확장사고 활성화 시스템 추가
- 메모리 시스템 통합 (경계 조건 주입)

## v0.5.0 — 2026-03-14 세션 #3
- 열세 감지(O-3-3-A) + 확장사고 활성화 로직
- 메모리 → 토의 경계(non-debatable ground truth)로 주입
- Observer SKILL.md v0.5

## v0.4.0 — 2026-03-14 세션 #3
- Haiku 데이터 필터 에이전트 신설 (agents/data-filter.md)
- MasterLog 정리 스킬 신설 (skills/masterlog-review v0.1)
- workspace-init 스킬 + /cpas-init 커맨드
- 데이터 소스 신뢰도 3계층 ([12])
- 오케스트레이터 "Internal Data Pipeline" 섹션

## v0.3.0 — 2026-03-14 세션 #2
- recorder agent 폐기 → 오케스트레이터 품질 게이트 직접 수행
- 태그 스트리핑 정규식 처리
- 출력 포맷 통일

## v0.2.0 — 2026-03-14 세션 #1
- 태그 스펙트럼 확장 (R,C,A: 1-13 / S: 1-19)
- D Ref 태그 추가 (D가 R,C,A,S 허용 범위 제어)
- 블랙박스 원칙 강화 (부정문 제거)

## v0.1.0 — 2026-03-14 세션 #1
- 초기 플러그인 구조
- Advocate/Skeptic/Observer 프롬프트 v0.1
- 5축 메타 태그 시스템 (D/R/C/A/S)

================================================================================
