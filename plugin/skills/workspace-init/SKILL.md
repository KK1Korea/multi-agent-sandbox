---
name: workspace-init
description: >
  Initialize CPAS workspace file structure for any project. Creates the
  standard directory layout (MasterLog, True_Log, current_task, .context, Plans)
  that all CPAS components depend on. Use when starting a new project or when
  the sandbox-orchestrator detects missing structure.
version: 0.1.0
---

# CPAS Workspace Initializer

Set up the standard CPAS file structure in the user's workspace folder.
This structure is required by the sandbox debate system, MasterLog review, and all CPAS components.

## When to Use

- User runs `/cpas-init` with a project name
- Sandbox-orchestrator detects missing CPAS structure (auto-triggered)
- User explicitly asks to set up a new project

## Input

- **Project name**: Required. Used in file headers and MasterLog naming.
  - From command: `/cpas-init {project name}`
  - From auto-detect: Use the sandbox debate topic as project name, ask user to confirm.

## Initialization Protocol

### Step 1 — Check Existing Structure

Read the workspace folder. If ANY of these files already exist, do NOT overwrite:
- CLAUDE.md
- current_task.md
- True_Log.md
- MasterLog/*.md
- .context/index.md

If partial structure exists, only create the MISSING files. Report what was found and what was created.

### Step 2 — Create Directory Structure

```
{workspace}/
├── CLAUDE.md                   ← Session start rules
├── current_task.md             ← Current task tracker
├── .context/
│   ├── index.md                ← Annotation index
│   ├── session_log.md          ← Session work log
│   └── research_queue.md       ← Research task queue
├── True_Log.md                 ← Verified facts only
├── MasterLog/
│   └── MasterLog_{project}_1.md  ← First log file
├── Plans/                      ← Phase plans (empty)
└── Issues/
    └── Known_Issues.md         ← Environment bug isolation
```

### Step 3 — File Templates

**CLAUDE.md**:
```markdown
# CPAS — Session Start Rules

## Required Reading Order
1. `current_task.md` — Current user task (top priority)
2. `.context/index.md` — Project structure + annotation index
3. As needed: `True_Log.md`, `MasterLog/` reference

## Core Rules
- Detect branch points → trigger index-agent
  - Triggers: new feature / architecture change / [폐기] reappearance / Phase transition
- All work must be recorded in MasterLog with tags
- On conflict/omission detection, immediately notify user
- Update current_task.md on task completion/change

## Status Tags (5 types)
- [구상] — Idea stage, pre-verification
- [진행] — Currently in progress
- [보류] — Conditional hold (revival conditions specified)
- [폐기] — Evidence-based termination (reason specified)
- [확정] — Verification complete, confirmed

## MasterLog Format
- Structure: Symptom → Cause → Resolution → Lesson
- Numbering: [section-subsection] (e.g., [1-1], [1-2])
- Append-only, never modify
- No omission/compression/summarization
```

**current_task.md**:
```markdown
# current_task.md

## [Current State]
Project: {project name} — Initialization complete

## [Current Tasks]
1. (To be defined by user)

## [Pending Decisions]
- (None yet)

## [Progress]
Project: ░░░░░░░░░░░░░░░░░░░░ 0%

## [Last Updated] {date} Session #1
```

**True_Log.md**:
```markdown
# True_Log — {project name}
# Verified facts only. Each entry has been confirmed through evidence or empirical testing.

(No entries yet)
```

**MasterLog/{project}_1.md**:
```markdown
================================================================================
Project: {project name}
MasterLog_1 ([1]~)
Previous log: None
================================================================================

⚠ Writing Rules:
  - Append-only (no modifications). Chronological order.
  - Mark important branch points/completions with '우선확인'.
  - No omission/compression/summarization.

================================================================================

[1] Project workspace initialized — {date} Session #1
────────────────────────────────────────

  ■ Symptom:
    - New project "{project name}" started
    - CPAS workspace structure created

  ■ Resolution:
    - Standard CPAS file structure generated
    - Ready for work

  ■ Lesson:
    - CPAS structure provides session-persistent memory through filesystem

  Tag: [확정]
  Related: Workspace initialization

================================================================================
```

**.context/index.md**:
```markdown
# .context/index.md — {project name}

## Project Structure
(Auto-populated as project grows)

## Annotation Index
(File annotations will be tracked here)
```

**.context/session_log.md**:
```markdown
# Session Log — {project name}

## Session #1 — {date}
- Workspace initialized
```

**.context/research_queue.md**:
```markdown
# Research Queue — {project name}
# Unverified research items. Do NOT use as evidence in debates.

(No items yet)
```

**Issues/Known_Issues.md**:
```markdown
# Known Issues — {project name}

(No known issues yet)
```

### Step 4 — Confirmation

After creation, output:
```
CPAS workspace initialized for: {project name}

Created:
- CLAUDE.md
- current_task.md
- True_Log.md
- MasterLog/MasterLog_{project}_1.md
- .context/index.md, session_log.md, research_queue.md
- Issues/Known_Issues.md
- Plans/ (empty directory)

Ready for sandbox debates and project tracking.
```

## Important Rules

- NEVER overwrite existing files — only fill in missing ones
- NEVER modify existing MasterLog entries
- Project name must be sanitized for filenames (no spaces → underscores, no special chars)
- Date format: YYYY-MM-DD
- All templates are bilingual (Korean tags, English structure) for CPAS compatibility
