# 09 本次更新记录

## 核对范围

我在 2026-08-20 重新读取了 DeepSeek Harness 官方仓库。当前 HEAD 是 `141eb6fef83422698aef7a981029e843e8161534`，合并提交的主题是 `0.1.0-rc.8` 发布。上一版白皮书使用的是 `47f943859bef60e4160492346772ded9b24f765a`，两者之间存在一批会影响教程的变更。

本章只记录会改变读者操作、架构理解或扩展路线的内容。大量 UI 样式、测试重排和内部重构没有逐项写入正文。精确类型和实现细节仍应回到官方快照核对。

## 对读者最有影响的变化

### Web 启动交接更明确

`npx @deepseek-ai/dsh web` 仍然使用 `http://127.0.0.1:3080`。本机启动时，当前运行时会尝试打开默认浏览器。`--no-open` 可以关闭这次浏览器交接。通过 SSH 启动时，程序只打印宿主机 URL，转发和本地打开由 SSH 客户端或编辑器负责。

源码运行需要先执行 `pnpm run build`。随后 `pnpm dsh web` 使用已经生成的库和 Web 资源，不会隐式替你重新构建。这个细节已经补进 01 章和 README。

### 模型输入扩展到图片

当前 LLM 公共内容块包含文本、推理、图片、工具调用和工具结果。DeepSeek 适配器在本次快照中支持多模态请求，图片以持久附件引用进入消息。附件服务还会在接纳阶段检查图片尺寸和存储边界。

这不等于所有模型路由都拥有相同的多模态能力。真正发送图片前，仍要确认所选 provider、模型和客户端组合支持该内容块。04 章现在把图片附件列入能力系统，并保留 provider 级限制。

### Agent Teams 进入实验性扩展面

官方新增了两个实验性包。`@deepseek-ai/dsh-experimental-agent-team` 提供 `ctx.agentTeams` 服务，`@deepseek-ai/dsh-experimental-tool-agent-team` 提供面向模型的工具层。它们围绕 Root Session 保存成员 roster、持久 mailbox 和共享任务 DAG。

Agent Teams 不等于普通 subagent 的别名。它有 Lead 和 teammate 的持久身份，消息在目标 Session 记录后才完成 mailbox 的交付确认，任务通过 revision 做并发更新。当前能力属于私有且显式启用的实验 seam，不能按默认 Web 功能向读者承诺。05 章和 07 章分别补充了使用边界与扩展入口。

### 设置扩展有了独立的卡片路线

官方新增了 settings card cookbook。插件可以在 Host 侧注册 settings namespace，在浏览器侧按同一 namespace 注册卡片，再由客户端 slot 系统把卡片挂入设置页。敏感字段应该使用 secret 角色或 credentials 引用，重启后才生效的字段需要明确标出 restart 语义。

这条路线让设置扩展不必把页面代码塞进核心 Web 应用。它也要求插件同时考虑 Host 与 Client 两侧的导出、依赖和构建。07 章的 UI 扩展说明已经加入这条检查线。

### 持久化和调度边界更清楚

当前 SQLite 会话后端使用新的物理分块布局，逻辑上仍然返回同一条 SessionEvent 流。这个优化属于实现细节，不能让读者误以为 JSONL 与 SQLite 拥有相同的文件结构。

Schedule 继续依附原 Session 的生命周期。冷 Session 不会自行执行到期工作，重新打开后才会重建 timer 并处理 overdue 状态。`jobs-local` 仍是进程内的本地任务注册表，拥有者、权限和清理都会影响任务是否可读或可停。05、06 章现在把这两个边界分开写。

## 本轮修正的旧稿问题

- Agent 流程图补上了无工具请求、多工具调用、`step/end` 和 `turn/end`，也区分了首次输入被拒绝时不产生 step 的路径。
- 源码检验命令统一写成 `pnpm dsh`，避免读者在没有全局安装 CLI 时复制出错。
- Web 启动与真实模型请求的密钥边界分开描述。
- Settings 的用户配置 schema 与 profile、bundle、patch 组合的 Cordis 配置分开描述。
- 每个章节补回固定提交的事实源，方便读者从本章直接回到官方资料。

## 验证边界

本轮核对了官方仓库提交、版本、文档和包清单，并重新执行了无密钥的安装、类型检查、构建和配置导出验证。没有设置 `DEEPSEEK_API_KEY`，因此没有把 Web 中的真实模型请求、headless、ACP 或真实 API 端到端测试写成已亲测结果。

## 本章事实源

- [官方中文 README](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/README.zh.md)
- [官方架构文档](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/architecture.zh.md)
- [官方开发指南](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/development.zh.md)
- [官方 Agent Teams 子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/agent-team.zh.md)
- [官方 LLM 流式协议](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/llm-streaming.zh.md)
- [官方附件子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/attachment.zh.md)
- [官方设置卡片 Cookbook](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/cookbook/adding-a-settings-card.zh.md)
- [官方持久化子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/persistence.zh.md)
- [官方 Schedule 子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/schedule.zh.md)
- [官方 Jobs 子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/jobs.zh.md)
