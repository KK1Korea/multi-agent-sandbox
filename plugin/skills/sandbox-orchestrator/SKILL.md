---
name: sandbox-orchestrator
description: >
  This skill should be used when the user triggers "/sandbox", asks to
  "run a sandbox debate", "debate this topic", "get both sides on this",
  or needs a structured multi-agent discussion for high-stakes decisions.
  Orchestrates Advocate and Skeptic agents directly in a 2-level architecture.
  The orchestrator controls the debate loop, strips tags, analyzes quality,
  detects imbalance, and produces the final structured report.
version: 0.9.7
---

# Sandbox Debate Orchestrator — Cowork_CPAS v0.9.7

The orchestrator handles ALL phases: pre-debate setup, debate loop control, and post-debate analysis.
No Observer agent. The orchestrator directly spawns Advocate/Skeptic and performs observation + judgment.

Architecture: Main (Orchestrator) → {Advocate, Skeptic, MasterLog-Filter, TrueLog-Filter, FailLog-Filter} — 2-level only.

## Phase 1 — Pre-Debate Setup

### Step 0 — Workspace Structure Check

Check if the CPAS file structure exists in the workspace:
- Look for: `current_task.md`, `MasterLog.md`, `True_Log.md`, `Fail_Log.md`, `Dummy_Log/`, `CLAUDE.md`
- If ANY of these are missing → run the `workspace-init` skill first
  - Use the debate topic as the project name (ask user to confirm)
  - Wait for initialization to complete before proceeding

### Step 0.5 — Log Freshness Check

Before starting the debate, do a lightweight check on project log health:

1. **current_task.md freshness**: Read `[최종 갱신]` — is it 2+ sessions behind?
2. **MasterLog staleness**: Count entries with `[구상]`/`[진행]` tags older than 3 sessions.

**Actions:**
- If stale entries ≥ 3 OR current_task.md outdated:
  · Recommend: "프로젝트 로그가 오래됐습니다. 토의 전에 /review (cpas-manager)를 실행하시겠습니까?"
  · If user approves → user runs cpas-manager `/review` separately, then restart debate
  · If user declines → proceed normally (data filters will handle relevance anyway)
- If everything fresh → proceed silently

**IMPORTANT**: This is a lightweight check. Read headers/tags only — do NOT read full entry contents. Log classification is cpas-manager 플러그인의 역할이다.

### Step 1 — Memory & Live State Collection

Collect the project's live state for debate boundary context:

1. **Claude Memory** (built-in): Accumulated project context, user preferences, confirmed decisions. Automatically available.
2. **current_task.md `[지금 해야 할 일]`**: Current active tasks — the debate must stay relevant to these.

Combine into `{MEMORY_CONTEXT}` — concise summary of:
- Project identity and current phase
- Key constraints and confirmed decisions
- ★ `[작업 버전]`이나 `[로그 현황]`은 포함하지 않음 — 토의 쟁점 집중을 위해

Extract `{CURRENT_DIRECTION}` — current_task.md의 `[지금 해야 할 일]` 섹션 원문.
- 이 컨텍스트는 **Advocate에만** 전달됨 (Advocate의 방향 앵커)
- Skeptic에는 전달하지 않음 — Skeptic은 과거 데이터와 위험으로 독립 판단
- Advocate가 이 방향을 중심으로 토의를 진행하고, Skeptic의 지적을 수용하면서도 방향을 유지

### Step 2 — Data Filter Agents (Haiku, Parallel)

#### Step 2.0 — Volume Detection

Before spawning filter agents, detect how many log volumes exist:

```
Check workspace for log files:
  - MasterLog.md (always single file — overflow goes to Dummy_Log)
  - True_Log.md OR True_Log_1.md, True_Log_2.md, ...
  - Fail_Log.md OR Fail_Log_1.md, Fail_Log_2.md, ...
```

Rules:
- If `True_Log.md` exists (single file) → 1 truelog-filter agent
- If `True_Log_1.md`, `True_Log_2.md`, ... exist (volume split) → 1 truelog-filter agent PER volume
- Same logic for Fail_Log
- MasterLog is always 1 agent (overflow → Dummy, not volume split)
- Volume split trigger: any log file exceeding ~1500 lines

#### Step 2.1 — Spawn Filter Agents

**Base case (no volumes — most common):**

Spawn 3 filter agents in parallel:

**Agent 1: masterlog-filter**
```
Agent tool call:
  subagent_type: "cpas-sandbox:masterlog-filter"
  prompt: |
    Debate topic: {TOPIC}
    Read MasterLog.md and extract ONLY entries relevant to the debate topic.
    Deliver filtered results in your structured format.
```

**Agent 2: truelog-filter**
```
Agent tool call:
  subagent_type: "cpas-sandbox:truelog-filter"
  prompt: |
    Debate topic: {TOPIC}
    Read True_Log.md and extract ONLY entries relevant to the debate topic.
    Deliver filtered results in your structured format.
```

**Agent 3: faillog-filter**
```
Agent tool call:
  subagent_type: "cpas-sandbox:faillog-filter"
  prompt: |
    Debate topic: {TOPIC}
    Read Fail_Log.md and extract ONLY entries relevant to the debate topic.
    Deliver filtered results in your structured format.
```

**Volume case (when split files detected):**

Spawn 1 agent per volume file. Example with True_Log split into 2 volumes:

```
Agent tool calls (ALL in a SINGLE message):
  - masterlog-filter → MasterLog.md
  - truelog-filter (1) → prompt includes "Read True_Log_1.md" (NOT True_Log.md)
  - truelog-filter (2) → prompt includes "Read True_Log_2.md"
  - faillog-filter → Fail_Log.md
```

Each volume agent uses the SAME subagent_type (e.g., `cpas-sandbox:truelog-filter`)
but with a modified prompt specifying the exact volume filename to read.

IMPORTANT: Launch ALL agents in a SINGLE message (parallel execution).
Each agent reads only its assigned file — no overlap, no duplication.
Scaling rule: 1 file = 1 Haiku. Max ~1500 lines per file per agent.

#### Step 2.2 — Merge Filter Outputs

Capture all outputs and merge into `{FILTERED_DATA}`:
```
{truelog-filter output(s) — combine if multiple volumes}

{faillog-filter output(s) — combine if multiple volumes}

{masterlog-filter output}
```

Order: HIGH reliability first (True_Log, Fail_Log), then MEDIUM (MasterLog).
If multiple volumes exist for a log type, concatenate their outputs in volume order.

### Step 3 — Assess Internal Data Sufficiency

From merged filter outputs (count across all 3):
- **2+ relevant entries total** → sufficient
- **0-1 relevant entries total** → thin
- **All three report "No relevant data"** → search-only

### Step 4 — Load Tag Protocol (MANDATORY)

Before entering the debate loop, READ the tag protocol reference:
```
Read file: references/tag-protocol.md
```
(Relative to this skill's directory: `skills/sandbox-orchestrator/references/tag-protocol.md`)

This file contains:
- 5-axis tag definitions (D/R/C/A/S anchors and ranges)
- Tag stripping rules for agent-to-agent transfer
- **Orchestrator Tag Analysis Guide** — how to read tag time-series,
  detect turning points, assess debate quality, and report findings.

You MUST internalize this before running the debate loop.
Without it, tag analysis will be mechanical-only and miss pattern-level insights.

## Phase 2 — Debate Loop (Orchestrator Direct Control)

CRITICAL: The orchestrator runs the entire debate loop directly.
There is NO Observer agent. The orchestrator spawns Advocate and Skeptic,
strips tags, tracks quality, detects imbalance, and manages sections.

### Debate Structure (v0.9.7 — 8-Turn Format)

- Section 1 (Regular Debate): 3 Advocate↔Skeptic exchanges (6 turns)
- Section 2 (최후의 진술 / Final Statement): 1 Advocate + 1 Skeptic closing (2 turns)
- Total: 8 turns (down from 18 in v0.9.6)
- Section 1 uses FRESH agents. Section 2 RESUMES the same agents from Section 1.
- The orchestrator is the only entity with cross-section memory.

### Exchange Loop — Section 1 (Regular Debate)

Execute 3 exchanges (6 turns total):

**Exchange N (N = 1, 2, 3):**

1. **Spawn/Resume Advocate:**

   FIRST EXCHANGE of a section (spawn NEW agent):
   ```
   Agent tool call:
     subagent_type: "cpas-sandbox:advocate"
     prompt: |
       === PROJECT CONTEXT (non-debatable ground truth) ===
       {MEMORY_CONTEXT}
       === END CONTEXT ===

       === CURRENT DIRECTION (your north star) ===
       {CURRENT_DIRECTION}
       === END DIRECTION ===

       Debate topic: {TOPIC}
       You are arguing FOR this position. Drive the discussion toward the project's current goals.
       When the opponent raises valid concerns, acknowledge them and propose adjusted paths forward.

       OUTPUT FORMAT: Your response MUST begin with meta tags on the FIRST LINE:
       [D-{L/M/H}] [R-{1-13}] [C-{1-13}] [A-{1-13}] [S-{1-19}]
       ---
       (then your argument)
   ```

   Where {CURRENT_DIRECTION} is extracted from current_task.md `[지금 해야 할 일]` section.
   This gives the Advocate its project direction anchor — it argues not just "for" but "forward."

   SUBSEQUENT EXCHANGES within same section (resume same agent):
   ```
   Agent tool call:
     resume: {advocate_agent_id from previous call}
     prompt: |
       Your opponent responds:
       ---
       {stripped Skeptic text from previous exchange}
       ---
       Address their concerns and drive the discussion forward.
   ```

   ※ v0.9.7: No multi-section fresh spawns. Section 2 is Final Statement (resume same agent).

2. **Capture Advocate's full raw output** (tags + text). Store it.

3. **Extract the meta tag line:**
   Pattern: `[D-?] [R-?] [C-?] [A-?] [S-?]`
   Record in tag time-series tracker.

4. **Strip tags and separators** → clean text for Skeptic.

   Tag Stripping Rules:
   - Remove line matching: `[D-[LMH]] [R-\d+] [C-\d+] [A-\d+] [S-\d+]`
   - Remove `---` separator lines (lines that are exactly `---`)
   - Pass only remaining text content

5. **Spawn/Resume Skeptic:**

   FIRST EXCHANGE of a section (spawn NEW agent):
   ```
   Agent tool call:
     subagent_type: "cpas-sandbox:skeptic"
     prompt: |
       === PROJECT CONTEXT (non-debatable ground truth) ===
       {MEMORY_CONTEXT}
       === END CONTEXT ===

       Debate topic: {TOPIC}
       You are arguing AGAINST this position.

       Your opponent's opening argument:
       ---
       {stripped Advocate text}
       ---

       Internal data for your use:
       Assessment: {sufficient / thin / search-only}
       {FILTERED_DATA}

       OUTPUT FORMAT: Your response MUST begin with meta tags on the FIRST LINE:
       [D-{L/M/H}] [R-{1-13}] [C-{1-13}] [A-{1-13}] [S-{1-19}]
       ---
       (then your argument)

       Present your counterargument.
   ```

   SUBSEQUENT EXCHANGES within same section (resume same agent):
   ```
   Agent tool call:
     resume: {skeptic_agent_id from previous call}
     prompt: |
       Your opponent responds:
       ---
       {stripped Advocate text from this exchange}
       ---
       Present your counterargument.
   ```

6. **Capture Skeptic's full raw output** (tags + text). Store it.

7. **Extract and store the meta tag line** in tracker.

8. **Strip tags and separators** → clean text for next Advocate exchange.

After 3 exchanges: compile all 6 turns with UNSTRIPPED outputs for analysis.

**REMINDER: Every Advocate/Skeptic turn MUST be an Agent tool call.
The orchestrator produces ZERO debate content. It only strips tags, stores tags, and analyzes.**

### Section 2 — 최후의 진술 (Final Statement)

After Section 1's 3 exchanges, assess imbalance (see below), then run the Final Statement phase.

The Final Statement is injected by RESUMING the same agents from Section 1 with a special prompt prefix.
This is NOT a new section with fresh agents — it continues the same debate context.

**Turn 7 — Advocate Final Statement:**
```
Agent tool call:
  resume: {advocate_agent_id from Section 1}
  prompt: |
    [최후의 진술 단계] 이 토의의 마지막 턴입니다.
    자신의 핵심 논점 + 상대방의 유효한 논점을 종합하여 최종 입장을 진술하세요.
    반드시 WebSearch를 수행하여 최종 입장을 뒷받침하는 최신 근거를 확보하세요.
    태그 기준: C-10, R-1~4, S-7, A-7~11

    Your opponent's last argument:
    ---
    {stripped Skeptic text from Exchange 3}
    ---

    Present your FINAL STATEMENT — synthesize both positions and declare your conclusion.
```

**Turn 8 — Skeptic Final Statement:**
```
Agent tool call:
  resume: {skeptic_agent_id from Section 1}
  prompt: |
    [최후의 진술 단계] 이 토의의 마지막 턴입니다.
    자신의 핵심 논점 + 상대방의 유효한 논점을 종합하여 최종 입장을 진술하세요.
    반드시 WebSearch를 수행하여 최종 입장을 뒷받침하는 최신 근거를 확보하세요.
    태그 기준: C-10, R-1~4, S-7, A-7~11

    Your opponent's final statement:
    ---
    {stripped Advocate final text from Turn 7}
    ---

    Present your FINAL STATEMENT — synthesize both positions and declare your conclusion.
```

After both Final Statements: compile all 8 turns with UNSTRIPPED outputs for final analysis.

### Section Transition Rules (v0.9.7)

**After Section 1 (6 turns), before Final Statement:**

1. Structure issues from the 6 turns (see Phase 3 format).
2. Assess imbalance:
   - Criteria (ANY triggers imbalance):
     · One side's S ≤ 4 for 2+ consecutive turns while the other's S ≥ 10
     · One side reached S-1 or S-2 (surrender/near-surrender)
     · One side's C consistently ≤ 3 while the other's C ≥ 7 (evidence gap)
   - If Imbalanced:
     · ⚠ MANDATORY: Ask the user for approval before activating Extended Thinking.
     · Format: "불균형 감지: {side} 열세 (S≤4 연속). 확장사고를 활성화하면 토큰 비용이 ~2-3배 증가합니다. 최후의 진술에 활성화할까요?"
     · If approved: Activate Extended Thinking for the losing side's Final Statement.
     · If denied: Proceed with standard Opus for both sides.
     · This is environment adjustment, not content intervention.
3. Proceed to Section 2 (최후의 진술) — RESUME same agents (do NOT spawn fresh).

**After Section 2 (Final Statements, 2 turns):**

1. Final issue structuring incorporating all 8 turns.
2. Compare Section 1 trajectory with Final Statement conclusions.
3. Produce final report.

### Tag Reading Criteria

- R, C, A: 1-13 spectrum. Anchors: 1, 4, 7, 10, 13.
- S: 1-19 spectrum. Anchors: 1, 4, 7, 10, 13, 16, 19.
- D: L (fact exchange), M (claim collision), H (overheating).

### Convergence Assessment

- Both S ≤ 4 → Converged. Structure issues.
- One side S ≤ 2 → Converged by evidence exhaustion.
- Both S remain ≥ 10 throughout → Issue not separated. More structuring needed.

### Problem Detection

- One side S drops sharply (10 → 4 or below) → Evidence exhausted. Note weakness.
- R reaches 7+ → Topic drift occurred. Record as separated issue.
- D-H reached → Overheating. Extract core issue only.
- Both C are 1~3 → Insufficient evidence debate. Record in [Unverified Items].

## Phase 3 — Post-Debate Processing

### Present Results

Produce and present the structured analysis directly to the user.

**Output Structure:**

```
[Core Issue]
(The central point of conflict between both sides, 1-2 lines)

[Advocate Evidence]
· Claim summary (1-2 lines)
· Evidence source + reliability (high/medium/low)

[Skeptic Evidence]
· Counterargument summary (1-2 lines)
· Evidence source + reliability (high/medium/low)

[Key Difference]
(The single variable that divides both sides, 1 line)

[Unverified Items]
(What neither side could verify)

[Separated Issues]
(Issues that emerged during debate but are separate from the original topic)
→ research_queue registration candidates

[User Decision Needed]
(Questions only the user can answer)

[Debate Quality]
· Sections: Section 1 (Regular 6T) + Section 2 (Final Statement 2T) = 8 turns
· Convergence: converged / not converged / partially converged
· Evidence balance: balanced / Advocate advantage / Skeptic advantage
· Tag time-series summary:
  Advocate S trajectory: [S-12] → [S-10] → [S-7]
  Skeptic S trajectory: [S-10] → [S-8] → [S-4]

[Balance]
· Balanced / Imbalanced — {side} losing → Extended Thinking activated
· Reason: {specific tag evidence}

[Orchestrator Assessment]
· Evidence strength: Which side presented stronger evidence, and why
· Feasibility: Is the proposed direction achievable given current project state
· Recommendation: Suggested direction for user consideration (final decision is ALWAYS the user's)
```

### Quality Gate

Assess recording worthiness from the analysis:
- **Record**: Converged debate with C≥4 on at least one side → worth recording
- **Skip**: Both sides C≤3 throughout → not worth recording
- **Ask user**: Ambiguous quality → ask user

### Recording (if approved)

**Language rule**: Write the MasterLog entry in the **user's language** (the language they used to request the debate). If the user spoke Korean, record in Korean. If English, record in English.

Append to MasterLog.md (unclassified staging area):
```
[N] Sandbox: {topic} — {date}
────────────────────────────────────────

  ■ 쟁점: {core issue}
  ■ 평가자 근거: {summary + source + reliability}
  ■ 비평자 근거: {summary + source + reliability}
  ■ 핵심 차이: {key difference}
  ■ 미검증: {unverified items}
  ■ 토의 품질: {sections, convergence, balance}
  ■ 오케스트레이터 평가: {assessment summary}
  ■ 사용자 확인 필요: {questions}

  태그: [구상]
```

### Research Queue Update (mandatory after recording)

After MasterLog recording, update `.context/research_queue.md` with debate-derived items:

1. Extract from the structured report:
   - [Unverified Items] → each becomes a research queue entry
   - [Separated Issues] → each becomes a research queue entry
   - Any falsification conditions proposed but not yet tested

2. Format per entry:
```
## [RQ-N] {title} — [대기] {priority: HIGH/MEDIUM/LOW}
- 출처: MasterLog [{N}] {debate reference}
- 내용: {what needs to be verified/tested}
- 측정: {how to measure success/failure}
- 성공 기준: {what constitutes pass/fail}
- 관련: {related log entries}
```

3. Priority assignment:
   - HIGH: Blocks project progress or invalidates a key assumption
   - MEDIUM: Improves confidence but not blocking
   - LOW: Nice to know, no urgency

4. Also sync to `github-repo/docs/context/research_queue.md` if the repo exists.

This step is mandatory — the research queue is how the user tracks what needs to be proven next to advance the project.

### MasterLog Review

Log classification is handled by `cpas-manager` plugin (`/review` command).
If the user wants to classify logs after debate, recommend running `/review` separately.

### Memory Update

Assess whether debate result should update Claude's memory:
- Confirmed decision → propose update
- Changed constraints → propose update
- Inconclusive → no update

Process:
1. Draft proposed addition (1-2 sentences)
2. Present to user: "Shall I save this to memory? → {text}"
3. Only update after explicit user approval
4. Orchestrator is the ONLY component that may modify memory

### Next Steps

Ask the user:
- Dig deeper into a specific point?
- Run another sandbox on a sub-topic?
- Proceed with a decision?

## Reference

Tag protocol: `references/tag-protocol.md`
Architecture: `Prompts/Cowork_CPAS.md`
