# CPAS Sandbox Plugin v0.9.2

Structured multi-agent debate system for high-stakes decision making. 2-level architecture — orchestrator directly controls all agents.

## Components

| Component | Name | Model | Role |
|-----------|------|-------|------|
| Command | `/sandbox` | — | Entry point — triggers a structured debate |
| Command | `/cpas-init` | Sonnet | Initialize workspace file structure |
| Skill | sandbox-orchestrator | — | Debate loop control + analysis + final report |
| Skill | masterlog-review | Sonnet | Classify MasterLog entries (True/Dummy/Fail) |
| Skill | workspace-init | Sonnet | Create standard directory structure |
| Agent | advocate | Opus | Argues FOR with web search evidence |
| Agent | skeptic | Opus | Argues AGAINST with project history + web search |
| Agent | masterlog-filter | Haiku | Filters MasterLog.md (MEDIUM reliability) |
| Agent | truelog-filter | Haiku | Filters True_Log.md (HIGH reliability) |
| Agent | faillog-filter | Haiku | Filters Fail_Log.md (HIGH reliability) |
| Agent | observer | Opus | [IDEAL ONLY] For Claude Code 3-level architecture |
| Agent | data-filter | Haiku | [LEGACY] Replaced by 3 specialized filters above |

## Usage

```
/sandbox Should we migrate from REST to GraphQL for the new API?
/cpas-init my-project-name
```

## Design References

See `docs/ko/` for Korean design documents and `README.md` (root) for full documentation.
