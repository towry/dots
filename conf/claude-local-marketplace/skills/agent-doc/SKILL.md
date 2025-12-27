---
name: agent-doc
description: This skill should be used when managing, creating, or organizing agent documentation (CLAUDE.md, AGENTS.md). Triggered by phrases like [agent doc], [update claude.md], [add agent instruction], [organize agent docs], [create reference doc for agents]. Use this to keep main agent docs concise while linking to detailed reference documents.
---

# Agent Doc

## Overview

Manage agent documentation with a layered approach: keep main entry docs (CLAUDE.md, AGENTS.md) concise with references to detailed docs that agents load on-demand. This reduces context overhead while maintaining comprehensive guidance.

## Core Principles

1. **Concise Entry Docs** - Main docs contain only triggers and pointers, not full content
2. **On-Demand Loading** - Detailed docs loaded only when relevant task is triggered
3. **Single Source of Truth** - Each topic lives in one place only
4. **Progressive Disclosure** - Surface-level in main doc, depth in references

## Doc Structure

```
project/
├── CLAUDE.md              # Main entry (concise, ~500 words max)
├── AGENTS.md              # Agent-specific rules (optional)
└── .claude/
    └── docs/
        ├── vue-components.md    # Detailed: Vue patterns
        ├── api-guidelines.md    # Detailed: API conventions
        ├── testing-rules.md     # Detailed: Test requirements
        └── ...
```

## Writing Main Entry Docs

### Format for CLAUDE.md/AGENTS.md

Use conditional loading statements instead of inline content:

```markdown
# Project Instructions

## Code Style
- Follow existing patterns in codebase
- If writing Vue components, read `.claude/docs/vue-components.md`
- If writing API endpoints, read `.claude/docs/api-guidelines.md`

## Testing
- All features require tests
- For testing guidelines, read `.claude/docs/testing-rules.md`
```

### What Belongs in Main Doc

- Project name and brief purpose
- Critical constraints (security, performance)
- Conditional pointers to detailed docs
- High-level workflow triggers

### What Goes in Reference Docs

- Detailed examples and code patterns
- Step-by-step procedures
- Schema definitions and API specs
- Domain-specific knowledge

## Creating Reference Docs

### Naming Convention

Use descriptive kebab-case names:
- `vue-components.md` - Component patterns
- `api-v2-migration.md` - Migration guide
- `auth-flow.md` - Authentication details

### Reference Doc Template

```markdown
# [Topic Name]

## When to Use
[Brief description of when agent should load this doc]

## Guidelines
[Main content - patterns, rules, examples]

## Examples
[Concrete code examples if applicable]

## Common Mistakes
[What to avoid]
```

## Workflow

### Adding New Instructions

1. Determine if instruction is universal or conditional
2. Universal → Add brief line to main doc
3. Conditional → Create/update reference doc in `.claude/docs/`
4. Add pointer in main doc: "If doing X, read `.claude/docs/x.md`"

### Auditing Existing Docs

1. Check main doc line count (target: <100 lines)
2. Identify inline content that should be extracted
3. Group related instructions into reference docs
4. Replace inline content with conditional pointers

### Reorganizing Docs

To refactor bloated main docs:

1. Read current CLAUDE.md/AGENTS.md
2. Categorize content by topic/trigger condition
3. Create reference docs for each category
4. Rewrite main doc with pointers only
5. Verify no duplicate content exists

## Best Practices

- **One topic per reference doc** - Easier to maintain and load
- **Use clear trigger phrases** - "If writing...", "When debugging...", "For API..."
- **Keep references self-contained** - Should make sense without main doc context
- **Version reference docs** - Include date or version if content evolves
- **Test the flow** - Simulate agent loading to verify pointers work

## Resources

### references/reference-doc-template.md

Template for creating new agent reference docs. Copy this template when creating a new reference doc in `.claude/docs/`.

### references/writing-best-practices.md

Detailed guidance on writing effective agent documentation, including structure, language, sizing, and common mistakes. Read when improving doc quality or reorganizing existing docs.
