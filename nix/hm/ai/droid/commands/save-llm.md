---
description: "Save chat context as documentation"
---

你的职责是保存聊天上方的文档内容到本地文件系统中。请确保文件名和内容格式正确。 如果你发现没有可以保存的文档，请告知用户。以 “我将查看可以保存的文档..“ 作为回复的开头。

*文件名*

- 如果是计划类的，则是 `llm/task-plan/<plan-name>_plan.md`
- 如果是文档类的，则是 `llm/documents/<document-name>.md
- 如果是报告类的，则是 `llm/reports/<report-name>.md`

*要求*

- 只查看聊天中输出的内容， 不要查看附件等
- 请务必保存到 `llm` 目录下的相应子目录中。
- 你的任务只是保存，不得进行任何修改和润色。
- 如果文件已存在，请覆盖旧文件。
- 请直接保存文件，避免额外的输出。
- 去除开头的无意义的问候语句
