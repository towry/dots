---
name: facts-check
description: This skill should be used when verifying facts before implementation, checking API compatibility, validating library versions exist and are up-to-date, confirming code patterns follow current best practices, or verifying external data accuracy. Triggered by phrases like [facts check], [is this API still supported], [verify this implementation], [check if this library version works], [avoid non-exist data field].
---

# Facts Check

## Overview

To verify facts, API compatibility, dependency versions, and code patterns before implementation. This skill prevents errors from outdated knowledge, deprecated APIs, non-existent package versions, or incorrect assumptions about external data.

## When to Trigger

- Before implementing code that depends on external APIs or libraries
- When user explicitly requests fact-checking ("facts check this design")
- When referencing specific package versions or API methods
- When design relies on external data fields or schema assumptions
- When uncertain about current best practices or deprecation status

## Verification Strategy

**Rule:** If the target references codebase elements (modules, functions, data structures), verify against actual code. If it references external dependencies (libraries, APIs), verify with external sources. Often both are needed.

### External Verification (for libraries, APIs, external services)

#### 1. Dependency Version Verification

To verify a package version exists and is current:

```
Use Exa AI web_search_exa tool with query: "<package-name> <version> npm/pypi/crates.io"
```

Check for:
- Does the version exist?
- Is it the latest stable version?
- Are there known security vulnerabilities?
- Is it compatible with other project dependencies?

#### 2. API Compatibility Check

```
Use Exa AI get_code_context_exa tool with query: "<library> <method-name> usage examples"
```

#### 3. Best Practices Validation

```
Use Exa AI web_search_exa tool with query: "<framework> <pattern> best practices 2024 2025"
```

#### 4. External Schema Verification

```
Use Exa AI crawling_exa tool on official API documentation URL
```

### Codebase Verification (for modules, functions, data structures)

When the target references internal code elements, verify against actual codebase:

#### Preferred: AST-based Verification (ast-grep)

Use ast-grep for structural code verification - it matches actual code patterns, not text:

```bash
# Verify function/method exists with expected signature
ast-grep run -p 'function $FUNC($$$PARAMS) { $$$ }' -l javascript --json
ast-grep run -p 'def $FUNC($$$PARAMS):' -l python --json

# Verify method calls match expected API
ast-grep run -p '$OBJ.methodName($$$ARGS)' -l typescript --json

# Verify class/interface structure
ast-grep run -p 'interface $NAME { $$$ }' -l typescript --json
ast-grep run -p 'class $NAME { $$$ }' -l java --json

# Verify field declarations
ast-grep run -p '$TYPE $FIELD;' -l java --json
```

#### Fallback: Text-based Search (rg/fd)

Use for simple searches, config files, or non-code files:

```bash
# Quick text searches
rg "<pattern>" src/ -m 3 | head -20

# Find files by name
fd "<filename>" src/

# Generate full codebase index if needed
bunx repomix ./
```

#### Tool Selection Guide

| Verification Task | Tool | Why |
|-------------------|------|-----|
| Function signatures | ast-grep | Avoids false positives from comments/strings |
| API method calls | ast-grep | Matches actual invocations, not mentions |
| Field/property names | ast-grep | Targets declarations, not variable usage |
| Config values | rg | Config files aren't code |
| File existence | fd | Fast file finding |

Verify:
- Referenced modules/functions exist
- Function signatures match assumptions
- Data structure field names are accurate
- Config and naming patterns follow conventions

## Output Format

After verification, report findings in this format:

```
## Facts Check Results

**Verified:** [item being checked]
**Status:** ✅ Confirmed / ⚠️ Outdated / ❌ Invalid

**Findings:**
- [Key finding 1]
- [Key finding 2]

**Recommendation:** [Action to take based on findings]

**Source:** [URL or reference used for verification]
```

## Critical Rules

1. **Dual verification** - If target contains code references, MUST verify both external AND codebase facts
2. **Never assume** - Verify with sources before claiming correctness
3. **Use official sources** - Prefer official docs over blogs
4. **Check dates** - Pre-2024 info may be outdated
5. **Document sources** - Include URLs or file paths used
