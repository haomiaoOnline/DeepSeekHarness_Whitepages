# DeepSeek Harness 个人白皮书与实践教程

一份面向开发者的中文技术白皮书与实践教程，带你从 dsh 的定位读到插件扩展。

作者为 yumi。

文档状态为个人整理，基于下方列出的官方快照编写。后续版本需要重新核对。
资料快照为 2026-08-20，官方仓库提交 141eb6fef83422698aef7a981029e843e8161534，根版本为 0.1.0-rc.8。

> 本项目由个人独立整理，与 DeepSeek AI 没有隶属、代理或官方合作关系。本文不代表 DeepSeek 的官方立场，也不替代官方文档。DeepSeek Harness、dsh、Cordis 及相关名称和标识归其各自权利人所有。

## 这份文档讲什么

[DeepSeek Harness 官方页面](https://www.deepseek.com/harness/)把 Harness 描述为 Agent 的运行基础设施。模型负责理解和生成，Harness 负责让 Agent 接触环境、使用工具，并持续推进任务。官方项目的核心设计是“一切皆插件”，模型适配器、工具、会话、沙箱、存储、循环、调度和 UI 都可以由插件提供，并在配置层组合。

这份个人白皮书做三件事。

1. 把官方概念翻译成一条适合中文读者的学习路径。
2. 把架构、运行循环、能力接缝和扩展点串起来。
3. 把可运行步骤、凭据边界、版本风险和资料来源写清楚。

本文以官方源码和官方文档为事实底稿，参考 [ht426 的中文教程](https://github.com/ht426/deepseek-harness-tutorial) 的章节组织方式，所有正文重新撰写。参考项目的许可证和来源信息见 [来源与版本记录](docs/SOURCES.md)。

## 快速开始

### 直接体验 Web UI

安装 Node.js 后，按官方页面提供的方式运行。

~~~bash
npx @deepseek-ai/dsh web
~~~

默认 Web UI 地址为 http://127.0.0.1:3080。本机启动时，官方运行时会尝试打开默认浏览器，传入 `--no-open` 可以关闭这次交接。通过 SSH 启动时只打印宿主机 URL，实际转发地址由 SSH 客户端或编辑器提供。启动 Web 服务本身可以先不配置密钥，真实模型请求仍需要 DeepSeek 凭据。本文没有把未执行的真实 API 请求写成亲测结果。

### 从源码运行

官方仓库当前开发指南要求 Node.js ^22.19.0 或 >=24.0.0，项目固定使用 pnpm 11.7.0。源码路径可以按下面的顺序准备。

~~~bash
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
corepack enable
pnpm install
pnpm run typecheck
pnpm run build
pnpm dsh web
~~~

`pnpm run typecheck` 适合用来确认第一次安装已经完成。`pnpm run build` 会构建库和 Web 资源，`pnpm dsh web` 直接使用这些已构建产物。使用 Web 发送真实模型请求、headless、ACP 或真实 API 测试时，按照官方说明配置 `DEEPSEEK_API_KEY`，不要把密钥写入 Git。

## 章节目录

| 章节 | 你会得到什么 |
| --- | --- |
| [00 定位与阅读方法](docs/00-positioning.md) | Agent、Harness、dsh、资料边界和阅读路线 |
| [01 快速开始](docs/01-quick-start.md) | 前置环境、安装路径、凭据和常见卡点 |
| [02 总体架构](docs/02-architecture.md) | Cordis、插件树、profile、bundle、patch 和能力接缝 |
| [03 Agent 核心循环](docs/03-agent-loop.md) | session、turn、step、工具调用和追加日志 |
| [04 能力系统](docs/04-capabilities.md) | LLM、文件、Shell、终端、沙箱、Web、MCP 与 Skill |
| [05 编排与人类协作](docs/05-orchestration.md) | subagent、workflow、plan、goal、jobs、审批和权限 |
| [06 持久化与对外接口](docs/06-persistence-and-interfaces.md) | 会话数据、workspace、credentials、SDK、ACP、API 与 Web |
| [07 扩展 dsh](docs/07-extending-dsh.md) | 工具、适配器、provider、UI 节点和新包的选择方法 |
| [08 开发验证与限制](docs/08-development-and-limits.md) | 开发者预览、版本变化、验证口径和安全边界 |
| [09 本次更新记录](docs/09-updates-rc8.md) | 从 47f9438 到 141eb6f 的核对结果和新增能力 |
| [术语与来源](docs/SOURCES.md) | 术语速查、资料快照、致谢和引用边界 |

## English summary

This repository is an independent Chinese whitepaper and practical tutorial for DeepSeek Harness, authored by yumi. It explains the public architecture of dsh, including the Cordis plugin system, profiles and bundles, capability seams, the agent loop, session logs, orchestration, persistence, integrations, and extension points.

The document is based on the official DeepSeek Harness website and the pinned 0.1.0-rc.8 snapshot of the official open-source repository. It is not an official DeepSeek publication and does not claim affiliation with DeepSeek AI. Runtime instructions that require a DEEPSEEK_API_KEY are clearly marked. The repository is released under the MIT License.

## 阅读时请记住三件事

- 官方项目目前处于开发者预览阶段，接口可能发生破坏兼容性的变化。当前快照是 0.1.0-rc.8，不代表未来版本。
- 本文的架构解释服务于学习和源码导航，精确类型、配置字段和最新命令应回到[官方仓库](https://github.com/deepseek-ai/deepseek-harness)核对。
- 本地验证、公开资料整理和真实 API 调用属于不同事情。本文会把它们分开写。

## 许可证

本仓库原创内容采用 MIT License，详见 [LICENSE](LICENSE)。官方项目和第三方参考项目的代码、文档、图片及其许可证仍归原项目所有。本项目不重新分发它们的正文或图片。
