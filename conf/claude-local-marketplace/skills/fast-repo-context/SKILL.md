---
name: fast-repo-context
description: "This skill should be used when needing to efficiently retrieve repository context for code search, analysis, or understanding. Triggered by phrases like [fast context], [please analyze codebase], [search repo], [Explore code], [understand which files/code...]"
---

# Fast Context

## Overview

Efficiently retrieve repository context for code search and analysis without loading the entire codebase into the conversation. This skill provides two primary context sources: repomix-generated XML files for comprehensive code structure and content, and knowledge graph (kg) queries for keyword-based retrieval.

## ⚠️ MANDATORY EXECUTION CHECKLIST

**When this skill is invoked, you MUST follow these steps IN ORDER:**

- [ ] **Step 1**: Check repomix-output.xml freshness with `ls -lh repomix-output.xml`
- [ ] **Step 2**: If file is missing or >2 days old, regenerate with `bunx repomix --output-show-line-numbers`
- [ ] **Step 3**: Search repomix-output.xml with Bash(rg)/Grep tool (PRIMARY search method)
- [ ] **Step 4** (OPTIONAL): Query knowledge graph using `mcp__kg__query_graph` only if repomix search is insufficient

### 🚫 CRITICAL CONSTRAINTS

- **FORBIDDEN**: Do NOT skip directly to Grep/Glob on source files without checking repomix first
- **FORBIDDEN**: Do NOT use `Grep` tool on source code directories (src/, lib/, etc.) as your first action
- **REQUIRED**: Always start with repomix freshness check, then search repomix-output.xml
- **PRIMARY TOOL**: Bash(rg)/search on repomix-output.xml is the main search method
- **OPTIONAL TOOL**: KG query is a fallback/supplement, not mandatory
- **REQUIRED**: Document which steps you completed in your response

## When to Use This Skill

Use this skill when:
- Need to search or analyze code across the repository
- Want to understand repository structure and organization
- Need specific code snippets or file contents quickly
- Building context for debugging or feature implementation
- Exploring unfamiliar codebases
- User says "use fast context"

### What This Skill Is NOT

This is **NOT** a shortcut to run Bash(rg)/Glob directly on source files. It's a systematic approach to:
1. Maintain a queryable code snapshot (repomix)
2. Leverage semantic search (kg)
3. Then perform targeted code searches

**If you just want to grep source files, don't invoke this skill.**

## Core Context Retrieval Strategy

Follow a two-pronged approach to retrieve repository context efficiently:

### 1. Repomix Context Source (Comprehensive Code Context)

Repomix generates an XML file (`repomix-output.xml`) containing the entire repository's structure, files, and code content. This serves as a queryable, comprehensive context source.

#### Step 1: Check Repomix Output Availability

Before using repomix context, verify the XML file exists and is current:

```bash
# Check if repomix-output.xml exists and view its modification time
ls -lh repomix-output.xml
```

**Freshness criteria:**
- If the file was modified within the last 2 days (or since last significant code changes), it can be used directly
- If the file is older or doesn't exist, proceed to Step 2 to regenerate it

#### Step 2: Generate/Update Repomix Output

When the XML file needs updating, use one of these recommended commands based on the scenario:

**Standard generation (recommended for most cases):**
```bash
# Generate XML with line numbers for easy code reference
bunx repomix --output-show-line-numbers
```

**For large repositories (optimize output size):**
```bash
# Exclude common build/dependency directories and remove comments
bunx repomix \
  --ignore "node_modules/**,dist/**,build/**,.next/**,coverage/**,*.lock" \
  --remove-comments \
  --remove-empty-lines

# Or use compressed mode (extracts only code structure: classes, functions, interfaces)
bunx repomix --compress --output-show-line-numbers
```

**For focused context (specific directories only):**
```bash
# Include only specific patterns
bunx repomix --include "src/**/*.ts,src/**/*.tsx,*.md"

# Or process specific directories
bunx repomix src/ lib/
```

**With git context (useful for understanding recent changes):**
```bash
# Include recent git diffs and commit history
bunx repomix --include-diffs --include-logs --include-logs-count 20
```

**Advanced options you may need:**
```bash
# Output to custom location
bunx repomix -o path/to/output.xml

# Different output format (markdown or plain text)
bunx repomix --style markdown  # or --style plain

# Show token count analysis (helpful for LLM context planning)
bunx repomix --token-count-tree 100  # Shows files with ≥100 tokens

# Security-conscious: skip sensitive data check if you're certain
bunx repomix --no-security-check  # Only use when you trust the repo

# Metadata only (no file contents, useful for structure analysis)
bunx repomix --no-files
```

**After generation, verify success:**
```bash
# Check file was created and has reasonable size
ls -lh repomix-output.xml

# Optionally preview the structure
head -n 50 repomix-output.xml
```

#### Step 3: Query Repomix Output

Once `repomix-output.xml` is available and current:

1. **Read the file** to search for specific code, files, or patterns:
   ```bash
   # Use Read tool to load repomix-output.xml into context
   ```

2. **Search efficiently** using rg or XML parsing:
   ```bash
   # Search for specific functions, classes, or patterns
   rg -n "function_name" repomix-output.xml

   # Search for file paths
   rg -n "path.*specific_file" repomix-output.xml
   ```

3. **Extract relevant sections** rather than loading the entire file when possible

**Benefits of repomix context:**
- Single file contains entire codebase structure
- Queryable with standard text search tools
- Preserves file paths and code organization
- Updated on-demand, not continuously synchronized

### 2. Knowledge Graph Context Source (Keyword-Based Retrieval)

The knowledge graph (kg) MCP tool stores indexed information about the codebase that can be queried by keywords, concepts, or relationships.

#### Using kg for Context Retrieval

Query the knowledge graph to accelerate code search and analysis:

1. **Search for specific concepts or components**:
   ```
   Use mcp__kg__query_graph with operation='search_memory' to find:
   - Component names and locations
   - Architecture patterns
   - API endpoints and routes
   - Database schemas
   - Common workflows
   ```

2. **Find related entities**:
   ```
   Use operation='search_entities' to discover:
   - Related modules or components
   - Dependencies and relationships
   - Similar patterns in the codebase
   ```

3. **Leverage group_id for project organization**:
   ```
   Filter queries by group_id to retrieve context specific to:
   - Particular features or modules
   - Specific subsystems
   - Related documentation
   ```

**Benefits of kg context:**
- Fast keyword-based retrieval
- Discovers relationships between code elements
- Can surface architectural patterns and conventions
- Complements repomix by providing semantic search

## Workflow Decision Tree

**ALWAYS START HERE when this skill is invoked:**

```
Step 1: Check repomix freshness
├─ Run: ls -lh repomix-output.xml
├─ Missing or >2 days old? → Run: bunx repomix --output-show-line-numbers
└─ Fresh? → Continue to Step 2

Step 2: Search repomix-output.xml (PRIMARY METHOD)
├─ Use rg/Grep tool on repomix-output.xml (NOT source files!)
├─ Extract relevant code sections
├─ Found what you need? → DONE
└─ Insufficient results? → Consider Step 3

Step 3 (OPTIONAL): Query Knowledge Graph as supplement
├─ Run: mcp__kg__query_graph with operation='search_memory'
├─ Query: [user's search terms for semantic/architectural context]
└─ Use KG results to enhance understanding from Step 2

Step 4 (OPTIONAL): Direct source file access
└─ Only if Steps 2-3 didn't provide needed detail
```

### ❌ Anti-Pattern Example (DO NOT DO THIS)

```bash
# WRONG: Jumping directly to source code search
rg "候选人详情" src/
rg "phone.*country" lib/
```

### ✅ Correct Pattern Example

```bash
# CORRECT: Following the workflow
# Step 1: Check repomix
ls -lh repomix-output.xml

# Step 2: Search repomix output FIRST (PRIMARY METHOD)
rg -n "候选人详情" repomix-output.xml
rg -n "phone.*country" repomix-output.xml

# Step 3 (OPTIONAL): Query kg only if needed for semantic context
# operation='search_memory', query='候选人详情 architecture pattern'
```

## Best Practices

1. **Prefer targeted queries over full loads**: Use rg, search patterns, or specific file reads rather than loading entire repomix output into context

2. **Keep repomix output fresh**: Regenerate after significant code changes or at the start of a session

3. **Combine sources strategically**:
   - Use repomix as the primary source for code/file searching
   - Use kg only when you need semantic/architectural context beyond what's in the code

4. **Cache frequently accessed context**: Store commonly referenced patterns, schemas, or APIs in kg with appropriate group_ids for quick retrieval

5. **Validate assumptions**: After retrieving context, verify file paths and code snippets are current by checking modification times

## Common Usage Patterns

### Pattern 1: Finding a Specific Function Implementation

1. Search repomix-output.xml with rg for the function name
2. Extract the implementation from search results
3. (Optional) Query kg if you need architectural context about how this function fits into the system

### Pattern 2: Understanding Module Architecture

1. Search repomix for the module files and structure
2. Examine file structure and imports from repomix output
3. (Optional) Query kg for high-level architectural patterns or design decisions if needed

### Pattern 3: Debugging a Feature

1. Search repomix for feature-related code and error patterns
2. Extract detailed code from repomix-output.xml
3. (Optional) Query kg with feature name if you need historical context or design rationale

## Limitations

- **Repomix freshness**: Output is a snapshot, not live; must be regenerated to reflect changes
- **File size**: Very large repositories may produce large XML files; use filters to limit scope
- **kg coverage**: Knowledge graph quality depends on what has been indexed; new code may not be present

## Troubleshooting

**Repomix generation fails:**
- Check bunx is installed and available
- Verify repomix package is accessible
- Review error messages for specific issues (memory, permissions, etc.)

**Repomix output is too large:**
- Use `--ignore` flag to exclude node_modules, build artifacts, etc.
- Use `--include` to focus on specific directories
- Consider generating separate outputs for different subsystems

**kg returns no results:**
- Information may not be indexed yet
- Try broader search terms
- Fall back to repomix for comprehensive search

## Self-Check Before Executing

**Before performing ANY search operation, verify you have completed:**

1. ✅ **Have I checked repomix-output.xml freshness?**
   - If NO: Run `ls -lh repomix-output.xml` now

2. ✅ **Have I searched repomix-output.xml first?**
   - If NO: Use rg/Grep tool on `repomix-output.xml` now

3. ✅ **Am I searching repomix output, not source files directly?**
   - If NO: Change your rg/search target to `repomix-output.xml`

4. ✅ **Do I really need KG, or did repomix already provide the answer?**
   - Only query KG if you need semantic/architectural context beyond the code

### Execution Verification Template

When you complete a search task using this skill, include this verification in your response:

```
✅ Fast-Context Execution Log:
- [✓/✗] Step 1: Checked repomix freshness
- [✓/✗] Step 2: Searched repomix output (PRIMARY)
- [✓/✗] Step 3: (Optional) Queried knowledge graph for semantic context
- [✓/✗] Step 4: (Optional) Accessed source files

Findings: [Your search results here]
```

This helps ensure transparency and adherence to the workflow.

## 📚 Detailed Usage Examples

For comprehensive examples of correct and incorrect usage patterns, see:
- **[EXAMPLES.md](./EXAMPLES.md)** - Real-world scenarios with step-by-step walkthroughs

This includes:
- ❌ Anti-patterns showing common mistakes
- ✅ Correct patterns following the mandatory workflow
- Practice exercises to test your understanding

