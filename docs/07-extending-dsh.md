# 07 扩展 dsh

## 先选扩展点

扩展 dsh 的第一步是找到行为所属的接缝，再决定是否需要新建一个包。官方架构文档给出了一份很实用的对应关系。

| 你要添加的东西 | 优先查看的扩展点 |
| --- | --- |
| 新模型提供方 | ctx.llm 和 LLM adapter |
| 模型可见工具 | ctx.tools |
| Shell 或远程执行环境 | ctx.shell、ctx.subprocess、ctx.sandbox |
| 持久终端 | ctx.terminals |
| 人类命令 | ctx.commands |
| 后台任务 | ctx.jobs |
| 文件系统策略 | ctx.fs 或 fs 事件 |
| 请求、工具或轮次拦截 | agent 事件和 tools 事件 |
| UI Chat 节点 | ConversationNodeDefinition 和 renderer |
| 持久会话状态 | SessionEventMap 和日志投影 |
| 同一会话的目标 | ctx.goals |
| Agent Teams 协作 | 实验性 ctx.agentTeams 与 team 工具 |

这个表的意义在于限制改动范围。行为已经有接缝时，优先挂到接缝上。只有现有事件和服务无法表达需求时，才重新评估核心循环。

## 工具插件的基本路线

一个模型可见工具至少要处理四件事。

1. 定义输入 schema，让模型知道参数格式。
2. 定义执行函数和运行时依赖。
3. 决定工具属于哪个 Agent 作用域。
4. 把审批、权限、错误和结果格式接入工具管线。

工具结果是否写入 session event，要根据它是否属于用户需要恢复的事实来决定。临时的内部计算可以留在服务中，用户任务产生的外部变化需要能够回放和审计。

## LLM Adapter 的基本路线

新 adapter 需要先对齐 dsh 的消息和流词汇，再处理具体 provider 的认证、请求、重试和计量。适配器负责差异转换，Agent loop 不应该为每个 provider 复制一套循环。

开发时先阅读官方 LLM subsystem 和现有 provider，再从最小请求开始。先让单轮文本请求可验证，再加入流式输出、工具调用、错误重试和 token 计量。每加入一层，都要保留对应的测试和文档。

## 新 Provider 和新包

能力 provider 适合隐藏外部执行环境或服务差异。新包适合拥有自己的生命周期、配置和测试边界。两者都需要明确下面几项。

- Service Definition 放在哪里。
- Provider 由谁加载。
- Consumer 使用哪个 ctx key。
- 配置行由哪个 bundle 或 profile 提供。
- 卸载时哪些 effect 需要撤销。

官方仓库的 cookbook 提供了添加 package、tool、LLM adapter 和 conversation node 的路线。先按 cookbook 选择骨架，再回到当前版本的包 README 核对命令。

## UI 和协议扩展

Web Chat 节点需要同时考虑服务端注册、客户端 renderer 和会话事件。协议驱动的扩展则需要把输入、输出、错误、取消和会话标识写清楚。

设置页扩展还要同时注册 Host 侧的 settings namespace 和 Client 侧的 keyed card。卡片通过 `ctx.settingsScope` 读写对应 section，敏感字段应使用 secret 角色或 credentials 引用，重启后才生效的字段要标记 restart。当前官方 cookbook 把这条路径单独列出，适合在已有 Cordis entry 的插件上复用。

一个扩展能在本地运行，不代表它已经适合长期发布。公开插件还要补齐 README、许可证、版本要求、权限说明和最小复现步骤。官方 README 建议为插件仓库添加 dsh-plugin 话题，便于社区发现。

## 扩展后的检查顺序

~~~bash
pnpm run typecheck
pnpm run build
pnpm dsh --profile web --dump-config
~~~

再根据改动范围选择测试和文档检查。若改动涉及模型请求、文件写入、Shell 或凭据，增加一个失败路径检查和一个权限检查。最后确认新插件没有把密钥、个人路径或临时调试数据带进仓库。

## 本章事实源

- [官方架构文档](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/architecture.zh.md)
- [官方扩展实操手册](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/cookbook/extension-cookbook.zh.md)
- [官方设置卡片 Cookbook](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/cookbook/adding-a-settings-card.zh.md)
- [官方 Agent Teams 子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/agent-team.zh.md)
