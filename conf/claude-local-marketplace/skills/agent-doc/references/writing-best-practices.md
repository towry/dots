# Writing Effective Agent Reference Docs

## When to Use

Load this when creating new reference documentation or improving existing agent docs.

## Principles

### Scannable Structure

- Use clear headings (H2, H3) for navigation
- Lead sections with the most important info
- Keep paragraphs short (3-5 sentences max)
- Use lists for multiple items

### Action-Oriented Language

Use imperative form:
- ✅ "Use kebab-case for file names"
- ❌ "You should use kebab-case"
- ❌ "Files should be named using kebab-case"

### Concrete Over Abstract

- ✅ "Name files like `user-profile.vue`, not `UserProfile.vue`"
- ❌ "Follow consistent naming conventions"

### Self-Contained Sections

Each section should make sense independently. Agents may jump directly to a section via search.

## Optimal Doc Sizes

| Doc Type | Target Size | Max Size |
|----------|-------------|----------|
| Main entry (CLAUDE.md) | 50-100 lines | 150 lines |
| Reference doc | 100-300 lines | 500 lines |
| Quick reference | 20-50 lines | 100 lines |

If a reference doc exceeds 500 lines, split into multiple focused docs.

## Trigger Phrase Patterns

Use consistent patterns in main docs to point to references:

```markdown
# Clear triggers
- If writing [X], read `.claude/docs/[x].md`
- When debugging [Y], see `.claude/docs/[y]-debugging.md`
- For [Z] conventions, follow `.claude/docs/[z]-conventions.md`

# Bad triggers (too vague)
- See docs for more info
- Check related documentation
- Refer to guidelines
```

## Content Categories

### Critical (Main Doc)

- Security constraints
- Breaking rules (what NEVER to do)
- Project-wide conventions

### Conditional (Reference Docs)

- Technology-specific patterns
- Feature area guidelines
- Domain knowledge
- Workflow procedures

### Ephemeral (Don't Document)

- Temporary workarounds
- One-time procedures
- Obvious conventions

## Common Mistakes

- **Over-documenting** - Not every pattern needs a doc; trust agent reasoning
- **Duplicating content** - Same info in main doc AND reference doc
- **Vague triggers** - "See docs" doesn't tell agent when to load
- **Stale content** - Docs that don't match actual codebase
- **Buried critical info** - Important constraints hidden in long docs
