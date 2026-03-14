# .context/research_queue.md — 연구과제 큐

토의에서 파생된 미검증 항목. 사용자가 증명/실험하여 프로젝트를 진행하기 위한 큐.
우선순위: HIGH → MEDIUM → LOW. 상태: [대기] / [진행] / [완료] / [폐기]

================================================================================

## [RQ-1] ET + Fail_Log context vs CPAS 직접 비교 — [진행] HIGH

* 출처: True_Log [27] v0.9.4 벤치마크, Section 3 Skeptic 제안
* 내용: 동일 의사결정 문제를 (A) CPAS, (B) ET + Fail_Log context, (C) ET + skeptical prompt로 병렬 실행. CPAS 고유 가치가 있는지 분리 측정.
* 측정: C축 (근거 품질), S축 (수렴 속도), 구체성 커밋 수
* 성공 기준: CPAS가 B/C 대비 명확한 우위 → CPAS 고유 가치 확인. B/C가 동등 → CPAS는 불필요한 복잡성.
* 현황: 초회 실험 완료 (MasterLog [28]). CPAS 고유 가치 = "깊이 기반 결론 신뢰성" 잠정 도출. 추가 주제로 재검증 필요 (n=1 불충분).
* 관련: [26], True_Log [21][27], MasterLog [28]

## [RQ-2] 포트폴리오 내 혼합 증거 결정 비율 — [진행] HIGH

* 출처: True_Log [27] Section 2 Skeptic 제안
* 내용: 실제 프로젝트 의사결정 10-15건을 분류하여, 혼합 증거(mixed evidence) 결정이 전체 중 몇 %인지 측정.
* 측정: 결정 유형별 분포 (clear / mixed / sparse / conflicted)
* 성공 기준: ≥25% mixed → CPAS 적용 범위 충분. <20% → CPAS는 니치 도구.
* 현황: TTS 프로젝트 12건 분류 완료 → mixed 3건(25%, 기준선 도달), non-clear 전체 6건(50%). D-5(conflicted), D-2(mixed) 토의 검증 2건, 나머지 10건은 오케스트레이터 수동 분류(미검증). CPAS 내부 데이터 정상 경로([28] RQ-5)에서도 mixed 1건 확인 (n=1). 단, TTS 토의는 외부 데이터 수동 주입 경로 → 정상 필터 경로와 신뢰도 차이. D8/D9는 미검증 mixed로 토의 시 clear 전환 가능성 있음 → mixed 비율 하락 리스크.
* 내부 경로 추가 증거 (세션 #11): RQ-1~5 자체가 내부 정상 경로 sandbox 토의([22],[27])에서 결론 미도출로 파생 = mixed의 정의. 외부 주입(TTS)보다 신뢰도 높음. 단 동일 토의 동시 파생이므로 독립 결정 포인트 5건으로 세기엔 과대 계상 우려.
* 쟁점 재정의 (세션 #11): 진짜 질문은 "mixed 비율이 충분한가?"가 아니라 **"CPAS가 mixed → clear 전환을 달성할 수 있는가?"**. 현재 전환 증거: D-5(conflicted→clear), D-2(mixed→clear), [28] RQ-5(mixed→clear) = 3건 전부 전환 성공. 단 D-5/D-2는 외부 경로, [28]만 내부 경로(n=1).
* 관련: True_Log [27], MasterLog [29], [28]

## [RQ-3] 구체성 강제 → 실행 오류 감소 인과관계 — [대기] MEDIUM

* 출처: True_Log [27] Section 3
* 내용: CPAS가 강제하는 구체성 커밋(specificity commitment)이 실제 실행 오류를 줄이는지 검증.
* 위험: 구체적이지만 틀린 결정 → 실행 오류 증가 가능성
* 측정: CPAS 구체적 결정 vs 일반적 결정 → 하류 수정 횟수 비교 (8주+ 필요)
* 관련: True_Log [27]

## [RQ-4] 하위 모델(Sonnet/Haiku) 토의 에이전트 품질 하한선 — [대기] MEDIUM

* 출처: current_task.md 항목 #3, True_Log [21]
* 내용: Advocate/Skeptic을 Sonnet 레벨로 교체 시 토의 품질(C축, S축) 유지 여부.
* 성공 기준: Sonnet Advocate/Skeptic의 C축 평균 ≥7, S축 자연 수렴 유지 → 비용 2-3x 절감 가능.
* 관련: True_Log [21][24][27]

## [RQ-5] CPAS 재포지셔닝 — 결과 개선 vs 프로세스 개선 — [진행] MEDIUM

* 출처: True_Log [27] Section 3 결론
* 내용: CPAS를 "의사결정 결과 개선 도구" vs "의사결정 프로세스 개선 도구"(문서화/투명성/감사 추적) 중 어느 쪽으로 포지셔닝할지.
* Choice A: 12주 결과 추적 실험 → 결과 개선 입증 경로
* Choice B: 결정 문서화 도구로 재포지셔닝 → 즉시 실행 가능, 결과 데이터 불필요
* 현황: Choice B 기본 경로 합의. RQ-1 결과에 따라 Choice A 전환 조건 설정. 20주 순차 계획 ($99K), week-4 하드 게이트 (MasterLog [28]).
* 의존: RQ-1 결과에 따라 방향 결정
* 관련: [26], True_Log [27], MasterLog [28]

================================================================================
