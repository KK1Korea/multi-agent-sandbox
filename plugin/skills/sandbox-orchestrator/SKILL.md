---
name: sandbox-orchestrator
description: >
  This skill should be used when the user triggers "/sandbox", asks to
  "run a sandbox debate", "debate this topic", "get both sides on this",
  or needs a structured multi-agent discussion for high-stakes decisions.
  Orchestrates Advocate and Skeptic agents directly in a 2-level architecture.
  The orchestrator controls the debate loop, strips tags, analyzes quality,
  detects imbalance, and produces the final structured report.
version: 0.9.2
---

# Sandbox Debate Orchestrator — Cowork_CPAS v0.9.2

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

Before starting the debate, check the health of project logs:

1. **MasterLog staleness**: Count entries with `[구상]` or `[진행]` tags that have been in MasterLog for 3+ sessions (check session numbers vs current session).
2. **True_Log superseded check**: Quick scan — are there entries referencing versions that have been replaced by later entries?
3. **current_task.md freshness**: Is `[최종 갱신]` more than 2 sessions behind?

**Actions:**
- If stale entries ≥ 3: Recommend user to run `masterlog-review` before debate.
  · Format: "MasterLog에 3세션 이상 미분류 항목이 {N}건 있습니다. 토의 전에 masterlog-review를 실행하시겠습니까?"
  · If user approves → run masterlog-review, then continue to Step 1
  · If user declines → proceed normally (data filters will handle relevance anyway)
- If current_task.md is stale: Warn user.
  · Format: "current_task.md가 세션 #{N}에서 멈춰있습니다. 토의 경계 조건이 outdated일 수 있습니다. 업데이트할까요?"
- If everything fresh → proceed silently

**IMPORTANT**: This is a lightweight check, NOT a full masterlog-review. Read headers/tags only — do NOT read full entry contents.

### Step 1 — Memory & Live State Collection

Collect the project's live state:

1. **Claude Memory** (built-in): Accumulated project context, user preferences, confirmed decisions. Automatically available.
2. **current_task.md**: Real-time project state.

Combine into `{MEMORY_CONTEXT}` — concise summary of:
- Project identity and current phase
- Key constraints and confirmed decisions
- Current active tasks
- Relevant boundaries

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

### Debate Structure

- 1 section = 3 Advocate↔Skeptic exchanges (6 total turns)
- Default: up to 3 sections
- Each section starts with FRESH agents (new spawn, no resume across sections)
- The orchestrator is the only entity with cross-section memory.

### Exchange Loop — How to Run Each Section

For each section, execute 3 exchanges (6 turns total):

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

       Debate topic: {TOPIC}
       You are arguing FOR this position. Present your case.
   ```

   SUBSEQUENT EXCHANGES within same section (resume same agent):
   ```
   Agent tool call:
     resume: {advocate_agent_id from previous call}
     prompt: |
       Your opponent responds:
       ---
       {stripped Skeptic text from previous exchange}
       ---
       Present your counterargument.
   ```

   NEW SECTION (spawn fresh agent, do NOT resume):
   ```
   Agent tool call:
     subagent_type: "cpas-sandbox:advocate"
     prompt: |
       [same as first exchange prompt above — fresh context]
   ```

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

### Section Transition Rules

**After Section 1:**

1. Structure issues from the 6 turns (see Phase 3 format).
2. Assess imbalance:
   - Criteria (ANY triggers imbalance):
     · One side's S ≤ 4 for 2+ consecutive turns while the other's S ≥ 10
     · One side reached S-1 or S-2 (surrender/near-surrender)
     · One side's C consistently ≤ 3 while the other's C ≥ 7 (evidence gap)
   - If Imbalanced:
     · ⚠ MANDATORY: Ask the user for approval before activating Extended Thinking.
     · Format: "불균형 감지: {side} 열세 (S≤4 연속). 확장사고를 활성화하면 토큰 비용이 ~2-3배 증가합니다. 활성화할까요?"
     · If approved: Activate Extended Thinking for the losing side in Section 2.
     · If denied: Proceed with standard Opus for both sides.
     · Add `model: "opus"` with extended thinking hint in the agent prompt.
     · The agent does not know why — blackbox preserved.
     · This is environment adjustment, not content intervention.
3. Spawn NEW agents for Section 2 (fresh context).

**After Section 2:**

1. Structure issues from Section 2's 6 turns.
2. Compare Section 1 and Section 2 conclusions:
   - "Same conclusion" criteria:
     · Core issue is the same AND
     · Strength direction is the same (Advocate advantage / Skeptic advantage / balanced) AND
     · No new issues were added
   - All 3 met → "Same" → Skip Section 3. Produce final report.
   - Otherwise → Proceed to Section 3.
3. If proceeding: keep extended thinking active for same side.

**After Section 3 (if ran):**

1. Final issue structuring.
2. Record conclusion changes across all 3 sections.

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
· Sections: N/3 (note if skipped)
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

If separated issues noted, append to `research_queue.md`.

### MasterLog Review

If session wrapping up, invoke `masterlog-review` skill.

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
