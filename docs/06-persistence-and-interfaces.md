# 06 持久化与对外接口

## 会话日志是数据平面的起点

官方架构文档把 session log 称为模型上下文的来源。用户消息、模型消息、工具调用、工具结果和流式分片按照事件写入。恢复、分叉、转录、遥测和持久化都从这条事件流派生。

这种设计把一次运行变成了可以重建的事实序列。模型下一次请求看到了什么，应该能从日志找到依据。UI 展示的轨迹和后端保存的事件也拥有同一个来源。

## Projection 负责提供不同视图

一条追加式事件流适合保存事实，查询和 UI 则需要更容易消费的视图。projection 可以把事件折叠成会话列表、消息列表、标题、遥测或导出数据。

这里要区分原始事件和派生视图。

- 原始事件回答发生过什么。
- projection 回答用户现在需要看到什么。
- 查询服务负责按条件定位事件或投影。

当一个投影出现错误时，优先确认源事件是否正确，再修复投影逻辑。直接改展示结果，会让下次重建继续产生同样的问题。

## Workspace、Settings 和 Credentials

Workspace 说明 Agent 在哪个文件环境中工作。Settings 保存运行配置。Credentials 管理需要保护的密钥和身份信息。它们在产品里承担不同的责任，不能都塞进一个配置文件。

教程读者至少要记住下面几点。

- 工作目录决定文件和进程看到的环境。
- profile、bundle 和 patch 组合的是 Cordis 运行配置。
- Settings 按 schema 默认值、插件提供的 composition base 和用户自己的 section 处理用户设置。
- 凭据应由受保护的存储或环境变量提供。
- 日志和截图不能泄露 API Key。

官方开发指南示例使用 DEEPSEEK_API_KEY 和可选的 DEEPSEEK_BASE_URL。真实项目里还需要结合自己的密钥管理和网络策略。

当前快照的可选 SQLite 会话后端还优化了物理存储布局。相同分片块中的连续 delta 可以被打包到有界的 text、reasoning 和 tool-call 行，读取时再重建逻辑 SessionEvent 流。这个实现细节不改变会话日志作为事实来源的原则，也不代表 JSONL 与 SQLite 可以直接互换文件。

## 对外接口的几种路径

| 接口 | 适合的使用方式 |
| --- | --- |
| Web GUI | 人直接操作的浏览器界面 |
| SDK | 进程外应用驱动 dsh 能力 |
| ACP | 通过 Agent Client Protocol 自动化会话 |
| API 网关 | 让服务以类型化远程方法对外提供能力 |
| hooks | 把 dsh 与外部 Agent 或开发工具连接起来 |
| JSON-RPC stdio | 适合本地自动化和进程间通信 |

官方仓库同时维护 Host 和 Client 两侧的包。Web 运行需要关心服务端和浏览器端的组合，SDK、ACP 和 API 需要关心协议边界以及会话生命周期。

## 选接口前先问三个问题

第一，调用者是人还是程序。人操作优先看 Web GUI，程序驱动优先看 SDK、ACP 或 API。

第二，调用者是否需要保持会话。一次性任务可以使用 headless 路径，长会话需要确认持久化和恢复接口。

第三，调用者需要哪类权限。可以读取项目的接口，和能够执行命令、写文件、访问网络的接口，风险等级不同。

## 数据流阅读方法

从用户消息进入会话开始，沿着 SessionEvent、projection、查询和 UI 追踪。模型请求相关内容，再沿 deriveMessages 或等价的消息投影回到模型适配器。工具结果则沿 tool event 进入日志，并回到下一步请求。

这样读代码，能把“界面没有显示”“模型没看到”“工具没有执行”区分成三个不同问题。

## 本章事实源

- [官方架构文档](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/architecture.zh.md)
- [官方持久化子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/persistence.zh.md)
- [官方 Settings 子系统](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/subsystems/settings.zh.md)
- [官方会话持久化目录](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/persistence-catalog.zh.md)
