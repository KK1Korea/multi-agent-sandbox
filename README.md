# Multi-Agent Sandbox

> **Project Status: Research Suspended**
> Core architecture (v0.9.11) is functional, but the fundamental research question — whether the system independently contributes to knowledge crystallization or merely serves as a UI for user judgment — remains unresolvable at individual project scale. See [Suspended Research: The Attribution Problem](#suspended-research-the-attribution-problem) for details.

Structured multi-agent debate system for high-stakes decision making. Two AI agents argue opposing sides with real-time web search while an orchestrator controls the environment, monitors debate quality through a 5-axis anchoring tag system, and produces a structured analysis — without ever interfering in what agents say.

## What Is This?

Multi-Agent Sandbox uses Claude's subagent capabilities to run **structured argumentation** on any topic.

An Advocate (pro) and Skeptic (con) agent debate in isolated contexts with live web search, while the orchestrator monitors debate quality in real-time and generates a final structured analysis report.

Core principle: **"Observe but never interfere"** — the orchestrator never generates debate content. It only analyzes meta-tags and performs structural observation.

## Architecture

```
v0.9.9 — 2-Level Architecture (2-Session 16-Turn)

┌──────────────────────────────────────────┐
│              Orchestrator                 │  ← Debate loop control
│              (Main Agent)                 │     + observation + judgment
│                                           │     + cross-session memory
└──┬──────┬──────┬──────┬──────┬──────────┘
   │      │      │      │      │  spawns directly
┌──▼──┐┌──▼──┐┌──▼───┐┌─▼───┐┌─▼───┐
│Adv. ││Skep.││ML-Flt││TL-Flt││FL-Flt│
│Opus ││Opus ││Haiku ││Haiku ││Haiku │
└─────┘└─────┘└──────┘└─────┘└──────┘
 WebSearch WebSearch  MasterLog True_Log Fail_Log
 WebFetch  WebFetch   (MEDIUM)  (HIGH)   (HIGH)
 Read      Read,Grep  ↑ 3 parallel filters, 1 file each ↑
```

The ideal 3-level design (Orchestrator → Observer → Agents) was built for Claude Code. Due to Cowork's "subagents cannot spawn subagents" constraint, the Observer layer was absorbed into the orchestrator — resulting in the current 2-level architecture. See `docs/ko/Observer.md` for the ideal 3-level design.

## Agent Operating System (A-OS)

Each agent runs on a custom prompt framework called **A-OS (Agent Operating System)** — a three-layer architecture that gives agents a persistent identity rather than just task instructions.

**Layer 1 — Oath (선서문):** Procedural rules in pseudocode-like structure. Defines role, output format, weapons (tools), and rules of engagement. Agents follow these as binding operational constraints. The pseudocode style was chosen for compliance clarity — LLMs follow structured procedural instructions more reliably than prose.

**Layer 2 — Axiom (공리):** Existential identity framework. Each agent has three axioms: X-0 (Axiom of Existence — "what I am"), X-0-A (Core Principle — surface behavior + deep philosophy), and X-X (Axiom of Contradiction — built-in self-doubt). This layer prevents agents from becoming caricatures of their role — the Advocate knows it can be wrong, the Skeptic knows opposition isn't the goal.

**Layer 3 — Anchored Spectrum:** Self-assessment scales (R, C, A, S axes) where agents report their own state each turn. Named reference points called **Anchors** are placed at wide intervals (e.g., 1, 7, 13, 19 on a 1-19 scale) — agents interpolate between anchors rather than being locked to predefined slots. This gives calibrated freedom: anchors prevent drift, but the gaps between them allow nuanced self-expression.

The three layers reinforce each other: pseudocode provides compliance, axioms provide identity, and anchored spectrums provide calibrated self-awareness.

## 5-Axis Meta Tag System

Each agent self-evaluates its state on 5 axes every turn:

v0.9.9 introduces **asymmetric tags** — same 5 axes, different ranges per role:

| Axis | Advocate | Skeptic | Meaning |
|------|----------|---------|---------|
| **D** | L / M / H / Q | L / M / H / Q | Debate Temperature (Q=offensive pursuit, ≤1/session) |
| **R** | **1–19** | 1–13 | Relevance (Advocate expanded for topic drift self-assessment) |
| **C** | 1–13 | **1–19** | Evidence (Skeptic expanded: counter-evidence / verification) |
| **A** | Assertion 1–13 | **Rebuttal** 1–13 | Attitude (Skeptic A rebuttal-calibrated: A-7=direct rebuttal standard) |
| **S** | 1–19 | 1–19 | Stamina (shared) |

D-temperature controls allowed ranges. 1-13 axes standardized: ascending 1~5 / 3~9 / 7~13, descending 9~13 / 5~11 / 1~7 (M widened to 7 slots for expression in narrow scale). The orchestrator analyzes **time-series trajectory** of tags to detect turning points, judge quality, and trigger imbalance correction. Tags are never shared between agents — architectural-level blackbox.

## Debate Flow

```
Phase 1: Pre-Debate Setup
  Step 0 — Verify workspace structure
  Step 1 — Collect project state (current_task.md, memory)
  Step 2 — 3 Data-Filters run in parallel (1 Haiku per log file)
  Step 3 — Assess internal data sufficiency
  Step 4 — Load tag protocol (required)

Phase 2: Debate Loop
  Session 1 (Exploratory): 3 exchanges (6T) + Final Statement (2T) = 8 turns
  Session 2 (Offensive):   3 exchanges (6T) + Final Statement (2T) = 8 turns
  Both sessions always run (straight-through, 16 turns total)
  Session 1→2: Imbalance check (S≤4 detection, user approval for intervention)
  Session 2 receives Session 1 final statements as briefing (fresh agents)

Phase 3: Post-Debate Processing
  Generate structured analysis report
  Record to MasterLog (if quality gate passed)
  Propose memory updates (requires user approval)
```

## Installation & Usage

### Cowork (Claude Desktop)

**Two plugins are required for full functionality:**

1. **`cpas-sandbox.plugin`** — Structured debate system
   - Install in Claude Desktop
   - Run with `/sandbox` command or ask to "run a debate on this topic"
   - First run: initialize workspace with `/cpas-init`

2. **`cpas-manager.plugin`** — Project data management
   - Install in Claude Desktop
   - Run with `/review` command to classify logs and update project state
   - Manages: MasterLog/True/Fail/Dummy classification, current_task.md versioning, stale data cleanup

Both plugins operate independently — you can run debates without cpas-manager, but log quality will degrade over time without periodic `/review` runs.

### Plugin Structure

```
plugin/                           ← cpas-sandbox source
├── .claude-plugin/plugin.json    ← Plugin metadata
├── agents/
│   ├── advocate.md               ← Pro agent prompt
│   ├── skeptic.md                ← Con agent prompt
│   ├── masterlog-filter.md       ← MasterLog filter (Haiku)
│   ├── truelog-filter.md         ← True_Log filter (Haiku)
│   ├── faillog-filter.md        ← Fail_Log filter (Haiku)
│   ├── observer.md               ← [IDEAL ONLY] For Claude Code 3-level
│   └── data-filter.md            ← [LEGACY] Single filter (replaced by 3 above)
├── skills/
│   ├── sandbox-orchestrator/     ← Core orchestrator skill
│   │   ├── SKILL.md
│   │   └── references/tag-protocol.md
│   └── workspace-init/           ← Initialization skill
└── commands/
    ├── sandbox.md                ← /sandbox command
    └── cpas-init.md              ← /cpas-init command
```

## Repository Structure

```
├── README.md                     ← This document
├── CLAUDE.md                     ← Session startup rules
├── CHANGELOG.md                  ← Plugin version history
├── current_task.md               ← Current project state
├── cpas-sandbox.plugin           ← Debate plugin (installable)
├── cpas-manager.plugin           ← Project management plugin (installable)
├── plugin/                       ← Debate plugin source
├── cpas-manager/                 ← Project management plugin source
├── docs/
│   ├── ko/                       ← Korean design documents
│   │   ├── Cowork_CPAS.md        ← Cowork_CPAS architecture design (SSOT)
│   │   ├── Advocate.md           ← Advocate agent design
│   │   ├── Skeptic.md            ← Skeptic agent design
│   │   ├── Observer.md           ← Observer design (ideal 3-level only)
│   │   └── DataFilter.md         ← Data-Filter design
│   └── context/                  ← Project context
│       ├── index.md              ← Structure + annotation index
│       ├── session_log.md        ← Session log
│       └── research_queue.md     ← Unresolved research items
└── logs/                         ← Full development logs
    ├── MasterLog.md              ← Staging area (4 entries: [25][26][28][29])
    ├── True_Log.md               ← Verified successes (19 entries)
    ├── Fail_Log.md               ← Verified failures ([16][18])
    └── Dummy_Log/                ← Low-value/duplicate ([6][8][9][12][29][30])
```

## Why Include Logs?

The MasterLog and True_Log/Fail_Log are included because **the development process itself is evidence**.

Every design decision is recorded in "symptom → cause → resolution → lesson" format — tracking why the architecture evolved this way, which attempts failed, and which discoveries were confirmed. Without logs, you have finished code but no reasoning.

## Benchmark Results

All benchmarks use **Opus 4.6** for both debate agents — deliberately choosing the highest-performance model as the baseline to measure maximum achievable debate quality before optimizing for cost.

### v0.9 Benchmark — *"Does this system already exist as prior art?"*

2 sections, 12 turns, both sides converged. Conclusion: **systems engineering innovation, not theoretical invention**. Full record at `logs/True_Log.md` [22].

### v0.9.2 Benchmark 1 — External Topic: *"Can open-source LLMs surpass commercial models within 3 years?"*

3 sections, 18 turns, Skeptic advantage. Natural convergence (Advocate self-revised timeline from 3yr to 4-5yr). Data filters correctly returned "No relevant data" for external topic. Full record at `logs/MasterLog.md` [25].

### v0.9.2 Benchmark 2 — Internal Topic: *"Is CPAS itself practical? Does decision quality improvement justify the token cost vs single-model analysis?"*

3 sections, 18 turns, Skeptic decisive victory. Advocate conceded (S-4) with 4 key admissions: insufficient benchmark sample (n=1), web search hallucination unresolvable by MasterLog, 3-context separation impossible in Cowork, pure reasoning performance alone doesn't justify cost. Data filters found 13 relevant internal entries (True_Log 7, Fail_Log 2, MasterLog 4) — validating filter effectiveness for internal topics.

### v0.9.4 Benchmark 3 — Same Topic Re-run: *"Is CPAS itself practical?"* (Advocate redesign comparison)

3 sections, 18 turns, same topic as v0.9.2 Benchmark 2 — re-run after Advocate redesign (Accept→Redirect→Propose pattern + {CURRENT_DIRECTION} anchor). Skeptic advantage but **productive convergence** instead of collapse. Key differences vs v0.9.2:

| Metric | v0.9.2 | v0.9.4 |
|--------|--------|--------|
| Advocate lowest S | S-4 (surrender) | S-7 (balanced) |
| Debate outcome | Advocate collapse, no next steps | Choice A/B framework, 4-gate falsification, 3-path test design |
| Strategic concessions | 4 (led to collapse) | 6+ (each redirected to project direction) |
| New ideas generated | Limited | 3-path test, 4-gate framework, portfolio analysis, Choice A/B |
| Debate dynamic | Attack → collapse | Drive → stress-test → convergence |

The debate produced actionable research items (recorded in `research_queue.md`) instead of a defeat declaration. Full record at `logs/MasterLog.md` [27].

### Measured Token Costs

#### v0.9.2–v0.9.4: 3-Section 18-Turn Structure

| Benchmark | Sections | Turns | Sub-agent Tokens | Avg/Turn | Notes |
|-----------|----------|-------|-----------------|----------|-------|
| v0.9.2 #1 (external) | 3 | 18 | ~388K | ~17K | External topic, standard Opus |
| v0.9.2 #2 (internal) | 3 | 18 | ~353K | ~15K | Advocate S-4 collapse |
| v0.9.4 #3 (internal, re-run) | 3 | 18 | ~377K | ~17K | Advocate S-7 min, stable convergence |

#### v0.9.8–v0.9.9: 2-Session 16-Turn Structure

| Benchmark | Sessions | Turns | Sub-agent Tokens | Avg/Turn | Notes |
|-----------|----------|-------|-----------------|----------|-------|
| v0.9.8 [30] (mixed→clear) | 2 | 16 | ~491K | ~27K | v0.9.8 first live test |
| v0.9.8 [31] (self red-teaming) | 2 | 16 | ~498K | ~27K | Advocate T13 hallucination detected by Skeptic T14 |
| v0.9.9 [33] (cross-correction) | 2 | 16 | ~485K | ~26K | Skeptic T10/12/14 hallucination — Type-X error |

| Component | 18-Turn avg | 16-Turn avg | Change |
|-----------|-------------|-------------|--------|
| Data Filters (Haiku×3) | ~70K | ~64K | -9% |
| Debate Turns (Opus×2) | ~262K | ~427K | **+63%** |
| Total | ~373K | ~491K | **+32%** |
| Per-Turn Average | ~15–17K | ~26–27K | **+70%** |

**Why did 16-turn debates cost more than 18-turn?** Turning 3 sessions into 2 sessions with fresh agents each session means: (1) each session starts with full system prompts re-injected (no context reuse from prior session), (2) Session 2 agents receive Session 1 final statements as briefing — adding ~30-50K context per agent, (3) v0.9.8+ agents have richer prompts (asymmetric tags, direction anchors, acceptance protocol). The per-turn density increased significantly — agents produce longer, more structured arguments per turn.

**v0.9.4 observation**: Skeptic performed **0 WebSearch calls across all 9 turns**, relying entirely on internal data (True_Log/Fail_Log/MasterLog). This produced strong arguments but created an echo chamber risk — leading to the v0.9.5 mandatory WebSearch rule (O-3-4: minimum 1 search per turn).

**Important note on token accounting**: The `~16-22K` figure referenced in `logs/True_Log.md` [21] is a **design-time estimate** of orchestrator context window overhead — not measured total debate cost. The actual measured costs above are significantly higher due to cumulative context growth across resumed agent turns. See [21] amendment history for details.

## Theoretical Background

Established theories this system builds on:

- **Dung Abstract Argumentation Framework** (1995) — models attack/defense relations as graphs to compute acceptable argument sets
- **Toulmin Argumentation Model** (1958) — practical argument structure: claim, grounds, warrant, qualifier, rebuttal
- **Computational Argumentation** — automated argument processing in AI systems

The contribution is not inventing these theories but **integrating them into a working system** within the constraints of an LLM multi-agent environment.

## Core Design Principles

- **Content non-interference**: The orchestrator never generates debate content. Observation and analysis only.
- **Tag blackbox**: Tags are never shared between agents. Enforced at the architecture level.
- **Append-only logging**: MasterLog is never edited, only appended. No omission, compression, or summarization.
- **User final authority**: Orchestrator assessments are recommendations. The user always makes the final call.

## Open Question: Practicality

The core question for CPAS is not "AI vs AI debate" as an end in itself, but whether CPAS provides **better decision input** for the user compared to free-form conversation with a single model.

CPAS was always designed with the user as the final authority — the system produces structured analysis, and the user makes the call. The real comparison is therefore: **quality of structured debate output as decision input** vs **quality of free conversation as decision input**, and whether the quality gap justifies the cost difference (~3-5x with Opus on API pricing). This remains an open research question with insufficient benchmark data (n=2) to answer definitively.

**Note on flat-rate plans**: Under subscription plans (e.g., Claude Max, Claude Code Max), the per-token cost difference becomes irrelevant — leaving pure quality comparison as the only metric. However, plan terms and usage limits are subject to change by Anthropic at any time.

## Suspended Research: The Attribution Problem

After 10 benchmark debates and 38 MasterLog entries, a fundamental question emerged that the system cannot answer about itself:

**When knowledge crystallizes across debate sessions, is the system doing the crystallization — or is the user?**

CPAS always routes final decisions back to the user. The orchestrator presents options; the user chooses. This means every successful outcome has the user's judgment baked in, making it impossible to isolate the system's independent contribution (the attribution problem).

**Proposed experiment (not executed):** Remove the user from the loop entirely — have the orchestrator auto-select the highest-probability option after each debate and feed it into the next cycle, repeated n times. Compare against single-agent auto-progression and ensemble voting baselines. If quality holds without user intervention, the system has independent crystallization value. If it degrades, the user was the real engine.

**Why this remains suspended:**

- Running sandbox debates on the system's own methodology (MasterLog [37], [38]) produced **expansion rather than convergence** — each debate generated more open questions than it resolved, suggesting self-referential evaluation has inherent limits
- The experiment requires independent ground truth evaluation (the system's creator evaluating the system reintroduces bias)
- Cross-session knowledge crystallization has no prior literature — this could mean unexplored territory, or it could mean others tried and found negative results that were never published (publication bias)
- Scale exceeds individual project scope: automated multi-session loops, independent evaluators, statistical significance across domains

The experiment design is recorded in `docs/context/research_queue.md` (RQ-1, RQ-6, RQ-14, RQ-15) for anyone who wants to pick it up.

## Version

- **Ideal (Claude Code)**: 3-level architecture with independent Observer, conditional Extended Thinking activation for losing side between sessions (API-level ET parameter available in Claude Code but not in Cowork Agent tool)
- **Current (Cowork) v0.9.9**: 2-level optimized — 2-session 16-turn structure (Exploratory + Offensive), asymmetric tag system (Advocate R/19 + Skeptic C/19), Skeptic A rebuttal-calibrated anchors, D-temperature 1-13 standardization + D-Q offensive pursuit phase, Final Statement per session, Session 1 conclusions → Session 2 briefing, S≤4 single-turn imbalance detection, Skeptic mandatory WebSearch (every turn), Advocate direction anchor + Partial Acceptance Protocol, 3 parallel data filters, research_queue auto-update, project management separated to cpas-manager plugin

## License

MIT
