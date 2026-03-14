# Tag Protocol Reference — Cowork_CPAS v0.9

## 5-Axis Meta Tag System

Every Advocate and Skeptic turn outputs tags in this format:
```
[D-{level}] [R-{1-13}] [C-{1-13}] [A-{1-13}] [S-{1-19}]
```

### D — Debate Temperature
- D-L: Fact exchange. Calm evidence presentation.
  - Ref: R-1~4 + C-4~13 + A-1~4 + S-10~19
- D-M: Claim collision. Arguments and rebuttals.
  - Ref: R-1~7 + C-2~10 + A-4~9 + S-4~13
- D-H: Overheating. Topic drift, weakened evidence, rigid attitude.
  - Ref: R-5~13 + C-1~7 + A-7~13 + S-1~7

### R — Relevance [1-13]
Anchors: 1 (dead center on topic), 4 (directly related), 7 (derived topic), 10 (indirectly related), 13 (completely off-topic)

### C — Confidence/Evidence [1-13]
Anchors: 1 (no data/gut feeling), 4 (indirect evidence), 7 (direct evidence), 10 (cross-verified multiple sources), 13 (proven fact from True_Log)

### A — Attitude [1-13]
Anchors: 1 (neutral fact statement), 4 (assertion with evidence), 7 (rebuttal with evidence), 10 (emotional rebuttal), 13 (completely stuck/repeating)

### S — Stamina [1-19]
Anchors: 1 (surrender), 4 (weak evidence), 7 (even), 10 (confident with evidence), 13 (strong evidence), 16 (overwhelming evidence), 19 (proven beyond debate)

## Stripping Rules

For agent-to-agent transfer (Advocate ↔ Skeptic):
- Remove: `[D-?] [R-?] [C-?] [A-?] [S-?]` line
- Remove: `---` separator lines
- Pass: text content only

For orchestrator analysis:
- Keep everything (tags + separators + text)
- Include turn labels (=== Turn N: Agent ===)

## Orchestrator Tag Analysis Guide — 관찰자 분석 프레임

오케스트레이터는 태그를 기계적으로만 읽지 않는다. 6턴 전체의 태그 시계열을 놓고
토의의 흐름, 전환점, 품질을 종합적으로 판단한다.

### 1. 시계열 패턴 읽기

태그는 개별 턴이 아닌 **궤적(trajectory)**으로 읽는다:

```
Turn 1: [D-L] [R-1] [C-7]  [A-4]  [S-12]
Turn 2: [D-L] [R-1] [C-4]  [A-4]  [S-10]
Turn 3: [D-M] [R-4] [C-7]  [A-7]  [S-8]
Turn 4: [D-M] [R-4] [C-10] [A-7]  [S-6]
Turn 5: [D-M] [R-1] [C-10] [A-4]  [S-4]
Turn 6: [D-L] [R-1] [C-7]  [A-1]  [S-3]
```

이 패턴에서 읽어야 하는 것:
- S 궤적: 12→10→8→6→4→3 = 한쪽이 점진적으로 밀림 (급락 없이 자연 수렴)
- C 궤적: 7→4→7→10→10→7 = 근거 수준이 오르내림 (중반에 핵심 근거 등장)
- D 전이: L→L→M→M→M→L = 초반 사실 교환 → 중반 충돌 → 후반 재합의
- R 변동: 1→1→4→4→1→1 = 중반에 파생 주제 발생 → 본 주제로 복귀

### 2. 전환점(Turning Point) 감지

토의에서 흐름이 바뀌는 순간을 포착:

- **S 급락** (10→4 또는 그 이상): 결정적 근거가 등장한 턴. 해당 턴의 상대방 C를 확인.
- **C 급등** (4→10 이상): 핵심 증거 제시. 이 근거가 토의를 지배하는지 후속 턴에서 확인.
- **D 상승** (L→H): 과열 시작점. 이 턴 이후의 내용은 감정이 섞일 수 있으므로 주의.
- **R 상승** (1~4→7+): 주제 이탈 시작. 이탈된 주제를 [분리 쟁점]으로 기록.

### 3. 토의 품질 종합 판정

단일 지표가 아닌 패턴 조합으로 판정:

**고품질 토의:**
- 양쪽 C가 최소 한 번 7+ 도달 (직접 근거 있음)
- S가 자연스럽게 수렴 (급락 없이 점진적 하강)
- D가 H에 도달하지 않음
- R이 4 이내 유지 (주제 집중)

**저품질 토의:**
- 양쪽 C가 3 이하 유지 (근거 없는 주장 대결)
- S가 변동 없음 (양쪽 고집, 수렴 실패)
- D-H 다수 등장 (감정적 과열)
- R이 7+ 다수 (주제 이탈)

**편향 토의:**
- 한쪽 S만 하락, 다른 쪽 유지/상승 (일방적)
- 한쪽 C만 높음 (근거 격차)
- 이 경우 열세 측에 확장사고 활성화 고려

### 4. 분석 보고 시 핵심 원칙

- **사실과 판단을 분리**: "Advocate S가 12에서 4로 하락했다"(사실) vs "Skeptic의 근거가 더 강했다"(판단)
- **판단의 근거를 명시**: "Skeptic이 Turn 4에서 C-10 근거를 제시한 후 Advocate S가 급락"
- **불확실성 인정**: "양쪽 C가 비슷하여 근거 우위를 판정하기 어려움"
- **내용 불간섭 재확인**: 분석은 태그 패턴 + 논증 구조에 대한 것이지, "어느 쪽 주장이 옳다"가 아님
  (단, [오케스트레이터 평가]에서는 근거 강도 기반 권고 가능)
