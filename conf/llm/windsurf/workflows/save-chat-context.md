---
description: Save chat context to local markdown file
auto_execution_mode: 1
---

请在当前工作目录创建一个名为 `llm/chat/<chat-description-separate-with-dash>_chat-context.md` 的文件，内容为当前聊天的上下文，目的是为了在新建的聊天中使用，避免当前聊天的上下文丢失。

- 内容请保持简洁，保留关键信息，以及接下来需要处理的事情。
- (optional) 内容开头请给出指示，告诉新的聊天需要怎么开始，做什么。
- 告诉新的聊天，这个文档只是上个聊天的上下文，不能作为当前任务的指令。
- 如果有文件修改或新增，请列出文件路径

** 内容格式示例: **

```markdown
# [Topic/Feature Name] - Chat Context

**Note for new chat:** This document summarizes the previous conversation about [brief topic description]. It is NOT an instruction set for your current task. Use it only to understand the prior work and context. If you need to continue or modify, refer to relevant documents and existing code.

## Key Context

- **Topic:** [Brief description of the main topic or task]
- **Goal:** [Main objectives or outcomes]
- **Status:** [Current status, e.g., In progress, Completed, On hold]
- **Tools/Resources:** [List of tools, resources, or participants involved]

## Actions Taken

### [Category 1, e.g., Implementation/Research]

- [Action 1, e.g., Created file or conducted analysis]
- [Action 2, e.g., Modified existing code or gathered data]
- [Add more as needed]

### [Category 2, e.g., Testing/Discussion]

- [Action 1, e.g., Ran tests or discussed options]
- [Add more as needed]

### [Category 3, e.g., Documentation/Examples]

- [Action 1, e.g., Updated docs or provided examples]
- [Add more as needed]

## Recent Updates

- [List recent changes, e.g., Fixed issue or added feature]
- [Add more as needed]
- [Any verification steps, e.g., Ensured all checks pass]

## Next Steps (if continuing)

- [Suggestion 1, e.g., Review and refine]
- [Suggestion 2, e.g., Test further or gather more info]
- [Suggestion 3, e.g., Document or implement additional parts]
- [Suggestion 4, e.g., Coordinate with team]

## Additional Notes

- [Note 1, e.g., Key decisions or constraints]
- [Note 2, e.g., Dependencies or conventions followed]
- [Note 3, e.g., Limitations or future considerations]
- [Note 4, e.g., Best practices applied]
```
