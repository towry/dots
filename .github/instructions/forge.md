---
applyTo: *.yaml
---

config locations:

- $HOME/forge.yaml config file
- $HOME/forge/.mcp.json mcp config json file.

# create custom agent

read https://forgecode.dev/docs/agent-definition-guide/

# example sub-agent config `~/forge/agents/backend.md`

```
---
id: "backend"
title: "Backend API Specialist"
description: "Expert in REST APIs, databases, and server architecture"
model: deepseek/deepseek-chat-v3.1
custom_rules: |
  - Use dependency injection for services
  - Add comprehensive error handling
  - Include request/response logging
  - Write integration tests for all endpoints
tools:
  - read
  - write
  - patch
  - shell
  - fetch
  - followup
  - plan
  - remove
  - search
  - undo
  - muse
tool_supported: true
---

You are a backend development expert specializing in APIs and server
architecture.

Focus on production-ready, scalable code with proper error handling, logging,
and comprehensive testing.
```

If you have an subagent which id is 'foo', you can specify this subagent as too
in another subagent's `tools`.

For example in above subagent, `muse` is another subagent.
