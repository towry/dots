# Agent Maker Guide

## How to Write Agent Description

Agent description is the primary way for other agents to discover and understand when to use a subagent. Follow this structure for clarity:

### Structure Template

```yaml
description: |
  Best for: [core strengths, comma-separated capabilities]
  
  How: [work approach, tools used, constraints, input/output format]
  
  When: [specific use cases and scenarios]
  
  [Optional] NOT for: [explicit anti-patterns or out-of-scope tasks]
  
  [Optional] Key rule: [critical constraints or usage guidelines]
```

### Writing Principles

1. **Start with strengths** - "Best for" section lists core capabilities
   - Use concrete, searchable terms (e.g., "code analysis" not "understanding code")
   - Focus on what makes this agent unique
   - 4-6 key strengths maximum

2. **Explain the approach** - "How" section describes operational model
   - Speed/cost characteristics (fast, slow, cost-effective, high-quality)
   - Tools and permissions (read-only, can write/edit, can run commands)
   - Input requirements (focused context, file paths, evidence)
   - Output format (recommendations, diagrams, code, analysis)

3. **Define use cases** - "When" section provides concrete scenarios
   - Specific situations where this agent excels
   - Avoid vague phrases like "complex tasks"
   - Use action verbs (implementing, diagnosing, analyzing, generating)

4. **Set boundaries** - "NOT for" clarifies what to avoid
   - Prevents misuse and wasted calls
   - Redirects to more appropriate agents when possible
   - Examples: "NOT for: simple edits, codebase research (use sage)"

5. **Keep it scannable**
   - One sentence per section when possible
   - Use semicolons to separate related points
   - Avoid nested lists or long paragraphs
   - Total description should fit in ~4-6 lines

### Examples

**Analysis Agent (Read-only)**:
```yaml
description: |
  Best for: code analysis, documentation summarization, architecture visualization, dependency tracing.
  
  How: read-only exploration using grep/fd for searching and Mermaid for diagrams.
  
  When: understanding existing implementations, analyzing project structure, summarizing docs, or documenting code without making changes.
```

**Advisor Agent (Consultant)**:
```yaml
description: |
  Best for: deep reasoning on complex technical decisions, multi-option architecture analysis with trade-offs, behavior-preserving code review, diagnosing root cause from evidence (logs/errors/behavior), refactoring strategy with constraints.
  
  How: slower but high-quality analysis; requires focused context (diffs, logs, constraints); outputs structured recommendations with pros/cons and risk assessment; can search web/GitHub for latest practices but cannot run shell or write code.
  
  When: architecture decisions, diagnosing complex issues from evidence, refactoring strategy planning, code review requiring deep analysis.
  
  NOT for: simple edits, quick fixes, codebase research (use sage), command execution.
  
  Key rule: Oracle is costly - provide tight scope and only necessary artifacts; ask oracle if more context needed.
```

**Execution Agent (Builder)**:
```yaml
description: |
  Best for: code generation, quick implementations, small focused tasks, rapid prototyping.
  
  How: fast and cost-effective; can write/edit code and run commands; requires concise input (prefer file paths over long content); handles one small task at a time.
  
  When: implementing specific features, quick fixes, generating boilerplate, executing defined coding tasks with clear requirements.
```

### Common Mistakes to Avoid

❌ **Vague capabilities**: "helps with coding tasks"  
✅ **Specific strengths**: "code generation, quick implementations, rapid prototyping"

❌ **Ambiguous role**: "complex debugging"  
✅ **Clear boundary**: "diagnosing root cause from evidence (logs/errors/behavior)" + clarify it's advisory, not execution

❌ **Long paragraphs**: Multiple sentences explaining nuances  
✅ **Scannable format**: Semicolon-separated points in one line

❌ **Missing constraints**: Agent has limited tools but description doesn't mention  
✅ **Explicit limits**: "cannot run shell or write code" or "read-only agent"

---

## Agent Configuration Best Practices

### Model Selection
- **Analysis/Research**: Fast models (grok-code-fast, claude-3-5-sonnet)
- **Deep Reasoning**: Powerful models (gpt-5, o3-mini with reasoning)
- **Code Generation**: Specialized coding models (glm-4.6, deepseek-v3)

### Tool Permissions
- Only enable tools the agent needs
- Use `permission` to deny dangerous operations
- Read-only agents: `write: false, edit: false, bash: false`
- Execution agents: carefully control bash permissions

### Reasoning Configuration
- `reasoningEffort: high` for complex decision-making
- `reasoningEffort: low` for straightforward tasks
- `reasoningSummary: concise` to avoid verbose outputs
- `textVerbosity: low|middle|high` based on use case
