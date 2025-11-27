# Fast Repo Context - Examples

## Basic Usage

### Find authentication flow
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "how user authentication and login works"
```

### Find where data is validated
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "input validation before saving to database"
```

### Find error handling
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "how API errors are handled and returned to client"
```

### Find component rendering logic
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "conditional rendering based on user permissions"
```

## Real-World Scenarios

### Scenario 1: Debug a feature

**User:** "Find where the cart total is calculated incorrectly"

```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "shopping cart total calculation with discounts and taxes"
```

Then read the specific files from results.

---

### Scenario 2: Understand architecture

**User:** "How does the payment system work?"

```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "payment processing flow from checkout to confirmation"
```

---

### Scenario 3: Find similar patterns

**User:** "Find all places that call external APIs"

```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "HTTP requests to external services with error handling"
```


