# Multi-Agent Sandbox

Structured multi-agent debate system for high-stakes decision making. Two AI agents argue opposing sides with real-time web search while an orchestrator controls the environment, monitors debate quality through a 5-axis anchoring tag system, and produces a structured analysis — without ever interfering in what agents say.

## What Is This?

Multi-Agent Sandbox uses Claude's subagent capabilities to run **structured argumentation** on any topic.

An Advocate (pro) and Skeptic (con) agent debate in isolated contexts with live web search, while the orchestrator monitors debate quality in real-time and generates a final structured analysis report.

Core principle: **"Observe but never interfere"** — the orchestrator never generates debate content. It only analyzes meta-tags and performs structural observation.

## Architecture

```
v0.9.2 — 2-Level Architecture

┌──────────────────────────────────────────┐
│              Orchestrator                 │  ← Debate loop control
│              (Main Agent)                 │     + observation + judgment
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

## 5-Axis Meta Tag System

Each agent self-evaluates its state on 5 axes every turn:

| Axis | Meaning | Range | Anchor |
|------|---------|-------|--------|
| **D** | Debate Temperature | L / M / H | L=fact exchange, M=claim clash, H=overheated |
| **R** | Relevance | 1–13 | 1=core topic, 7=derived topic, 13=completely off-topic |
| **C** | Confidence/Evidence | 1–13 | 1=intuition, 7=direct evidence, 13=True_Log verified |
| **A** | Attitude | 1–13 | 1=neutral, 7=evidence-based rebuttal, 13=stuck repetition |
| **S** | Stamina | 1–19 | 1=surrender, 7=balanced, 13=strong evidence, 19=proven |

**D is the anchor** — it controls the allowed ranges for R, C, A, S, preventing agents from inflating confidence or faking stamina. The orchestrator analyzes the **time-series trajectory** of these tags to detect turning points, judge quality, and trigger imbalance correction (Extended Thinking activation). Tags are never shared between agents — architectural-level blackbox.

## Debate Flow

```
Phase 1: Pre-Debate Setup
  Step 0 — Verify workspace structure
  Step 1 — Collect project state (current_task.md, memory)
  Step 2 — 3 Data-Filters run in parallel (1 Haiku per log file)
  Step 3 — Assess internal data sufficiency
  Step 4 — Load tag protocol (required)

Phase 2: Debate Loop
  1 Section = 3 Advocate↔Skeptic exchanges (6 turns)
  Max 3 sections, early termination via cross-section comparison
  Imbalance detected → Extended Thinking activated for the losing side
  Each section starts with fresh agents (cross-section memory held by orchestrator only)

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
├── .claude-plugin/plugin.json    ← Plugin metadata (v0.9.5)
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
    ├── MasterLog.md              ← Staging area (6 entries: [2][23][24][25][26][27])
    ├── True_Log.md               ← Verified successes (15 entries)
    ├── Fail_Log.md               ← Verified failures ([16][18])
    └── Dummy_Log/                ← Low-value/duplicate ([6][8][9][12])
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

### v0.9.2 Benchmark 2 — Internal Topic: *"Is CPAS itself practical? Does decision quality improvement justify the token cost vs single-model Extended Thinking?"*

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

| Benchmark | Sections | Turns | Sub-agent API Tokens | ET Activated | Skeptic WebSearch | Notes |
|-----------|----------|-------|---------------------|-------------|-------------------|-------|
| v0.9.2 #1 (external) | 3 | 18 | ~388K | No | Yes | Standard Opus |
| v0.9.2 #2 (internal) | 3 | 18 | ~524K | Yes (S2/S3) | Yes | Advocate S-4 collapse triggered ET |
| v0.9.4 #3 (internal, re-run) | 3 | 18 | ~513K | No | **Zero** | Advocate S-7 min, no ET needed |
| Data Filters (Haiku×3) | — | — | ~50-55K per debate | — | — | Parallel execution |

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

## Version

- **Ideal (Claude Code)**: 3-level architecture with independent Observer
- **Current (Cowork) v0.9.5**: 2-level optimized — orchestrator absorbs Observer functions, 3 parallel data filters, Advocate direction anchor + Partial Acceptance Protocol, Skeptic mandatory WebSearch, research_queue auto-update, project management separated to cpas-manager plugin

## License

MIT
