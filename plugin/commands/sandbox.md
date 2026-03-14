---
description: Run a structured sandbox debate on a topic
allowed-tools: Agent, Read, Grep, WebSearch, WebFetch
argument-hint: [debate topic]
model: opus
---

The user wants to run a CPAS sandbox debate on the following topic:

**Topic**: $ARGUMENTS

Before proceeding, load the sandbox-orchestrator skill by reading @${CLAUDE_PLUGIN_ROOT}/skills/sandbox-orchestrator/SKILL.md and follow its instructions exactly.

The orchestrator skill contains the complete protocol for running sections, managing agent calls, stripping tags, and delivering the final structured result to the user.
