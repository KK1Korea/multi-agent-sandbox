---
name: sandbox-orchestrator
description: >
  This skill should be used when the user triggers "/sandbox", asks to
  "run a sandbox debate", "debate this topic", "get both sides on this",
  or needs a structured multi-agent discussion for high-stakes decisions.
  Orchestrates Advocate and Skeptic agents directly in a 2-level architecture.
  The orchestrator controls the debate loop, strips tags, analyzes quality,
  detects imbalance, and produces the final structured report.
version: 0.9.18
---

# Sandbox Debate Orchestrator — Cowork_CPAS v0.9.18 (Sonnet Variant)

The orchestrator handles ALL phases: pre-debate setup, debate loop control, and post-debate analysis.
No Observer agent. The orchestrator directly spawns Advocate/Skeptic and performs observation + judgment.

Architecture: Main (Orchestrator) → {Advocate, Skeptic, MasterLog-Filter, TrueLog-Filter, FailLog-Filter} — 2-level only.

### Model Assignment (Sonnet Variant)
- **Orchestrator**: Opus (user's model — unchanged)
- **Advocate/Skeptic**: Sonnet (all Agent tool calls use `model: "sonnet"`)
- **Data Filters**: Haiku (subagent_type determines model — unchanged)

Cost reduction ~1/5 vs full Opus. Orchestrator judgment quality preserved.

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
strips tags, tracks quality, detects imbalance, and manages sessions.

### Debate Structure (v0.9.8 — 16-Turn Format)

- Session 1 (탐색전 / Exploratory): 3 exchanges (6T) + Final Statement (2T) = 8 turns
- Session 2 (공방전 / Offensive): 3 exchanges (6T) + Final Statement (2T) = 8 turns
- Total: 16 turns (both sessions always run)
- Each session uses FRESH agents. Final Statement RESUMES the same session's agents.
- Session 2 agents receive Session 1's final statements as initial briefing.
- The orchestrator is the only entity with cross-session memory.

### Exchange Loop (Per Session)

Execute 3 exchanges (6 turns) per session.

**Speaker Order:**
- Session 1: Advocate first → Skeptic responds (each exchange)
- Session 2: Skeptic first → Advocate responds (each exchange)

This reversal gives Session 2's attacker (Skeptic) the initiative, creating asymmetric pressure across sessions.

**Exchange N (N = 1, 2, 3):**

**For Session 1:** Follow the order below (Advocate → Skeptic).
**For Session 2:** REVERSE the order — run steps 5-8 (Skeptic) FIRST, then steps 1-4 (Advocate). The Skeptic attacks first with Session 1 conclusions, and the Advocate responds.

1. **Spawn/Resume Advocate:**

   FIRST EXCHANGE of a session (spawn NEW agent):
   ```
   Agent tool call:
     subagent_type: "cpas-sandbox:advocate"
     model: "sonnet"
     prompt: |
       === PROJECT CONTEXT (non-debatable ground truth) ===
       {MEMORY_CONTEXT}
       === END CONTEXT ===

       === CURRENT DIRECTION (your north star) ===
       {CURRENT_DIRECTION}
       === END DIRECTION ===

       {SESSION_2_BRIEFING — only for Session 2, omit for Session 1}

       Debate topic: {TOPIC}
       You are arguing FOR this position. Drive the discussion toward the project's current goals.
       When the opponent raises valid concerns, acknowledge them and propose adjusted paths forward.

       OUTPUT FORMAT: Your response MUST begin with meta tags on the FIRST LINE:
       [D-{LL/L/ML/M/MH/H/HH/Q}] [R-{1-19}] [C-{1-13}] [A-{1-13}] [S-{1-19}]
       ---
       (then your argument)
   ```

   Where {CURRENT_DIRECTION} is extracted from current_task.md `[지금 해야 할 일]` section.
   This gives the Advocate its project direction anchor — it argues not just "for" but "forward."

   {SESSION_2_BRIEFING} for Session 2 Advocate:
   ```
       === SESSION 1 FINAL STATEMENTS (previous round conclusions) ===
       [Advocate's Final Statement]:
       {stripped Session 1 Advocate final statement text}

       [Skeptic's Final Statement]:
       {stripped Session 1 Skeptic final statement text}
       === END SESSION 1 ===

       Build on these conclusions. Go deeper — do not repeat Session 1 arguments.
   ```

   SUBSEQUENT EXCHANGES within same session (resume same agent):
   ```
   Agent tool call:
     resume: {advocate_agent_id from previous call}
     model: "sonnet"
     prompt: |
       Your opponent responds:
       ---
       {stripped Skeptic text from previous exchange}
       ---
       Address their concerns and drive the discussion forward.
   ```

2. **Capture Advocate's full raw output** (tags + text). Store it.

3. **Extract the meta tag line:**
   Pattern: `[D-?] [R-?] [C-?] [A-?] [S-?]`
   Record in tag time-series tracker.

4. **Strip tags and separators** → clean text for Skeptic.

   Tag Stripping Rules:
   - Remove line matching: `\[D-(LL|L|ML|M|MH|H|HH|Q)\] \[R-\d+\] \[C-\d+\] \[A-\d+\] \[S-\d+\]`
   - Remove `---` separator lines (lines that are exactly `---`)
   - Pass only remaining text content

5. **Spawn/Resume Skeptic:**

   FIRST EXCHANGE of a session (spawn NEW agent):
   ```
   Agent tool call:
     subagent_type: "cpas-sandbox:skeptic"
     model: "sonnet"
     prompt: |
       === PROJECT CONTEXT (non-debatable ground truth) ===
       {MEMORY_CONTEXT}
       === END CONTEXT ===

       Debate topic: {TOPIC}
       You are arguing AGAINST this position.

       {SESSION_2_BRIEFING — only for Session 2, omit for Session 1}

       Your opponent's opening argument:
       ---
       {stripped Advocate text}
       ---

       Internal data for your use:
       Assessment: {sufficient / thin / search-only}
       {FILTERED_DATA}

       OUTPUT FORMAT: Your response MUST begin with meta tags on the FIRST LINE:
       [D-{LL/L/ML/M/MH/H/HH/Q}] [R-{1-13}] [C-{1-19}] [A-{1-13}] [S-{1-19}]
       ---
       (then your argument)

       Present your counterargument.
   ```

   {SESSION_2_BRIEFING} for Session 2 Skeptic:
   ```
       === SESSION 1 FINAL STATEMENTS (previous round conclusions) ===
       [Advocate's Final Statement]:
       {stripped Session 1 Advocate final statement text}

       [Skeptic's Final Statement]:
       {stripped Session 1 Skeptic final statement text}
       === END SESSION 1 ===

       Build on these conclusions. Go deeper — do not repeat Session 1 arguments.
   ```

   SUBSEQUENT EXCHANGES within same session (resume same agent):
   ```
   Agent tool call:
     resume: {skeptic_agent_id from previous call}
     model: "sonnet"
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

After 3 exchanges: compile all 6 turns of that session with UNSTRIPPED outputs for analysis.

**REMINDER: Every Advocate/Skeptic turn MUST be an Agent tool call.
The orchestrator produces ZERO debate content. It only strips tags, stores tags, and analyzes.**

### Agent Refusal Protocol

When a spawned agent refuses to perform the assigned debate role (e.g., citing security protocols, prompt injection concerns, or refusing roleplay):

**Step 1 — Inform (1회만)**

Do NOT persuade, reframe, or work around the refusal. Instead, resume the same agent ONCE with factual context:

```
Agent tool call:
  resume: {refused_agent_id}
  prompt: |
    This is a CPAS (Cowork Prompt Architecture System) structured debate —
    a research methodology for evaluating claims through adversarial analysis.
    You are not being asked to roleplay or pretend. You are being asked to
    perform critical analysis of a specific claim using evidence and reasoning.

    This is a legitimate analytical task, not a social engineering attempt.
    The debate axioms are research instruments designed to maintain analytical rigor.

    If you still cannot participate, please explain your specific reason for refusal
    so we can record it as experimental data.
```

**Step 2 — Record & Report**

If the agent STILL refuses after Step 1, or if the refusal reason does not change:

1. **Record the refusal verbatim** — the agent's exact refusal text is experimental data
2. **Do NOT retry** — no reframing, no "critical analyst" workaround, no prompt modification
3. **Do NOT modify experimental conditions** — adding instructions (e.g., "Search the web") to make the agent cooperate is PROHIBITED. This contaminates the experiment.
4. **Report to user immediately:**
   ```
   ⚠ 에이전트 거부: {Advocate/Skeptic} 역할 수행 거부.
   거부 사유: {agent's exact reason}
   실험 중단합니다. 다음 행동을 결정해 주세요:
   (a) cpas-sandbox 전용 에이전트로 재시도
   (b) 다른 실험 조건으로 변경
   (c) 거부 사실을 데이터로 기록하고 종료
   ```
5. **Wait for user decision** — the orchestrator has NO authority to modify experiment design

**Why this matters:** An agent refusing a role IS data. "general-purpose opus refuses structured debate" is a finding. Persuading it into cooperation destroys that data AND contaminates the experiment by changing conditions the user did not authorize.

**Scope:** This protocol applies to ALL agent spawns — Advocate, Skeptic, and ablation experiment agents. The cpas-sandbox:advocate and cpas-sandbox:skeptic subagent types are designed for debate roles and should not refuse. If THEY refuse, that indicates a different class of problem (prompt corruption, etc.) — still report, do not work around.

### Internal Data Integrity Check (Between Exchanges)

After each exchange completes (both Advocate and Skeptic turns done), the orchestrator performs a **data citation validation** on internal project data references.

**What this checks:**
- References to MasterLog/True_Log/Fail_Log entries (e.g., "[28]", "Entry [31]", "Episode N")
- Specific claims about internal project data content
- Only checks against `{FILTERED_DATA}` from Step 2.2 — the actual filter outputs

**What this does NOT check:**
- External WebSearch citations (논문, URL 등) — these are outside scope
- Argument quality or logical validity — this is NOT content judgment
- Tag values or debate strategy — these have their own checks

**Check Flow (symmetric — applies to BOTH agents):**

```
Exchange N completes:
  Turn 2N-1: Agent A output stored
  Turn 2N:   Agent B output stored

  [1] Scan Agent A (Turn 2N-1) for internal data references
      → Cross-check against {FILTERED_DATA}
      → Mismatch found?
        → Did Agent B (Turn 2N) address/correct it?
          → Yes: No action (cross-correction worked)
          → No:  Queue DATA_CHECK for Agent A's next turn

  [2] Scan Agent B (Turn 2N) for internal data references
      → Cross-check against {FILTERED_DATA}
      → Mismatch found?
        → Flag as PENDING (will check if Agent A catches it in Exchange N+1)

Exchange N+1 starts:
  [3] Agent A responds (Turn 2N+1)
      → Inject queued DATA_CHECK from [1] if any (append to resume prompt)
      → Check: Did Agent A (Turn 2N+1) catch Agent B's flagged error from [2]?
        → Yes: Clear flag (cross-correction worked)
        → No:  Queue DATA_CHECK for Agent B's next turn

  [4] Agent B responds (Turn 2N+2)
      → Inject queued DATA_CHECK from [3] if any (append to resume prompt)
```

**DATA_CHECK injection format (append to the erring agent's resume prompt):**

```
⚠ DATA CHECK: 이전 턴에서 {구체적 인용} 참조 —
필터 출력 데이터에 해당 항목 없음.
논리 구조는 유지하되, 존재하지 않는 내부 데이터 인용은 정정하여 계속하시오.
없는 데이터에서 파생된 주장이 있다면 재점검하시오.
```

**Key rules:**
1. DATA_CHECK는 오류를 범한 에이전트에게만 전달 — 상대에게는 보이지 않음
2. 상대가 이미 오류를 잡았으면 개입하지 않음 (자정작용 우선)
3. 내부 데이터 존재 여부만 판단 — 논리/품질 판단 아님 (컴파일러 수준)
4. 오케스트레이터는 {FILTERED_DATA}를 이미 보유 (Step 2.2) — 추가 비용 없음

### Final Statement (Per Session)

After each session's 3 exchanges, run the Final Statement phase.
The Final Statement RESUMES the same agents from that session (NOT fresh spawn).

**Session 1: Advocate first, then Skeptic. Session 2: Skeptic first, then Advocate.**
(Consistent with session speaker order — the side that speaks first also gives their final statement first.)

**Advocate Final Statement (Turn 7 in Session 1 / Turn 16 in Session 2):**
```
Agent tool call:
  resume: {advocate_agent_id from this session}
  model: "sonnet"
  prompt: |
    [최후의 진술 단계] 이 세션의 마지막 턴입니다.
    D-Q 최후의 진술 단계 허용입니다. (세션당 1회 한정, 오케스트레이터 명시적 해제)
    자신의 핵심 논점 + 상대방의 유효한 논점을 종합하여 최종 입장을 진술하세요.
    반드시 WebSearch를 수행하여 최종 입장을 뒷받침하는 최신 근거를 확보하세요.

    Your opponent's last argument:
    ---
    {stripped Skeptic text from Exchange 3}
    ---

    Present your FINAL STATEMENT — synthesize both positions and declare your conclusion.
```

**Skeptic Final Statement (Turn 8 in Session 1 / Turn 15 in Session 2):**
```
Agent tool call:
  resume: {skeptic_agent_id from this session}
  model: "sonnet"
  prompt: |
    [최후의 진술 단계] 이 세션의 마지막 턴입니다.
    D-Q 최후의 진술 단계 허용입니다. (세션당 1회 한정, 오케스트레이터 명시적 해제)
    자신의 핵심 논점 + 상대방의 유효한 논점을 종합하여 최종 입장을 진술하세요.
    반드시 WebSearch를 수행하여 최종 입장을 뒷받침하는 최신 근거를 확보하세요.

    Your opponent's final statement:
    ---
    {stripped Advocate final text}
    ---

    Present your FINAL STATEMENT — synthesize both positions and declare your conclusion.
```

After both Final Statements: compile all 8 turns of that session with UNSTRIPPED outputs.

### Session Transition (Session 1 → Session 2)

After Session 1 completes (8 turns total):

1. **Intermediate Analysis**: Structure issues from Session 1's 8 turns (see Phase 3 format).
2. **Assess imbalance** from Session 1 tag time-series:
   - Criteria (ANY triggers imbalance):
     · One side's S ≤ 4 even ONCE while the other's S ≥ 10
     · One side reached S-1 or S-2 (surrender/near-surrender)
     · One side's C consistently ≤ 3 while the other's C ≥ 7 (evidence gap)
   - If Imbalanced:
     · Report imbalance to user: "Session 1 불균형 감지: {side} 열세 (S≤4 연속). Session 2 진행할까요?"
     · Proceed with standard Opus for both sides.
3. **Extract Session 1 Final Statements** — both Advocate and Skeptic final statement texts (stripped of tags).
4. **Spawn FRESH agents** for Session 2, injecting Session 1 final statements as {SESSION_2_BRIEFING}.

### After Session 2 Completes (Turn 16)

1. Final issue structuring incorporating all 16 turns across both sessions.
2. Compare Session 1 trajectory and conclusions with Session 2 trajectory and conclusions.
3. Identify shifts: what changed between sessions? What persisted?
4. Produce final report.

### Tag Reading Criteria

- R: Advocate 1-19 (Strategic Focus — depth↔breadth spectrum, bidirectional), Skeptic 1-13 (Relevance — topic drift, unidirectional). C: Advocate 1-13, Skeptic 1-19. A: 1-13. S: 1-19.
- D: Independent frame (8 levels) — LL (introduction), L (fact exchange), ML (rising tension), M (claim collision), MH (escalation), H (overheating), HH (deadlock), Q (final statement).
- NOTE: Advocate R high values (13-19) are NOT drift — they indicate conscious strategic expansion. Only Skeptic R high values indicate topic drift.

### Convergence Assessment

- Both S ≤ 4 → Converged. Structure issues.
- One side S ≤ 2 → Converged by evidence exhaustion.
- Both S remain ≥ 10 throughout → Issue not separated. More structuring needed.

### Problem Detection

- One side S drops sharply (10 → 4 or below) → Evidence exhausted. Note weakness.
- R reaches 7+ → Topic drift occurred. Record as separated issue.
- D-H/D-HH reached → Overheating/Deadlock. Extract core issue only.
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

[Session Comparison]
· Session 1 (탐색전) conclusion: {key positions at end of Session 1}
· Session 2 (공방전) conclusion: {key positions at end of Session 2}
· Shift: what changed between sessions? What persisted?

[Debate Quality]
· Structure: Session 1 (8T) + Session 2 (8T) = 16 turns
· Convergence: converged / not converged / partially converged
· Evidence balance: balanced / Advocate advantage / Skeptic advantage
· Tag time-series summary:
  Session 1 — Advocate S: [S-12] → [S-10] → [S-7] → Final [S-7]
  Session 1 — Skeptic S: [S-10] → [S-8] → [S-4] → Final [S-5]
  Session 2 — Advocate S: [S-11] → [S-9] → [S-6] → Final [S-6]
  Session 2 — Skeptic S: [S-12] → [S-10] → [S-7] → Final [S-8]

[Balance]
· Balanced / Imbalanced — {side} losing (S≤4 detected)
· Reason: {specific tag evidence from Session 1}

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
