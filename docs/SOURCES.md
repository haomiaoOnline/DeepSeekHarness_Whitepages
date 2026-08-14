# 术语与来源

这份记录说明本文依据哪些材料写成，以及读者在什么情况下需要回到原始资料。

## 资料快照

- 核对日期为 2026-08-14，Asia/Shanghai
- 官方项目是 [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)
- 官方仓库快照为 [47f943859bef60e4160492346772ded9b24f765a](https://github.com/deepseek-ai/deepseek-harness/tree/47f943859bef60e4160492346772ded9b24f765a)
- 官方仓库根版本为 0.1.0-rc.5
- 官方 CLI 包版本为 @deepseek-ai/dsh 0.1.0-rc.5
- 参考教程是 [ht426/deepseek-harness-tutorial](https://github.com/ht426/deepseek-harness-tutorial)，核对到提交 [1d753a2](https://github.com/ht426/deepseek-harness-tutorial/commit/1d753a2f979b7db77ca5f03ee4c45945640067f7)

版本号、Node.js 要求、安装命令和插件接口都会变化。本文的命令和解释只对上述快照负责，后续更新应重新核对。

## 主要一手来源

| 来源 | 本文使用的事实 |
| --- | --- |
| [DeepSeek Harness 官方页面](https://www.deepseek.com/harness/) | 开发者预览定位、一切皆插件、模型与 Harness 的关系、运行模式、会话可追溯性和官方运行入口 |
| [官方中文 README](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/README.zh.md) | 项目名称、Cordis 依赖、开发者预览提示、npm 与源码运行方式、MIT 许可证 |
| [官方架构文档](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/docs/architecture.md) | Cordis、profile、bundle、patch、核心包、事件、turn/step、session log、能力接缝和扩展点 |
| [官方开发指南](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/docs/development.md) | Node.js 与 pnpm 前置条件、安装、typecheck、build、环境变量和真实 API 测试边界 |
| [官方 package.json](https://github.com/deepseek-ai/deepseek-harness/blob/47f943859bef60e4160492346772ded9b24f765a/package.json) | 仓库版本、Node.js engine、pnpm 版本和当前脚本名称 |

## 参考材料的使用方式

[ht426 的中文教程](https://github.com/ht426/deepseek-harness-tutorial)提供了按学习顺序组织源码的思路。本文借鉴了它把概念、运行、源码模块和扩展开发串成路线的做法，重新安排章节、重新撰写说明，并以官方快照重新核对命令和术语。

本文没有复制该项目的段落、封面图片或代码。参考项目采用 MIT License，版权归原作者所有。对参考项目的引用只说明来源，不代表作者之间存在合作关系。

## 事实层级

本文把内容分成三层。

1. 官方页面、官方仓库和官方文档直接写明的事实。
2. 根据源码结构做出的解释，例如把 profile 理解为一棵按层组合的插件树。
3. 为了帮助读者学习而给出的阅读建议和风险判断。

第二层和第三层属于本文作者的整理。涉及精确类型、事件签名、配置字段、发布版本或行为差异时，应回到官方仓库确认。

## 许可证和品牌边界

本仓库原创文字、原创 Mermaid 图和原创示例采用 MIT License。DeepSeek Harness、dsh、Cordis 以及官方项目中的代码、文档、图片和标识仍由各自权利人负责。本仓库没有获得官方背书，也不授予任何商标或品牌使用权。
