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

1. Install the `cpas-sandbox.plugin` file in Claude Desktop
2. Run with `/sandbox` command or ask to "run a debate on this topic"
3. First run: initialize workspace with `/cpas-init`

### Plugin Structure

```
plugin/
├── .claude-plugin/plugin.json    ← Plugin metadata (v0.9.2)
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
│   ├── masterlog-review/         ← Log classification skill (inherits user's model)
│   └── workspace-init/           ← Initialization skill
└── commands/
    ├── sandbox.md                ← /sandbox command
    └── cpas-init.md              ← /cpas-init command
```

## Repository Structure

```
├── README.md                     ← This document
├── CLAUDE.md                     ← Session startup rules
├── current_task.md               ← Current project state
├── cpas-sandbox.plugin           ← Installable plugin file
├── plugin/                       ← Plugin source code
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
    ├── MasterLog.md              ← Staging area (3 entries: [2][23][24])
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

### Measured Token Costs

| Benchmark | Sections | Turns | Sub-agent API Tokens | Notes |
|-----------|----------|-------|---------------------|-------|
| v0.9.2 #1 (external) | 3 | 18 | ~388K | Standard Opus, no Extended Thinking |
| v0.9.2 #2 (internal) | 3 | 18 | ~524K | S2/S3 Advocate Extended Thinking activated |
| Data Filters (Haiku×3) | — | — | ~50-55K per debate | Parallel execution |

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

CPAS was always designed with the user as the final authority — the system produces structured analysis, and the user makes the call. The real comparison is therefore: **quality of structured debate output as decision input** vs **quality of free conversation as decision input**, and whether the quality gap justifies the cost difference (~3-5x with Opus). This remains an open research question with insufficient benchmark data (n=2) to answer definitively.

## Version

- **Ideal (Claude Code)**: 3-level architecture with independent Observer
- **Current (Cowork) v0.9.2**: 2-level optimized — orchestrator absorbs Observer functions, 3 parallel data filters

## License

MIT
