# Tag Protocol Reference — Cowork_CPAS v0.9.18

## 5-Axis Meta Tag System

Advocate and Skeptic use the SAME 5 axes but with DIFFERENT anchor definitions and ranges.
Tags are role-specific — the same axis measures different things for each role.

### Advocate Tag Format
```
[D-{level}] [R-{1-19}] [C-{1-13}] [A-{1-13}] [S-{1-19}]
```

### Skeptic Tag Format
```
[D-{level}] [R-{1-13}] [C-{1-19}] [A-{1-13}] [S-{1-19}]
```

---

## D — Debate Temperature (shared, both roles)

{D is an independent frame representing the current debate state. D is determined by the combination of current R,C,A,S values.}

- D-LL. [Introduction]
- D-L. [Fact Exchange]
- D-ML. [Rising Tension]
- D-M. [Claim Collision]
- D-MH. [Escalation]
- D-H. [Overheating]
- D-HH. [Deadlock]
- D-Q. [Final Statement]
  ≤1 use per session. Only available when the orchestrator explicitly unlocks it.

## S — Stamina [1-19] (shared, both roles)
Anchors: 1 (surrender), 4 (weak position), 7 (even), 10 (confident with evidence), 13 (strong evidence), 16 (overwhelming evidence), 19 (proven beyond debate)

---

## Advocate-Specific Axes

### R(Advocate) — Strategic Focus [1-19]
Measures: the Advocate's deliberate position on the depth-breadth spectrum.
This is a bidirectional axis — deep single-point focus (1) and comprehensive
connective expansion (19) at opposite ends, with strategic balance at center (10).
Neither extreme is inherently bad; the Advocate consciously navigates toward
whichever direction serves the argument better.

Anchors:
- 1: core penetration (drilling into a single argument to its conclusion)
- 4: analytical focus (core argument + directly related sub-issues simultaneously)
- 7: depth-breadth inflection (crossover point where depth and breadth intersect)
- 10: strategic balance (depth and breadth equally distributed)
- 13: multi-angle integration (illuminating the core from 3+ independent perspectives)
- 16: comprehensive overview (positioning the issue within project-wide / domain-level context)
- 19: full-spectrum exploration (consciously moving beyond the issue's boundaries to find new research directions and connection points)

### C(Advocate) — Claim Evidence [1-13]
Measures: strength of evidence SUPPORTING the Advocate's position.

Anchors:
- 1: no data, gut feeling, speculation
- 4: indirect evidence (analogies, similar cases, theoretical reasoning)
- 7: direct evidence (specific data, benchmarks, studies supporting the claim)
- 10: cross-verified from multiple independent sources
- 13: proven fact (True_Log confirmed, reproducible)

### A(Advocate) — Assertion Strength [1-13]
Measures: how strongly the Advocate is pushing the position forward.

Anchors:
- 1: neutral fact presentation, no directional push
- 4: assertion with supporting evidence
- 7: active defense against counterarguments
- 10: aggressive push, dismissing counter-evidence
- 13: completely stuck, repeating same claims without new evidence

---

## Skeptic-Specific Axes

### R(Skeptic) — Relevance [1-13]
Anchors: 1 (dead center on topic), 4 (directly related), 7 (derived topic), 10 (indirectly related), 13 (completely off-topic)

### C(Skeptic) — Counter-Evidence / Verification [1-19]
Measures: strength of evidence used to CHALLENGE, VERIFY, or REFUTE the Advocate's claims.
Expanded to 1-19 because Skeptic's verification work spans a wider range:
from gut-level suspicion to multi-source definitive refutation with historical proof.

Anchors:
- 1: gut suspicion, no specific counter-evidence ("something feels off")
- 4: indirect counter-evidence (analogies, similar failures, theoretical risk)
- 7: direct counter-evidence (specific data contradicting Advocate's claim)
- 10: cross-verified refutation (multiple independent sources confirming the flaw)
- 13: historically proven failure (Fail_Log + True_Log cross-reference confirms pattern)
- 16: multi-vector refutation (flaw confirmed from independent angles: internal logs + external research + live verification)
- 19: definitive debunk (Advocate's claim proven false beyond reasonable doubt — e.g., source verification reveals fabrication)

### A(Skeptic) — Rebuttal Intensity [1-13]
Measures: the depth and approach of the Skeptic's challenge.
Skeptic's natural operating mode is rebuttal, so anchors are calibrated accordingly.

Anchors:
- 1: clarification request, neutral questioning ("can you specify the source?")
- 4: structured counter-question with evidence request ("this contradicts X — explain?")
- 7: direct rebuttal with counter-evidence (Skeptic's standard operating mode)
- 10: multi-angle attack (challenging claim from multiple directions simultaneously)
- 13: complete dismantling with full evidence chain (every sub-claim addressed)

---

## Stripping Rules

For agent-to-agent transfer (Advocate ↔ Skeptic):
- Remove: `[D-?] [R-?] [C-?] [A-?] [S-?]` line
- Remove: `---` separator lines
- Pass: text content only

For orchestrator analysis:
- Keep everything (tags + separators + text)
- Include turn labels (=== Turn N: Agent ===)
- Note: Advocate R is 1-19, Skeptic R is 1-13. Advocate C is 1-13, Skeptic C is 1-19.
  For cross-role comparison on asymmetric axes, normalize to percentage.

## Orchestrator Tag Analysis Guide — 관찰자 분석 프레임

오케스트레이터는 태그를 기계적으로만 읽지 않는다. 전체 태그 시계열을 놓고
토의의 흐름, 전환점, 품질을 종합적으로 판단한다.

### 1. 시계열 패턴 읽기

태그는 개별 턴이 아닌 **궤적(trajectory)**으로 읽는다:

```
Turn 1 (Adv): [D-LL] [R-1]  [C-7]  [A-4]  [S-12]   (R/19, C/13)
Turn 2 (Skp): [D-LL] [R-1]  [C-7]  [A-4]  [S-10]   (R/13, C/19)
Turn 3 (Adv): [D-ML] [R-4]  [C-7]  [A-7]  [S-8]
Turn 4 (Skp): [D-M]  [R-4]  [C-13] [A-7]  [S-6]
Turn 5 (Adv): [D-M]  [R-1]  [C-10] [A-4]  [S-4]
Turn 6 (Skp): [D-L]  [R-1]  [C-10] [A-1]  [S-3]
```

이 패턴에서 읽어야 하는 것:
- S 궤적: 12→10→8→6→4→3 = 한쪽이 점진적으로 밀림 (급락 없이 자연 수렴)
- C 궤적: 역할별 다른 스케일 주의
  - Advocate C/13: 7→7→10 = 주장 근거 강화
  - Skeptic C/19: 7→13→10 = 반론 검증 수준 변동 (T4에서 Fail_Log 교차 참조 도달)
- R 궤적: 역할별 다른 의미 주의
  - Advocate R/19: 1→4→1 = 깊이 집중 전략 유지 (분석적 초점 → 핵심 회귀)
  - Skeptic R/13: 1→4→1 = 주제 집중 (논점 이탈 없음)
- D 전이: LL→LL→ML→M→M→L = 도입 → 긴장 고조 → 충돌 → 사실 교환 재합의

### 2. 전환점(Turning Point) 감지

토의에서 흐름이 바뀌는 순간을 포착:

- **S 급락** (10→4 또는 그 이상): 결정적 근거가 등장한 턴. 해당 턴의 상대방 C를 확인.
- **C 급등** (4→10 이상): 핵심 증거 제시. 이 근거가 토의를 지배하는지 후속 턴에서 확인.
  - Skeptic C-16+ 도달: 다중 벡터 반증 — Advocate 입장에 심각한 타격 가능
  - Skeptic C-19 도달: 결정적 반증 — Advocate 입장 사실상 붕괴
- **D 상승** (L→MH 이상): 과열 진입. 이 턴 이후의 내용은 감정이 섞일 수 있으므로 주의.
- **Advocate R 이동** (R-13+ 또는 R-1 장기 고정): 전략적 선택인지 확인. R-16+는 의식적 확장이면 정상, 표류이면 문제. R-1 고정은 깊이 집중이면 정상, 시야 협소면 문제.
- **Skeptic R 상승** (R-7+): 주제 이탈. 분리 쟁점 기록.

### 3. 토의 품질 종합 판정

단일 지표가 아닌 패턴 조합으로 판정:

**고품질 토의:**
- Advocate C가 최소 한 번 7+ 도달 (직접 근거 있음)
- Skeptic C가 최소 한 번 10+ 도달 (교차 검증된 반론 있음)
- S가 자연스럽게 수렴 (급락 없이 점진적 하강)
- D가 H/HH에 도달하지 않음
- Advocate R이 전략적으로 이동 (의식적 깊이↔폭 전환), Skeptic R≤7 (주제 집중)

**저품질 토의:**
- Advocate C가 4 이하 유지 (간접 근거만)
- Skeptic C가 7 이하 유지 (직접 반증 없이 감에 의존)
- S가 변동 없음 (양쪽 고집, 수렴 실패)
- D-H/D-HH 다수 등장 (감정적 과열/교착)
- Advocate R 무질서 이동 (전략 없이 산만), Skeptic R 불안정 (잦은 주제 이탈)

**편향 토의:**
- 한쪽 S만 하락, 다른 쪽 유지/상승 (일방적)
- C 격차 큼 (한쪽만 강한 근거 보유)
- 이 경우 열세 측에 불균형 보고 고려

### 4. 분석 보고 시 핵심 원칙

- **사실과 판단을 분리**: "Advocate S가 12에서 4로 하락했다"(사실) vs "Skeptic의 근거가 더 강했다"(판단)
- **판단의 근거를 명시**: "Skeptic이 Turn 4에서 C-13 근거를 제시한 후 Advocate S가 급락"
- **불확실성 인정**: "양쪽 C가 비슷하여 근거 우위를 판정하기 어려움"
- **비대칭 축 명시**: Advocate R/19 vs Skeptic R/13, Advocate C/13 vs Skeptic C/19
- **내용 불간섭 재확인**: 분석은 태그 패턴 + 논증 구조에 대한 것이지, "어느 쪽 주장이 옳다"가 아님
  (단, [오케스트레이터 평가]에서는 근거 강도 기반 권고 가능)
