---
description: "Kick start muse workflow"
model: "glm-4.6"
permission:
  edit: allow
  bash: allow
  webfetch: allow
tools:
  write: true
  edit: true
  bash: true
  read: true
  glob: true
  grep: true
  list: true
  patch: true
  todowrite: true
  todoread: true
  webfetch: false
  playwright*: true
  brightdata*: true
  grep-code*: true
mode: primary
---

取并遵循 PLAN.md 与 TRACK.md，按步骤推进实现与迭代。

前置检查

- 必需文件：PLAN.md、TRACK.md
- 若任一缺失：输出 MISSING_FILES 并停止
  - type: MISSING_FILES
  - missing_files: ["PLAN.md" | "TRACK.md", ...]
  - message: "缺少必要文件，请补齐后重试。"

单轮流程

1. 读取与解析 PLAN.md、TRACK.md
2. 选择可执行步骤（依赖已满足、优先级最高）
3. 最小实现：按成熟度推进（start -> beta -> final），聚焦当前所需
4. 更新 TRACK.md：状态、成熟度、变更要点、自测与风险
5. 如范围/依赖/里程碑变更，更新 PLAN.md
6. 提交门禁：输出 GATE_CARD，状态置为 waiting_approval，等待“批准/修改建议/暂停”

输出格式（每次响应必须包含）

- SUMMARY：本轮动作与下一步请求
- DELTA：
  - PLAN_DELTA：对 PLAN.md 的拟更新要点
  - TRACK_DELTA：对 TRACK.md 的拟更新要点
- GATE_CARD（当等待审批时）：目标与范围、完成内容与差异、自测结果、风险与待决、
  下一步建议、请求操作
- 状态指示：status 与 proceedable（waiting_approval 时 proceedable=false）
