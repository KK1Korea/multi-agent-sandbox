---
name: sandbox-orchestrator
description: >
  This skill should be used when the user triggers "/sandbox", asks to
  "run a sandbox debate", "debate this topic", "get both sides on this",
  or needs a structured multi-agent discussion for high-stakes decisions.
  Orchestrates Advocate and Skeptic agents directly in a 2-level architecture.
  The orchestrator controls the debate loop, strips tags, analyzes quality,
  detects imbalance, and produces the final structured report.
version: 0.9.0
---

# Sandbox Debate Orchestrator — Cowork_CPAS v0.9

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

### Step 1 — Memory & Live State Collection

Collect the project's live state:

1. **Claude Memory** (built-in): Accumulated project context, user preferences, confirmed decisions. Automatically available.
2. **current_task.md**: Real-time project state.

Combine into `{MEMORY_CONTEXT}` — concise summary of:
- Project identity and current phase
- Key constraints and confirmed decisions
- Current active tasks
- Relevant boundaries

### Step 2 — Data Filter Agents (3× Haiku, Parallel)

Spawn THREE filter agents in parallel — each handles one log file:

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

IMPORTANT: Launch all 3 agents in a SINGLE message (parallel execution).
Each agent reads only its assigned file — no overlap, no duplication.

Capture outputs and merge into `{FILTERED_DATA}`:
```
{truelog-filter output}

{faillog-filter output}

{masterlog-filter output}
```

Order: HIGH reliability first (True_Log, Fail_Log), then MEDIUM (MasterLog).

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
     · Activate Extended Thinking for the losing side in Section 2.
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
