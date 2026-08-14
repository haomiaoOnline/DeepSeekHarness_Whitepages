# 03 Agent 核心循环

## Step 和 Turn

官方架构文档把 Step 定义为一次模型请求以及它调用的工具。Turn 是一组连续的 Step，它从输入被领取前开始，在没有待处理工作时结束。

这个区分很实用。模型发出一次请求，工具返回结果后又需要模型继续判断，这通常还是同一个 Turn 里的多个 Step。记录日志、计算上下文和处理停止条件时，不能把每次请求都当成一个完整任务。

## 一次 Turn 怎样流动

官方文档给出的主流程可以压缩成下面这张图。

~~~mermaid
flowchart TD
  Start["turn/start"] --> Claim["领取下一步输入与一条排队消息"]
  Claim --> Prompt["组装提示词片段与工具 schema"]
  Prompt --> Pre["agent/pre-step"]
  Pre -->|拒绝或空输入| End["关闭 Turn"]
  Pre --> Step["step/start"]
  Step --> User["追加 user/message"]
  User --> History["从日志推导模型历史"]
  History --> Request["agent/request"]
  Request --> Stream["llm/stream"]
  Stream --> Assistant["assistant/chunk 与 assistant/message"]
  Assistant --> ToolCall["tool/call"]
  ToolCall --> PreTool["tools/pre-execute"]
  PreTool --> Execute["tools/execute"]
  Execute --> PostTool["tools/post-execute"]
  PostTool --> ToolResult["tool/result"]
  ToolResult --> More{"是否还有待处理工作"}
  More -->|是| Claim
  More -->|否| Stop["agent/turn-stopping"]
  Stop --> End
~~~

流程中的每个位置都有自己的用途。agent/pre-step 可以拒绝或改写即将进入模型的输入。agent/request 连接 Agent 和模型适配器。llm/stream 处理流式分片。tools 的三个事件为策略、执行和结果加工提供接缝。

## Session log 负责什么

Session log 是模型上下文的来源。官方文档明确强调，模型看到的内容必须能够从日志重建。原始 assistant/chunk 事件保留流式输出，其他持久事件则承载用户消息、模型消息、工具调用和工具结果。

这条规则带来一个工程判断。只要新输入会进入模型请求，就需要考虑它是否有对应的 session event。如果只在内存里塞入一段上下文，恢复、分叉、导出和遥测可能无法得到同样的状态。

官方页面把运行轨迹也放在了这个思路里。系统记录提示词、工具调用、工具结果、子 Agent 调度和上下文注入，读者可以把它理解为让一次 Agent 运行拥有可回放的证据链。

## Agent、工具和模型的边界

Agent 循环负责推动工作。工具注册表负责把可用能力整理成 schema，并在执行前后接入策略。模型适配器负责把内部消息和流转换成具体提供方可以理解的请求。

这三者分开以后，工具可以被多个 Agent 使用，模型 provider 可以切换，循环也能在相同的事件语义上继续工作。调试时，先确认故障发生在请求组装、模型流、工具执行还是日志投影阶段。

## 取消和错误恢复

工具会返回错误，模型流也可能提前结束。输入在领取前被拒绝时，官方文档同样把它放在 Agent handle、事件和工具管线里处理。教程读者不需要先记住所有实现细节，但应该保留一个习惯。

- 先查 durable session event，确认事实是否写入日志。
- 再查 live agent event，确认工作是否还在运行。
- 最后查 provider 或工具实现，确认错误发生在外部依赖还是本地管线。

这样排查，比只看最后一条错误消息更容易还原一次运行到底走了哪条路径。
