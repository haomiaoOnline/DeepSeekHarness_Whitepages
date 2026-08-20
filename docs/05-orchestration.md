# 05 编排与人类协作

## Agent 走到多轮任务时需要编排

一次请求可以由一个 Agent 完成。任务变长以后，系统需要安排子 Agent、重复执行、记录目标、等待后台工作，并在上下文变大时整理历史。官方仓库把这些能力拆成 subagent、workflow、todo、plan、goal、schedule、jobs、compaction 和 guard 等包。

这些名字表达的是不同问题。

- subagent 解决谁来继续做一段独立工作。
- workflow 解决多个步骤如何按顺序或条件运行。
- todo 记录任务清单和当前进度。
- plan 描述本轮准备采取的方案。
- goal 让同一个会话持续围绕一个目标推进。
- jobs 管理后台工作和结果领取。
- compaction 处理上下文过长后的整理。
- guard 负责循环卫生，减少任务已经结束却继续运行的情况。

## Subagent 不是简单复制上下文

子 Agent 需要一个清楚的任务边界。父 Agent 需要决定它能够看到什么、能改哪些文件、结果怎样回传，以及失败后谁负责处理。这里的重点是作用域和生命周期。

一个可靠的委派至少要说明下面四件事。

1. 目标和成功条件。
2. 可读取、可写入和禁止触碰的范围。
3. 需要返回的事实、文件或验证结果。
4. 失败、超时和需要人类决定时的处理方式。

官方架构文档把不同的 subagent provider 放在同一能力接缝后面。实现可以变化，调用方仍然围绕相同的 Agent 语义组织工作。

## 实验性 Agent Teams

当前版本还提供一条私有且显式启用的 Agent Teams seam。它在 `ctx.agentTeams` 上维护 Root Team 的成员 roster、持久 mailbox 和共享任务 DAG，并由 `@deepseek-ai/dsh-experimental-tool-agent-team` 暴露面向模型的工具。

Team member 拥有持久 Session 身份。Lead 与 teammate 之间的消息会先进入 Lead Session 的日志，目标 Session 记录 pending inbox 或最终用户消息后才完成交付确认。任务更新使用 revision 做 compare-and-set，`writeScopes` 只是提示性的路径前缀，不是文件锁。

这条能力仍处于实验阶段，当前 Web 或 headless 默认组合不应被理解为自动包含 Agent Teams。准备试用时，先确认对应实验包、profile 配置、共享 checkout 策略和权限边界，再把它当作普通 subagent 的替代方案。

## Workflow、Todo 和 Goal 的关系

Workflow 适合描述过程。Todo 适合显示过程中的清单。Goal 适合让同一个 Agent 继续处理同一个目标。三者可以组合，但职责不要互相覆盖。

例如一个源码迁移任务可以先用 workflow 规定扫描、修改、测试和总结四步。每一步内部用 todo 记录文件状态，整个会话用 goal 记住最终要完成的迁移。这样读者看到的状态和真正控制执行的机制会有对应关系。

## Plan 和审批

Plan 让模型先把行动写出来，人可以在执行前检查范围。Approval 把可能影响外部世界的动作交给人确认。两者解决的问题不同。

- Plan 主要解决理解和排序。
- Approval 主要解决授权和风险。

写文件、执行 Shell、访问网络、修改配置和使用凭据，都应该有明确的权限策略。提示词可以帮助模型理解约束，权限预设和审批机制才是实际的控制位置。

## 后台任务和调度

Schedule 与 jobs 都涉及延后处理，但生命周期不同。Schedule 的记录会进入原 Session 的日志，交付模式仍然是 session-local。冷 Session 不会自行执行到期工作，重新打开后才会重建 timer，并把已经过去的目标标记为 overdue。它通过普通对话 transcript 出现，不提供独立的 Web 回执。

`jobs-local` 是进程内的本地任务注册表。任务是否可读、可停和能否收到完成通知，取决于 owner Session、当前 Agent 和服务生命周期。进程退出、owner 清理或权限边界都可能让后台任务停止或失去可见性，不能把它写成跨进程的持久队列。

无论使用哪一种机制，都要确认结果有没有被持久化，任务回来后能否找到，以及它是否仍然拥有原先的凭据、工作区和权限。guard、job 状态和明确的停止入口应该纳入检查。

## 上下文压缩

Agent 长时间工作后，上下文会超过模型或成本的合适范围。compaction 可以整理旧消息、工具结果和中间状态，但压缩不能改变持久事实。读者可以把它理解为减少模型每次请求的可见历史，保留会话能够恢复的记录。

如果一个新状态只存在于被压缩掉的提示词里，后续模型就可能无法重建它。需要跨轮次保留的内容，应设计为日志事件、目标或持久数据。

## 人类协作的实际建议

先让系统把可逆动作和不可逆动作分开。重命名文件、运行测试和读取源码通常容易回退。删除数据、推送代码、执行外部命令和使用生产凭据需要更高的确认级别。

再让每个委派结果带着证据回来。只说“完成了”不够，至少要有变更位置、验证命令和未解决风险。这个习惯和 dsh 的运行轨迹设计放在一起，才能让长任务更容易检查。

## 本章事实源

- [官方架构文档](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/architecture.zh.md)
- [官方 Agent Teams 子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/agent-team.zh.md)
- [官方 Schedule 子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/schedule.zh.md)
- [官方 Jobs 子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/jobs.zh.md)
