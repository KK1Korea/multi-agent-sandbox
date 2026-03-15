# .context/research_queue.md — 연구과제 큐

토의에서 파생된 미검증 항목. 사용자가 증명/실험하여 프로젝트를 진행하기 위한 큐.
우선순위: HIGH → MEDIUM → LOW. 상태: [대기] / [진행] / [완료] / [폐기]

================================================================================

## [RQ-1] ET + Fail_Log context vs CPAS 직접 비교 — [진행] HIGH

* 출처: True_Log [27] v0.9.4 벤치마크, Section 3 Skeptic 제안
* 내용: 동일 의사결정 문제를 (A) CPAS, (B) ET + Fail_Log context, (C) ET + skeptical prompt로 병렬 실행. CPAS 고유 가치가 있는지 분리 측정.
* 측정: C축 (근거 품질), S축 (수렴 속도), 구체성 커밋 수
* 성공 기준: CPAS가 B/C 대비 명확한 우위 → CPAS 고유 가치 확인. B/C가 동등 → CPAS는 불필요한 복잡성.
* 현황: 2차 실험 완료 (True_Log [31]). 동일 주제(MasterLog [30] vs ET-only) R축 비교 — CPAS R-4이상 18.75%, ET-only 42.1%. CPAS 고유 가치 정밀화: "교차 검증을 통한 쟁점별 스트레스 테스트 + R축 수렴 강제력". 결론 방향은 일치하나 도달 경로 상이 (CPAS=깊이+집중, ET-only=넓이+정량). 두 접근 보완적. ⚠ ET-only R값은 Opus 사후 분류(혼재 가능성). n=2(주제 2건), 추가 주제 재검증 필요.
* 관련: [26], True_Log [21][27][31], MasterLog [28][30]

## [RQ-2] 포트폴리오 내 혼합 증거 결정 비율 — [진행] HIGH

* 출처: True_Log [27] Section 2 Skeptic 제안
* 내용: 실제 프로젝트 의사결정 10-15건을 분류하여, 혼합 증거(mixed evidence) 결정이 전체 중 몇 %인지 측정.
* 측정: 결정 유형별 분포 (clear / mixed / sparse / conflicted)
* 성공 기준: ≥25% mixed → CPAS 적용 범위 충분. <20% → CPAS는 니치 도구.
* 현황: TTS 프로젝트 12건 분류 완료 → mixed 3건(25%, 기준선 도달), non-clear 전체 6건(50%). D-5(conflicted), D-2(mixed) 토의 검증 2건, 나머지 10건은 오케스트레이터 수동 분류(미검증). CPAS 내부 데이터 정상 경로([28] RQ-5)에서도 mixed 1건 확인 (n=1). 단, TTS 토의는 외부 데이터 수동 주입 경로 → 정상 필터 경로와 신뢰도 차이. D8/D9는 미검증 mixed로 토의 시 clear 전환 가능성 있음 → mixed 비율 하락 리스크.
* 내부 경로 추가 증거 (세션 #11): RQ-1~5 자체가 내부 정상 경로 sandbox 토의([22],[27])에서 결론 미도출로 파생 = mixed의 정의. 외부 주입(TTS)보다 신뢰도 높음. 단 동일 토의 동시 파생이므로 독립 결정 포인트 5건으로 세기엔 과대 계상 우려.
* 쟁점 재정의 (세션 #11): 진짜 질문은 "mixed 비율이 충분한가?"가 아니라 **"CPAS가 mixed → clear 전환을 달성할 수 있는가?"**. 현재 전환 증거: D-5(conflicted→clear), D-2(mixed→clear), [28] RQ-5(mixed→clear) = 3건 전부 전환 성공. 단 D-5/D-2는 외부 경로, [28]만 내부 경로(n=1).
* 세션 #12 sandbox [30] 결론: 양측 합의로 "mixed 비율 < 전환 능력" 확정. 그러나 전환의 인과성 미입증 — outcome verification ≠ process causation. Path A(CPAS) vs Path B(단일 에이전트) vs Path C(앙상블) 비교 실험이 유일한 검증 경로. Debate-induced overconfidence (72.9%→83.3%, arXiv 2505.19184)가 전환 관찰을 왜곡할 가능성.
* 관련: True_Log [27], MasterLog [29], [28], MasterLog [30]

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

## [RQ-6] Path A vs Path B vs Path C 비교 실험 — [대기] HIGH

* 출처: MasterLog [30] 양측 합의, 세션 #12
* 내용: 동일 mixed-evidence 문제에 대해 (A) CPAS Advocate/Skeptic 토의, (B) 단일 에이전트 분석, (C) 3 독립 에이전트 앙상블 투표를 병렬 실행. CPAS가 단일/앙상블 대비 mixed→clear 전환에서 우위를 보이는지 검증.
* 측정: (1) 분류 정확도 — 각 경로의 {mixed, clear} 분류가 ground truth와 일치하는 비율, (2) 불확실성 검출 — 실제 uncertain 주장에 높은 불확실성 배정 여부, (3) 사후 정확도 소급 — 결론의 사실적 정확성
* 성공 기준: CPAS(Path A) > Path B AND Path C 각 5% 이상 우위 (분류 정확도 기준). 동등 시 CPAS는 비싼 문서화.
* 설계 조건 (Skeptic 요구): (a) fresh uncontaminated evidence (기존 D-5/D-2 재사용 금지), (b) 검증 가능한 결과(ground truth)를 가진 사례만 사용, (c) 과신 방지 메커니즘 포함 권장
* 의존: RQ-1 결과에 따라 우선순위 상향 가능
* 관련: MasterLog [30], RQ-1, RQ-2

## [RQ-7] CPAS 과신 방지 메커니즘 설계 — [대기] MEDIUM

* 출처: MasterLog [30] 분리 쟁점, 세션 #12
* 내용: 2025 연구에서 확인된 debate-induced overconfidence (72.9%→83.3%)를 CPAS 환경에서 완화하는 메커니즘 설계 및 검증.
* 후보 메커니즘: (1) Self red-teaming — 에이전트가 자기 논증의 약점을 명시적으로 탐색, (2) Confidence hiding — S태그를 상대에게 공개하지 않음 (현재 이미 블랙박스이나 효과 미측정), (3) Validity weighting — 주장 강도가 아닌 증거 검증가능성 기반 가중치
* 측정: 메커니즘 적용 전/후 과신 에스컬레이션 비율 비교 (S태그 시계열 분석)
* 성공 기준: 과신 에스컬레이션 감소 (양측 최종 S 편차 < ±3), 토의 품질(C축) 유지
* 관련: MasterLog [30], arXiv 2505.19184

## [RQ-8] "Moral Cover" 리스크 평가 — Choice B 배포 조건 — [대기] MEDIUM

* 출처: MasterLog [30] 분리 쟁점, 세션 #12
* 내용: 구조화된 토의 문서(CPAS 보고서)가 stakeholder에게 "형식적 엄격함" 인상을 주어, 나쁜 결정에 거짓 정당성을 부여하는 "moral cover" 효과를 검증.
* 측정: Choice B 파일럿 3건에서 (a) stakeholder 확신도와 (b) 결정 사후 정확도 간 상관 분석. 확신도↑이면서 정확도↓이면 moral cover 효과 확인.
* 성공 기준: 확신도-정확도 양의 상관 또는 무상관 → moral cover 리스크 낮음. 음의 상관 → 배포 전 과신 방지 메커니즘 필수.
* 의존: Choice B 파일럿 실행 (RQ-5)
* 관련: MasterLog [30], RQ-5, RQ-7

================================================================================
