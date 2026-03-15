# .context/research_queue.md — 연구과제 큐

토의에서 파생된 미검증 항목. 사용자가 증명/실험하여 프로젝트를 진행하기 위한 큐.
우선순위: HIGH → MEDIUM → LOW. 상태: [대기] / [진행] / [완료] / [폐기]

================================================================================

## [RQ-1] ET + Fail_Log context vs CPAS 직접 비교 — [진행] HIGH

* 출처: True_Log [27] v0.9.4 벤치마크, Section 3 Skeptic 제안
* 내용: 동일 의사결정 문제를 (A) CPAS, (B) ET + Fail_Log context, (C) ET + skeptical prompt로 병렬 실행. CPAS 고유 가치가 있는지 분리 측정.
* 측정: C축 (근거 품질), S축 (수렴 속도), 구체성 커밋 수
* 성공 기준: CPAS가 B/C 대비 명확한 우위 → CPAS 고유 가치 확인. B/C가 동등 → CPAS는 불필요한 복잡성.
* 현황: 4차 실험 완료 (MasterLog [33]). RQ-1+RQ-9 결합 토의 — 양방향 교차 교정 구조적 속성 + 오케스트레이터 개입 위험도.
  - 1차(CPAS 실용성): CPAS R-4이상 18.75%, ET-only 42.1%. 결론 방향 일치. CPAS 고유 가치="깊이+집중 vs 넓이+정량".
  - 3차(Self red-teaming): CPAS R-4이상 **0%**, ET-only **~17%**. **결론 불일치** — CPAS "기각", ET "강화". 불일치 원인: CPAS 양방향 교차 교정 — Advocate 환각을 Skeptic이 교정(T13→T14→T15). D-2에서는 Skeptic 오류를 Advocate가 교정(S2-T11). ET-only에서는 교정 상대 부재.
  - 4차(구조적 속성): **양측 합의 — 양방향 교차 교정은 구조적 속성** ("구조적 vs 우연" 논쟁 종결). **미합의 — 충분성 범위**: Advocate=도메인별 조건부, Skeptic=복잡도 의존적 보편 열화. 3-track 테스트 설계 합의. Skeptic 자체 환각(T10,12,14)=Type-X 오류 증거.
  - **4차 ET-only 비교 완료**: 결론 방향 일치 (3차 불일치→4차 일치). 양쪽 모두 "구조적 속성 + 사후 검증 필수"에 도달. CPAS 우위: 반론 커버리지(measurement confound, propagation risk, complexity degradation — ET 미등장), 3-track 구체 설계, Type-X 자기발견. ET 고유: E_structural 분류, Semantically Rich Specs 제안. 아이디어 수 대등(5:5)이나 CPAS는 16턴 검증, ET는 단일 패스 나열. 비용: CPAS ~600K vs ET ~80K 토큰.
  - CPAS 고유 가치 정밀화: (1) R축 수렴 강제력, (2) **양방향 교차 교정(bidirectional cross-correction)** — 구조적 속성 확정(양측 합의), (3) ⚠ 복잡도 의존적 한계 — 고복잡도에서 교차 교정 열화 가능성.
  - R축 패턴 일관: CPAS=깊이+집중(R-1 고정), ET=넓이+확장(권고/실험 설계로 파생).
  - ⚠ n=3(비교 가능 실험, 4회 비교). 4차에서 구조적 속성 합의 + ET-only와 결론 방향 일치. 충분성은 미해결. 외부 주제 추가 + 3-track 테스트로 진전 가능.
  - **누적 패턴 (4회 비교)**: 1차 일치, 3차 불일치, 4차 일치. R축 4회 연속 동일(CPAS=깊이 R-1~4, ET=넓이 R-3~6). CPAS 고유 가치 최종: (1) R축 수렴 강제력, (2) 양방향 교차 교정(구조적 확정), (3) 반론 검증 robustness, (4) Type-X 자기발견.
* 관련: [26], True_Log [21][27][31][32], MasterLog [28][30][33]

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

## [RQ-7] CPAS 과신 방지 메커니즘 설계 — [진행] MEDIUM

* 출처: MasterLog [30] 분리 쟁점, 세션 #12
* 내용: 2025 연구에서 확인된 debate-induced overconfidence (72.9%→83.3%)를 CPAS 환경에서 완화하는 메커니즘 설계 및 검증.
* 후보 메커니즘: ~~(1) Self red-teaming — 에이전트가 자기 논증의 약점을 명시적으로 탐색~~ **(기각 — MasterLog [31] 토의 합의. 블랙박스 원칙과 충돌, 게이밍 압력 생성)**, (2) Confidence hiding — S태그를 상대에게 공개하지 않음 (현재 이미 블랙박스이나 효과 미측정) **(블랙박스 유지 확정)**, ~~(3) Validity weighting — 주장 강도가 아닌 증거 검증가능성 기반 가중치~~ **(미검토, 별도 토의 필요)**
* **확정 방향 (MasterLog [31])**: Path B — 사후 블랙박스 모니터링 + between-episode 시스템 조정. (1) 사후 S-tag 패턴 분석, (2) acceptance threshold 조정, (3) Skeptic evidence weighting. within-episode 투명 모니터링/피드백은 기각.
* 측정: 메커니즘 적용 전/후 과신 에스컬레이션 비율 비교 (S태그 시계열 분석)
* 성공 기준: 과신 에스컬레이션 감소 (양측 최종 S 편차 < ±3), 토의 품질(C축) 유지
* 현황: MasterLog [31] 토의 완료. Self red-teaming 전 형태 기각, Path B 확정. Advocate T13 허위 인용(Table 3)이 투명 모니터링의 게이밍 압력 실증. 남은 과제: (a) Path B n=5 실증, (b) between-episode 피드백의 게이밍 여부 검증, (c) defensive fabrication 빈도 측정.
* 관련: MasterLog [30][31], arXiv 2505.19184, arXiv 2505.14617, arXiv 2507.01786, Fail_Log [16]

## [RQ-8] "Moral Cover" 리스크 평가 — Choice B 배포 조건 — [대기] MEDIUM

* 출처: MasterLog [30] 분리 쟁점, 세션 #12
* 내용: 구조화된 토의 문서(CPAS 보고서)가 stakeholder에게 "형식적 엄격함" 인상을 주어, 나쁜 결정에 거짓 정당성을 부여하는 "moral cover" 효과를 검증.
* 측정: Choice B 파일럿 3건에서 (a) stakeholder 확신도와 (b) 결정 사후 정확도 간 상관 분석. 확신도↑이면서 정확도↓이면 moral cover 효과 확인.
* 성공 기준: 확신도-정확도 양의 상관 또는 무상관 → moral cover 리스크 낮음. 음의 상관 → 배포 전 과신 방지 메커니즘 필수.
* 의존: Choice B 파일럿 실행 (RQ-5)
* 관련: MasterLog [30], RQ-5, RQ-7

## [RQ-9] 교차 교정 작동 범위 및 최적 모니터링 아키텍처 검증 — [진행] HIGH

* 출처: MasterLog [31] 분리 쟁점 (세션 #13) → MasterLog [33] 토의로 재정의 (세션 #15)
* 기존 정의: "인용 검증 메커니즘 — LLM 환각 감지 방법" (LOW)
* **재정의 (MasterLog [33])**: 양방향 교차 교정의 작동 범위(도메인/복잡도)를 측정하고, 자정작용이 부족한 영역에서의 최적 모니터링 아키텍처를 검증.
* 내용:
  - 양방향 교차 교정은 구조적 속성 (양측 합의, [33]) — 그러나 충분성은 보편적이지 않음
  - Advocate: 도메인별 조건부 충분성 (법률/의학=낮음, SW/전략=높음)
  - Skeptic: 복잡도 의존적 보편 열화 (인용 정확도가 복잡도에 따라 모든 도메인에서 단조 감소)
  - Type-X 오류(양측 미감지) 발견: [33] Skeptic T10/12/14에서 존재하지 않는 Episode 데이터 인용 — Advocate 미감지
  - 기존 자정작용 성공 사례: [31] T13 환각→T14 검증→T15 인정 (3턴 소비)
  - 기존 자정작용 실패 사례: [33] Skeptic T10/12/14 환각 — Advocate 미감지 (Type-X)
* **3-track 테스트 설계 (양측 합의, [33])**:
  - Track A (bluegreen/무감독): 현재 블랙박스 그대로. 자정작용만 의존.
  - Track B (실시간 비평가적 salience flags): 인용 신뢰도 LOW/MED/HIGH 태그를 에이전트에게 표시. 평가 아님, metacognitive 활성화 목적.
  - Track C (async 30% 사후 감사): 2-에피소드 지연 후 30% 랜덤 감사. between-episode 피드백.
  - 측정: Type-X 발생률, 도메인/복잡도 클러스터링, 전파 카운트
  - 규모: 5 에피소드 × 3 track = 15 에피소드 (축소 버전) 또는 20 에피소드 × 3 track (풀 버전)
* ⚠ 핵심 제약 유지: 오케스트레이터 실시간 내용 개입은 블랙박스 원칙 위반 — 기각. Track B는 "비평가적 신호"로 제한.
* **v0.9.11 부분 해결 — 내부 데이터 무결성 검사 (MasterLog [34])**:
  - Haiku 필터 무관 확인 — 필터가 "Episode"를 제공한 적 없음. Skeptic의 순수 LLM 환각 (citation format contamination).
  - 근본 원인: v0.9.4 Advocate 재설계(Accept→Redirect→Propose)로 토의 안정성 확보하되 인용 검증 능력 상실 → Skeptic 오류 미감지(Type-X)
  - 해결: 오케스트레이터가 교환 간에 {FILTERED_DATA} 대비 내부 데이터 인용 존재 여부 확인
  - 양방향 대칭 (양쪽 에이전트 동일 적용) + 자정작용 우선 (상대가 잡으면 개입 안 함)
  - 내용 불간섭 원칙 유지 — "데이터 존재 확인"만, 논리/품질 판단 아님
  - 이것은 3-track 테스트와 별개 — 현재 아키텍처의 즉시 적용 가능한 안전장치
* 측정: (1) Type-X 발생률 (도메인/복잡도별), (2) Track A/B/C 간 환각 감지율 차이, (3) Track B의 metacognitive 활성화 효과, (4) v0.9.11 DATA_CHECK 개입 빈도 및 자정작용 대비 효과
* 성공 기준: Track A(자정작용만)의 Type-X < 10% → 현행 충분. Track B가 Track A 대비 유의미한 개선 → salience flags 채택. Track C가 Track A 대비 개선 → async audit 채택. v0.9.11 DATA_CHECK가 Type-X를 감소시키는지 별도 측정.
* 의존: 추가 sandbox 에피소드 축적 필요 (15~60 에피소드)
* 사용자 확인 대기: (1) 테스트 규모(축소 vs 풀), (2) salience flags 포함 여부
* 관련: MasterLog [31][33][34], RQ-7, Fail_Log [16], True_Log [22][27]

## [RQ-10 후보] Metacognitive Salience Shifting 메커니즘 — [대기] LOW

* 출처: MasterLog [33] 분리 쟁점, 세션 #15
* 내용: 비평가적 신호(salience flags 등)가 LLM의 자기검출 루프(metacognitive self-monitoring)를 활성화하는지 검증. arxiv 2505.13763 참조.
* 배경: Track B에서 인용 신뢰도 LOW/MED/HIGH 태그가 에이전트의 인용 검증 행동을 변화시키는지 측정. 게이밍 없이 자연스러운 주의 재배분(salience shifting)만 유도하는 것이 목표.
* 측정: Track B 에이전트의 인용 재확인 비율 vs Track A 기준선
* 성공 기준: Track B에서 인용 재확인 비율 상승 + 게이밍(방어적 허위 인용) 미발생
* 의존: RQ-9 3-track 테스트 실행
* 관련: MasterLog [33], RQ-9, arXiv 2505.13763

## [RQ-11 후보] 복잡도 의존적 교차 교정 열화 곡선 — [대기] MEDIUM

* 출처: MasterLog [33] 분리 쟁점, 세션 #15
* 내용: CPAS 양방향 교차 교정의 효과가 주제 복잡도에 따라 어떻게 변화하는지 측정. Skeptic 주장(복잡도 의존적 보편 열화)의 CPAS 환경 검증.
* 배경: Tool-MAD, ICLR 2025 연구에서 인용 정확도가 복잡도에 따라 단조 감소하는 패턴 확인. CPAS 환경에서도 동일 패턴이 재현되는지, 교차 교정이 이 열화를 완화하는지 측정.
* 측정: 복잡도 수준별(단순/중간/복잡) sandbox 토의에서 (1) 환각 발생률, (2) 교차 교정 성공률(감지→교정 비율), (3) Type-X 발생률
* 성공 기준: 교차 교정 성공률이 복잡도 증가에도 안정적(편차 < 15%) → CPAS 교차 교정이 복잡도 열화를 완화. 성공률이 복잡도와 함께 하락 → 고복잡도 보완 메커니즘 필요.
* 의존: 복잡도 수준 정의 + 각 수준별 최소 3 에피소드
* 관련: MasterLog [33], RQ-9, RQ-1

## [RQ-12 후보] Entropy-based Uncertainty Quantification의 CPAS 적용 — [대기] MEDIUM

* 출처: MasterLog [37] 분리 쟁점, 세션 #18 (Advocate 세션 2 전략 전환 제안)
* 내용: CPAS 토의 결과를 불확실성 정량화(UQ)로 변환하는 Entropy-based 프레임워크 실현 가능성 검증. Advocate가 CPAS의 재정위로 제안 — Skeptic은 "이론적으로 유효하나 실행 검증 불가"로 반론.
* 측정: (1) CPAS 5축 태그에서 Entropy 지표 추출 가능성, (2) 추출된 UQ와 실제 결정 품질 간 상관, (3) 기존 UQ 방법론(Semantic Uncertainty 등) 대비 부가가치
* 성공 기준: CPAS 태그 기반 UQ가 결정 품질과 유의미한 상관 → 재정위 근거. 무상관 → 재정위 근거 부족.
* 의존: RQ-1 충분성 결론, RQ-9 3-track 결과
* 관련: MasterLog [37], RQ-1, RQ-9

## [RQ-13 후보] Monoculture Collapse 리스크 — 동일 LLM 기반 에이전트 다양성 — [대기] LOW

* 출처: MasterLog [37] 분리 쟁점, 세션 #18
* 내용: 동일 LLM(Opus)에서 파생된 Advocate/Skeptic의 인식론적 독립성이 실제로 존재하는지. "Bias in the Mirror"(ACL 2025) 지적: 같은 사전학습 편향을 공유하는 에이전트 간 토의는 편향 교정 불가.
* ⚠ 핵심 제약 (MAD 문헌): 이종 모델 도입 시 **능력 수준이 동등해야 함**. ICLR 2025 MAD 연구 — 약한 모델(예: 8B급)은 다수 압력에 굴복하여 오히려 성능 저하. "Stop Overvaluing MAD"(arXiv 2502.08788) — 내재적 추론 능력(intrinsic reasoning capability)이 MAD 성공의 핵심 드라이버이며, 능력 차이가 큰 이종 조합은 다양성이 아니라 품질 저하를 초래. 따라서 Opus ↔ Haiku 같은 능력 격차 큰 조합은 부적합하며, Opus ↔ 동급 외부 모델(GPT-4o, Gemini Ultra 등) 비교만 유효.
* 측정: (1) 동급 이종 모델(Opus vs 동급 외부 모델) 간 토의 결과 비교, (2) 동일 LLM 내 편향 상관도 측정
* 성공 기준: 동급 이종 모델 토의가 동종 대비 편향 감소 → 아키텍처 변경 필요. 차이 미미 → 현행 유지.
* 의존: RQ-4(하위 모델 품질 — 능력 하한선 확인), 동급 이종 모델 접근 가능성
* 관련: MasterLog [37], RQ-4, "Bias in the Mirror" ACL 2025, ICLR 2025 MAD Blog, arXiv 2502.08788

================================================================================
