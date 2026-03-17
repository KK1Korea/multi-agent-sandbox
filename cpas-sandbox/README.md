# CPAS Sandbox Plugin v0.9.9

Structured multi-agent debate system for high-stakes decision making. 2-level architecture — orchestrator directly controls all agents.

## What's New in v0.9.9

- **Asymmetric tag system**: Advocate R 1-19 (topic tracking), Skeptic C 1-19 (counter-evidence/verification)
- **Skeptic A rebuttal-calibrated anchors**: A-1 clarification → A-7 direct rebuttal (standard) → A-13 complete dismantling
- **D-temperature 1-13 standardization**: ascending 1~5/3~9/7~13, descending 9~13/5~11/1~7
- **D-Q offensive pursuit phase**: full spectrum access, ≤1 per session (Final Statement only)

## Architecture

2-session 16-turn structure: Session 1 (Exploratory 8T) + Session 2 (Offensive 8T) with Final Statements. Session 2 receives Session 1 conclusions as briefing.

## Components

| Component | Name | Model | Role |
|-----------|------|-------|------|
| Command | `/sandbox` | — | Entry point — triggers a structured debate |
| Command | `/cpas-init` | Sonnet | Initialize workspace file structure |
| Skill | sandbox-orchestrator | — | Debate loop control + analysis + final report |
| Skill | workspace-init | Sonnet | Create standard directory structure |
| Agent | advocate | Opus | Argues FOR with web search evidence |
| Agent | skeptic | Opus | Argues AGAINST with project history + web search |
| Agent | masterlog-filter | Haiku | Filters MasterLog.md (MEDIUM reliability) |
| Agent | truelog-filter | Haiku | Filters True_Log.md (HIGH reliability) |
| Agent | faillog-filter | Haiku | Filters Fail_Log.md (HIGH reliability) |
| Agent | observer | Opus | [IDEAL ONLY] For Claude Code 3-level architecture |
| Agent | data-filter | Haiku | [LEGACY] Replaced by 3 specialized filters above |

## Tag Format

```
Advocate: [D-{L/M/H/Q}] [R-{1-19}] [C-{1-13}] [A-{1-13}] [S-{1-19}]
Skeptic:  [D-{L/M/H/Q}] [R-{1-13}] [C-{1-19}] [A-{1-13}] [S-{1-19}]
```

## Usage

```
/sandbox Should we migrate from REST to GraphQL for the new API?
/cpas-init my-project-name
```

## Related

- `cpas-manager` plugin: Log management (project-review, True/Fail/Dummy classification)
- `docs/ko/`: Korean design documents
- `references/tag-protocol.md`: Full tag axis definitions and orchestrator analysis guide
