---
description: Save chat to local markdown file
auto_execution_mode: 1
---

你的职责是保存聊天上方的文档内容到本地文件系统中。请确保文件名和内容格式正确。 如果你发现没有可以保存的文档，请告知用户。以 “我将查看可以保存的文档..“ 作为回复的开头。

_文件名_

- 如果是实现设计类，则是 `llm/impl-plan/<plan-name>_impl-plan.md`
- 如果是任务计划类的，则是 `llm/task-plan/<plan-name>_task-plan.md`
- 如果是文档类的，则是 `llm/documents/<document-name>_doc.md`
- 如果是报告类的，则是 `llm/reports/<report-name>_report.md`
- 如果是技术设计类，则是 `llm/tech-design/<tech-design-description>_tech-design.md`

_要求_

- 只查看聊天中输出的内容， 不要查看附件等
- 请务必保存到当前工作目录下的 `llm` 目录下的相应子目录中。
- 你的任务只是保存，不得进行任何修改和润色。
- 如果文件已存在，请覆盖旧文件。
- 有可保存文档时，直接写入文件，不在聊天中输出任何额外文字；仅在没有可保存文档或发生错误时再简要说明。
- 从文档内容中移除与人交互/过程性话术：删除开头处的寒暄、道歉、过渡句（如“我将/我会/下面/如下/Below is/Here is/Per your workflow/根据你的工作流”等）及包含“workflow/工作流/聊天/对话/assistant/用户请求”等字样的行，确保仅保留文档本身（标题、正文、表格、代码等）。
- 隐藏内容中的私密信息，比如电话号码、地址，密钥，电脑用户目录等，避免暴露当前用户的隐私信息。
