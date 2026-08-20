# 08 开发验证与限制

## 当前版本处于什么阶段

官方页面和官方 README 都把 DeepSeek Harness 标为开发者预览版，并明确提醒未来会出现破坏兼容性的变更。这个状态会影响教程的写法。

本文把命令、目录和类型说明绑定到 2026-08-20 核对的官方提交 141eb6fef83422698aef7a981029e843e8161534，根版本为 0.1.0-rc.8。读者使用更新版本时，先检查 README、package.json、docs/development.md 和 docs/architecture.md，再判断章节里的命令是否仍然成立。

## 验证矩阵

| 要验证的内容 | 不需要 API Key | 需要 API Key |
| --- | --- | --- |
| Node.js、Git、pnpm 版本 | 是 | 否 |
| 依赖安装 | 是 | 否 |
| typecheck | 是 | 否 |
| build | 是 | 否 |
| Web UI 能否启动 | 是 | 否 |
| headless Agent | 否 | 是 |
| ACP 自动化演示 | 否 | 是 |
| 真实 API 端到端测试 | 否 | 是 |

无密钥检查可以证明项目安装和构建路径具备可复核条件。它不能证明模型服务可用、当前密钥有权限，也不能证明某个任务输出符合预期。

## 发布前检查清单

### 文档检查

- README 的入口链接能够打开每个章节。
- 每个章节都能回到官方来源。
- Mermaid 图使用 GitHub 可以识别的语法。
- 命令中的目录、脚本和包名与资料快照一致。
- 需要凭据的步骤有明显标记。
- 没有把推测写成官方承诺。

### 安全检查

- 搜索 sk-、DEEPSEEK_API_KEY、token、password 等敏感字段。
- 删除真实个人路径、临时服务器地址和调试日志。
- 不把凭据写入 .env、截图、Markdown 或 Git 历史。
- 对 Shell、文件、网络和沙箱能力说明权限边界。

### 来源检查

- 保留官方页面、官方仓库和官方文档链接。
- 说明第三方教程只用于组织思路。
- 没有复制第三方段落、封面和代码。
- LICENSE 与来源说明保持一致。

## 如何维护这份白皮书

每次更新官方快照时，先做一次差异检查。

1. 记录新的提交号、版本号和核对日期。
2. 对照官方 README 和 development 文档更新安装段落。
3. 对照 architecture 文档检查包名、ctx key、事件和扩展点。
4. 重新运行无密钥验证。
5. 在 SOURCES.md 里记录发生了什么变化。

开发者预览期适合小步更新。一次改动最好只对应一组官方变化，读者才能看清命令和解释为什么发生变化。

## 本文的适用边界

这是一份源码导读和实践教程，适合帮助开发者理解 dsh 的公开设计和进入官方仓库。它不提供 DeepSeek API Key，不承诺特定模型输出，也不代替安全评审、生产部署检查或官方支持。

真正部署时，还需要补充自己的网络、权限、日志、密钥、数据留存和成本策略。尤其是 Shell、文件系统、远程执行和后台任务，必须在清楚的工作目录与授权范围内运行。

## 本章事实源

- [官方中文 README](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/README.zh.md)
- [官方开发指南](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/development.zh.md)
- [官方 package.json](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/package.json)
