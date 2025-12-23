---
name: local-research
description: "This skill should be used when performing codebase research with markdown documentation persistence. Triggered by phrases like [local research], [quick research], [load local research], [init local research], [read local research ...]."
---

# Local Research

## Overview

Perform comprehensive codebase research with persistent markdown documentation stored in `~/workspace/llm/research/`. This skill integrates multiple research tools including fast-repo-context skill, knowledge graph queries, and external resources to create structured research documentation.

Use absolute file path in research document for easy share across different projects/repos.

## When to Use This Skill

Use this skill when:
- Need to research and analyze codebase structure and patterns
- Want to create persistent research documentation
- Need to load previous research findings
- User says "local research", "quick research", or "load local research"

## Core Workflow

### Loading Research Process (when user mention load or want to update a research doc, or provided doc keywords)

**Critical**: If no research file found, just tell user and finish, do not create. Only read one research file, do not read multiple files.

1. **List Research Files**: `ls ~/workspace/llm/research/`
2. **Pick only one file(no read)**: Match user keywords to research names/content to find the most relevant research file, do not read, ask user to confirm if is this one, and list other possible match files if any.
3. User choose with file index, then you proceed to read the file.

Read the results and load the correct research file.

You can use `rg` to grep in the folder with multiple possible keywords to locate the file.

### When user requests new research to be created explicitly

1. **Generate Research Name**: Create descriptive research name based on user input as `<user-query>`, user input may contain typos, improve it.
2. **Create Research File**: `python3 ~/.claude/skills/local-research/scripts/research_ops.py create "<user-query>"`
3. **Ask Clarifying Questions**: Ask user for more details about research scope, this step is required to ensure accurate research direction.
4. **Execute Research Workflow**: Use integrated tools to gather information
5. **Document Findings**: Write results to research markdown file, use absolute file path when writing, do not use `~` path abbreviation.
6. **Iterate the research doc with user**: Present findings to user, ask for feedback or additional areas to explore, update the research doc accordingly.

## Research Tools and Methods

### Primary Research Tools

1. **Fast Context Skill** (`fast-repo-context`):
   - load fast-repo-context skill
   - Use for comprehensive codebase understanding
   - Leverages repomix-generated XML for efficient searching

2. **Knowledge Graph** (`kg`):
   - Query related keywords and existing research
   - Use `mcp__kg__query_graph` with semantic search
   - Set `group_id` to organize research by project/topics

3. **External Resources**:
   - **Exa**: Use `mcp__exa__web_search_exa` for web research and `mcp__exa__crawling_exa` for scraping content
   - **GitHub**: Use `mcp__github__search_code` or `mcp__github__search_repositories` for external code reference

### Research Execution Order

1. **Initialize Research Environment**:
   ```bash
   python3 ~/.claude/skills/local-research/scripts/research_ops.py create "<user-query>"
   ```

2. **Fast Context Analysis**:
   - Extract code structure, patterns, and key files
   - Document findings in research file

3. **Knowledge Graph Integration**:
   - Query `kg` for related information
   - Use semantic search with research keywords
   - Integrate findings into research documentation

4. **External Research** (if needed):
   - Use Exa for web research on related topics (search, scraping, code context)
   - Use GitHub tools for external examples and best practices
   - Add external insights to research file

## Research Documentation Structure

Each research markdown file should follow this structure:

```markdown
# <Research Name>

- **Created**: <timestamp>
- **Research Query**: <original user input>

## Executive Summary
<brief overview of findings>

## Codebase Analysis
<findings from fast-repo-context>

## Knowledge Graph Insights
<related information from kg queries>

## External Research
<findings from web/github research if applicable>

## Key Findings
<important discoveries and insights>

## Recommendations
<actionable recommendations based on research>

## Files Referenced
<list of key files analyzed>

## Next Steps
<suggested follow-up actions>
```

- Note: file path in the research doc must use absolute path, do not use `~` abbreviation, because this doc will be shared across different project/repos.

## Loading Research

When user wants to load existing research:

1. **Available Research**: List all research files with timestamps
2. **Search Matching**: Match user keywords to research names/content
3. **Display Findings**: Present the complete research file content

## Integration with Other Skills

### Fast Context Integration
- Always invoke `fast-repo-context` skill for codebase analysis
- Follow its mandatory checklist: check repomix freshness, search XML, then optionally KG
- Document steps completed in research file

### Knowledge Graph Integration
- Use consistent `group_id` for related research projects
- Store research summaries in KG for future retrieval
- Query KG before starting new research to avoid duplication

## Research Naming Conventions

Generate descriptive research names:
- Convert user input to kebab-case
- Include domain/technology focus
- Example inputs to names:
  - "analyze authentication system" → "authentication-system-analysis"
  - "react performance issues" → "react-performance-investigation"
  - "api design patterns" → "api-design-patterns-research"

## Error Handling

- If research directory creation fails, check permissions and path
- If fast-repo-context claude skill is unavailable, fall back to direct code search
- If external resources are unreachable, continue with internal research
- Always document any limitations or issues encountered

# Example

<example>
<user>
please load local research on "authentication system analysis" and update the document with any new findings.
</user>

<assistant>
```bash
python3 ~/.claude/skills/local-research/scripts/research_ops.py list
```
Good, found the research file at `<file-path>`. Now loading the content and summarizing the key points for you.
</assistant>
</example>

<example>
<user>
new research, city picker in ve form.
</user>

<assistant>
Let me first check if there are existing research files related to "city picker in ve form".

```bash
python3 ~/.claude/skills/local-research/scripts/research_ops.py list
```

No existing research found. Do you want me to create research file for "city picker in ve form".

<user>
No
</user>

<assistant>
Ok, let me know if you need anything else.
</assistant>

<user>
Ok, create it
</user>

<assistant>
Confirm received.

```bash
python3 ~/.claude/skills/local-research/scripts/research_ops.py create "city picker in ve form"
```

Great, I've created a new research file for "city picker in ve form". Could you please provide more details about the scope of this research? Are there specific aspects you would like me to focus on? Or some files/keywords let do the codebase search with fast-repo-context skill?
</assistant>
</example>
