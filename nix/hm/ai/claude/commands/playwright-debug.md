---
description: Debug frontend issue with playwright tool, find potential issues, verify work status;
argument-hint: [describe the issue]
---

Issue or task: $ARGUMENTS

# debug the issue find the root cause

To find the root cause of the issue, keep follow steps until the root cause find:

- Use the Playwright MCP tool to debug the pages. If you can not open the URL, close the browser and try again
- (Optional method) Ask diff-issue subagent try to find potential issues in the codebase changes.
- Ask our advanced consultant coding assistant oracle subagent with a dedicated question with context, to seek a possible solution or insight about the issue. Do not ask broad questions, that won't help.
- Ask sage subagent for codebase research, implementation details

Track the issue and your findings in the `llm/issues/<issue-description>.md` file, and edit project's `CLAUDE.md`, add an entry about our report with current date.
