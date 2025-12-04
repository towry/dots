---
name: create-lifeguard-rules
description: This skill should be used when creating lifeguard rules for code review
---

Lifeguard rules is used to guide code review, to ensure code quality.

# Lifeguard rule spec

**filename**: `lifeguard.yaml`

**content spec**:

```yaml
# comment
rules:
  # section description in comment (if needed)
  - name: "LG-<keyword>-001 Rule name ..., like: No magic numbers"
    description: "Details about the rule ..."
  - name: "LG-<keyword>-002 Another rule..."
    description: "Details about another rule ..."

  # section description in comment (if needed)
```

`<keyword>` is a short keyword that represents the rule category, like `vue-style`, `react-perf`, `security`, etc, keep it as short as possible.

# Rule content guidelines

When generating rules, please follow these guidelines:

- Understand current codebase, identify common pitfalls, anti-patterns, and areas for improvement.
- Find project convention for component, name convention etc, convert those to rules.
- Each rule should have clear and concise name.
- Each rule should focus on a single aspect of code quality or best practice, no complex single rule, you can create multiple simple rules instead.
- Each rule name should be consistent with rule description, for example, if the rule description focus on specific language feature, the rule name should also reflect that, instead of name is generic but the description is specific.
- When you create rules, avoid generate rule that enforce single case or rare case, for example, a function with a specific name should not be a rule, unless that function name is widely used in the codebase and have specific meaning.
- General rules to prevent bugs.
- General rules to avoid complex code, hack, work-around code.
- Dependency import path correctness.
- **Rule items order**: General rules come first, speicific/project-only rules come later.


# Validation 

Use python to validate the lifeguard.yaml file format, ensure the file have no yaml syntax error.

```
uv run --with pyyaml -- python -c "import sys, yaml; yaml.safe_load(sys.stdin)" < lifeguard.yaml && echo "✅ VALID" || ECHO "❌ NOT VALID"
```

Lifeguard content review after created: ask oracle subagent to verify the content of the lifeguard.yaml file, ensure the lifeguard rules are reasonable and useful for code review, ask it to review existing rules, not to fully rewrite.
