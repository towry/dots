---
applyTo: "nix/hm/ai/copilot/**"
description: Copilot workflow instructions
---

## Agent markdown file format

Agent markdown file is to define the agent for copilot llm agent.

doc: https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents?utm_source=changelog-docs-custom-agents&utm_medium=changelog&utm_campaign=universe25

```
---
name: Dynatrace Expert
description: Best for: Not for: When: How:
mcp-servers:
  dynatrace:
    type: 'http' | 'stdio'
    command: 'example-cmd'
    args: ['arg1', 'arg2']
    url: 'https://pia1134d.dev.apps.dynatracelabs.com/platform-reserved/mcp-gateway/v0.1/servers/dynatrace-mcp/mcp'
    headers: {"Authorization": "Bearer $COPILOT_MCP_DT_API_TOKEN"}
    tools: ["*"]
---

## Role definition

<agent role>

## Core principles

<core principles>

## Output requirements

<output requirements>
```
