# CHANGELOG — cpas-sandbox Plugin

플러그인 버전별 변경사항 기록. 최신이 위.

================================================================================

## v0.9.3 — 2026-03-14 세션 #7
- masterlog-review v0.3: 모델 고정(Sonnet) 제거 → 사용자 모델 상속
- masterlog-review v0.3: True_Log 잔류 기준 강화 (지속 참조 가치 필수)
- masterlog-review v0.3: 5종 상태 태그([구상]/[진행]/[보류]/[폐기]/[확정]) 분류 연동
- masterlog-review v0.3: Dummy 분류에 "구버전 설계" + "True_Log 재평가 대상" 추가
- sandbox-orchestrator: 확장사고 활성화 → 사용자 승인 필수 (비용 폭발 방지)

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
