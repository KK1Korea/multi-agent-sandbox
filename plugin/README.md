# CPAS Sandbox v0.6

Structured multi-agent debate system for high-stakes decision making.

## What it does

Runs a formal debate between two AI agents (Advocate vs Skeptic) while an invisible Observer controls the debate environment and structures the results — without judging who won. The user makes the final call.

## Components

| Component | Name | Model | Purpose |
|-----------|------|-------|---------|
| Command | `/sandbox` | — | Entry point — triggers a debate on a topic |
| Command | `/cpas-init` | Sonnet | Initialize CPAS workspace file structure for a project |
| Skill | sandbox-orchestrator | — | Lightweight: pre-debate setup + post-debate processing |
| Skill | masterlog-review | Sonnet | Classify MasterLog entries as True/Dummy/Fail |
| Skill | workspace-init | Sonnet | Create standard CPAS directory structure |
| Agent | advocate | Opus | Argues FOR with latest external evidence (web search) |
| Agent | skeptic | Opus | Argues AGAINST with project history + counter-evidence |
| Agent | observer | Opus | Controls debate loop, structures issues neutrally. Never judges. |
| Agent | data-filter | Haiku | Pre-processes internal data for Skeptic (prevents context pollution) |

## Architecture (v0.6)

### Debate Flow

1. **Orchestrator (main agent)** — Phase 1: Pre-debate setup
   - Collects memory context (Claude built-in memory + current_task.md)
   - Spawns data-filter (Haiku) to extract relevant internal data
   - Assesses internal data sufficiency

2. **Observer** — Phase 2: Controls entire debate loop
   - Spawns Advocate and Skeptic agents
   - Manages sections (up to 3 sections, 3 exchanges each)
   - Strips tags between agents (blackbox preserved)
   - Detects imbalance → activates extended thinking for losing side
   - Cross-section comparison (Section 1 = Section 2 → skip Section 3)
   - Delivers final structured report

3. **Orchestrator** — Phase 3: Post-debate processing
   - Presents Observer's report to user
   - Quality gate (Record / Skip / Ask user)
   - MasterLog recording if approved
   - Memory update proposal (user approval required)

### Context Isolation

Four independent contexts:
- **Advocate context**: sees only Skeptic's text (tags stripped) + memory context
- **Skeptic context**: sees only Advocate's text (tags stripped) + memory context + filtered internal data
- **Observer context**: sees everything (tags included), controls debate environment
- **Orchestrator context**: never sees debate data, only Observer's final report

### Data Source Reliability Tiers

| Tier | Sources | Usage |
|------|---------|-------|
| HIGH | MasterLog, True_Log | Primary evidence for Skeptic |
| LOW | Plans | Reference only, C-4 max |
| EXCLUDED | research_queue | Never delivered to debate agents |

### Imbalance Detection

After Section 1, Observer checks for one-sided dominance:
- One side S ≤ 4 for 2+ consecutive turns while other S ≥ 10
- One side reached S-1 or S-2 (surrender/near-surrender)
- Persistent C gap (one ≤ 3, other ≥ 7)

If detected: extended thinking activated for the losing side. Blackbox preserved — the agent doesn't know why.

## Tag System (D,R,C,A,S)

5-axis meta tags on every debate turn:
- **D** (Debate Temperature): L/M/H
- **R** (Relevance): 1-13
- **C** (Confidence/Evidence): 1-13
- **A** (Attitude): 1-13
- **S** (Stamina): 1-19

Tags are for Observer analysis. Debate agents produce them but never see the opponent's tags.

## Memory System

- **Source**: Claude built-in memory + current_task.md
- **Role**: Injected as "non-debatable ground truth" into both debaters
- **Boundary**: Sets the debate direction (debaters argue within this context)
- **Modification**: Only orchestrator can propose memory updates, with explicit user approval

## Usage

```
/sandbox Should we migrate from REST to GraphQL for the new API?
/cpas-init my-project-name
```

## Design References

Korean design documents: `CPAS/Prompts/Advocate.md` (v0.4), `Skeptic.md` (v0.5), `Observer.md` (v0.6), `DataFilter.md` (v0.1)
