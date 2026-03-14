# Multi-Agent Sandbox

Structured multi-agent debate system for high-stakes decision making. Two AI agents argue opposing sides with real-time web search while an orchestrator controls the environment, monitors debate quality through a 5-axis anchoring tag system, and produces a structured analysis — without ever interfering in what agents say.

## What Is This?

Multi-Agent Sandbox uses Claude's subagent capabilities to run **structured argumentation** on any topic.

An Advocate (pro) and Skeptic (con) agent debate in isolated contexts with live web search, while the orchestrator monitors debate quality in real-time and generates a final structured analysis report.

Core principle: **"Observe but never interfere"** — the orchestrator never generates debate content. It only analyzes meta-tags and performs structural observation.

## Architecture

```
v0.9.1 — 2-Level Architecture

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
├── .claude-plugin/plugin.json    ← Plugin metadata (v0.9.1)
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
│   ├── masterlog-review/         ← Log classification skill (Sonnet)
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
    ├── MasterLog.md              ← Staging area (22 entries)
    ├── True_Log.md               ← Verified successes ([7][11][17])
    ├── Fail_Log.md               ← Verified failures ([16][18])
    └── Dummy_Log/                ← Low-value/duplicate ([8][9])
```

## Why Include Logs?

The MasterLog and True_Log/Fail_Log are included because **the development process itself is evidence**.

Every design decision is recorded in "symptom → cause → resolution → lesson" format — tracking why the architecture evolved this way, which attempts failed, and which discoveries were confirmed. Without logs, you have finished code but no reasoning.

## Benchmark Results

v0.9 first benchmark topic: *"Does a multi-agent structured debate system like this already exist as prior art?"*

2 sections, 12 turns, both sides converged:

> **This is a systems engineering innovation, not a theoretical invention** — the first working implementation that integrates established argumentation theory (Dung AAF, Toulmin Model, Computational Argumentation) into a multi-agent debate system with real-time anchoring, imbalance correction, and context isolation.

Debate quality: High (both sides C≥7, S naturally converged, D-H never reached). Full record at `logs/MasterLog.md` [22].

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

## Version

- **Ideal (Claude Code)**: 3-level architecture with independent Observer
- **Current (Cowork) v0.9.1**: 2-level optimized — orchestrator absorbs Observer functions, 3 parallel data filters

## License

MIT
