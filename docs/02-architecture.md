# 02 总体架构

## Cordis 位于什么位置

官方架构文档把 Cordis 称为 dsh 的框架。插件可以向共享 Context 提供服务、类型化事件和可撤销的 effect。模型适配器、工具注册表、会话日志和 Agent 循环都以插件形式接入。

Cordis 的职责是加载、卸载和管理依赖关系。Agent 的具体能力由上层插件提供。这个分工让运行系统拥有清楚的插接面，也让开发者能够沿着服务和事件找到行为来源。

## Profile、Bundle 和 Patch

一个正在运行的 dsh 可以看成按层组合出来的插件树。

Profile 是存放在 Harness home 中的一份命名组合。它列出要叠加的 bundle，保存额外安装的插件，并保留 profile 自己的 cordis.patch.yml。web 和 headless 都有官方提供的模板。

Bundle 是 Cordis 配置行和它们所挂载代码的分发形式。每个 bundle 通过 package.json 里的 dsh 字段声明自己。dsh.profile 描述 profile 使用哪些 bundle，dsh.bundle 指向 bundle 的 patch 文件。

官方架构文档给出的覆盖顺序如下。

1. profile 列出的 bundle，按声明顺序应用。
2. profile 自己的 cordis.patch.yml。
3. Harness home 层的 patch。
4. 命令行传入的 --patch overlay。

patch 可以按 id 替换整行配置，也可以插入新行。执行 dsh --profile web --dump-config，可以看到机器实际启动的配置树。

## 核心包怎样分工

| 包 | 负责的事情 | Context 服务 |
| --- | --- | --- |
| core/session | 追加式 SessionEvent 日志和内存存储 | ctx.sessions |
| core/system-prompt | prompt section 和工具 schema 组装 | ctx.systemPrompt |
| core/tools | 作用域工具注册与受保护执行管线 | ctx.tools |
| core/agent | Agent 接口、运行中注册表和 agent 事件 | ctx.agents |
| core/agent-loop | 默认 Agent 驱动器 | ctx.agentLoop |
| core/scope | 每个 Agent 的作用域注册能力 | 无固定 key |
| llm/llm | 消息、流分片和模型适配器接缝 | ctx.llm |

这些包之间的关系比目录层级更重要。模型能力先看 llm 接缝，工具看 tools 注册表。需要恢复的运行事实应进入 session 事件。

## 事件是扩展点

官方文档把事件分成三类。

- Session 事件是需要写进追加日志的持久事实。
- Agent 事件携带正在运行的 Agent，用于观察或拦截进行中的工作。
- Capability 事件把策略和适配器挂到 fs、tools、telemetry 等接缝上。

Waterfall 事件需要监听器调用 next，才能把处理权继续交给后面的监听器。串行的 turn-stopping 事件不使用 next。读源码时，先确认事件类型和生命周期，再判断插件是否需要改写、阻断还是观察。

## 能力接缝

一个完整的能力接缝至少包含三部分。

1. Service Definition 声明接口。
2. Service Provider 提供实现。
3. Consumer 使用服务，常见形式是模型可见的工具。

例如把本地文件系统替换成远程沙箱，需要让 Shell、PTY 和 LSP 继续面对同一个执行世界。接缝的价值就在于替换 provider 时，消费方不需要分叉成另一套业务逻辑。

## 新行为放在哪里

| 目标 | 官方架构文档给出的方向 |
| --- | --- |
| 添加模型提供方 | 在 ctx.llm 上注册 adapter |
| 添加模型可见能力 | 注册到 ctx.tools |
| 给一个会话调整能力集合 | 组合 Agent preset，并按需使用 isolate realm |
| 添加 Shell 执行 | 注册 ctx.shell 后由 ctx.subprocess 启动 |
| 添加持久终端 | 提供 ctx.terminals 和 dsh-tool-terminal |
| 添加人类命令 | 注册到 ctx.commands |
| 添加后台工作 | 注册到 ctx.jobs |
| 添加文件系统或策略 | 提供 ctx.fs 或监听 fs 事件 |
| 拦截请求、工具或轮次 | 使用 agent 或 tools 相关事件 |
| 添加 Web Chat 节点 | 注册 ConversationNodeDefinition 和对应 renderer |

这里的表格适合做源码导航。真正开发前，应先阅读官方对应的 cookbook 和包 README。
