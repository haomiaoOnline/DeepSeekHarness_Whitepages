# 01 快速开始

## 这一章要完成什么

你会得到一条从环境准备到源码检查的最短路径。这里把“安装成功”“构建成功”和“真实 Agent 请求成功”分开处理，读者可以知道每一步到底验证了什么。

## 前置条件

官方开发指南给出的当前要求如下。

- Node.js 支持 22.19 及以上的 22.x 版本，或 24 及以上版本。
- 仓库固定使用 pnpm 11.7.0。
- Git 需要 2.26 或更新版本。
- Web UI 进程可以先无密钥启动。Web 中发送真实模型请求、headless、ACP 自动化演示和真实 API 端到端测试需要 DeepSeek API Key。

先检查本机版本。

~~~bash
node --version
pnpm --version
git --version
~~~

如果 pnpm 由 Corepack 管理，先运行下面的命令。

~~~bash
corepack enable
corepack prepare pnpm@11.7.0 --activate
~~~

不同系统对 Corepack 的预置方式可能不同。版本检查失败时，先处理 Node.js 和包管理器，再继续安装项目依赖。

## 路径一，直接启动 Web UI

官方页面提供了 npm 体验路径。

~~~bash
npx @deepseek-ai/dsh web
~~~

默认 Web UI 地址是 http://127.0.0.1:3080。这个命令适合快速认识界面和运行入口。它依赖当前 npm 分发结果，遇到版本差异时，应改用固定源码快照排查。

当前 Web 运行时在本机启动时会尝试打开默认浏览器。传入 `--no-open` 可以关闭这次交接。通过 SSH 启动时只打印宿主机 URL，实际转发地址由 SSH 客户端或编辑器提供。

## 路径二，从源码运行

~~~bash
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run typecheck
pnpm run build
pnpm dsh web
~~~

第一次安装后先跑 typecheck。它会完成官方开发指南规定的库构建和类型检查路径。确认基础检查通过后，再执行 build。源码运行的好处是你可以直接对照 packages、apps、docs 和 examples 阅读当前实现。

查看当前 profile 实际组合的配置树。

~~~bash
pnpm dsh --profile web --dump-config
~~~

输出内容可以用来定位某一项能力由哪个配置行提供，也能帮助你理解 bundle 和 patch 的覆盖顺序。

## 哪些步骤需要 API Key

Web 服务可以先在没有密钥的情况下启动。需要真实请求模型时，在当前 shell 或项目根目录的 gitignored .env 中设置下面的变量。

~~~bash
export DEEPSEEK_API_KEY=你的密钥
~~~

官方开发指南还提到可以用 DEEPSEEK_BASE_URL 指向兼容的 API 地址。没有密钥时，真实 API 端到端测试会跳过。无论采用哪种方式，都不要把密钥写进 README、日志、截图或 Git 历史。

本文不把 Web 页面能否完成真实对话写成已经验证的事实。安全的验证顺序是先完成版本、安装、typecheck 和 build，再在你自己的凭据环境里单独测试请求。

## 常见卡点

### pnpm 版本不对

优先确认 Node.js 版本，再让 Corepack 激活项目要求的 pnpm。不要在同一个仓库里混用多个包管理器生成的锁文件。

### 安装完成但 typecheck 失败

先保留完整错误信息，确认依赖安装没有被缓存或 postinstall 跳过。官方开发指南建议从仓库根目录重新安装依赖，再运行 typecheck。

### Web 能打开但模型不响应

检查 DEEPSEEK_API_KEY 是否只存在于当前进程，检查 API 地址是否与当前配置匹配。浏览器界面能启动，只说明本地服务启动路径工作，不能单独证明模型调用已经成功。headless、ACP 和真实 API 端到端测试则应在明确配置凭据后单独记录结果。

## 这一章的验收口径

无密钥检查能够说明环境、依赖、类型和构建流程是否可复核。真实对话还需要 API Key、可用的模型服务和当前版本支持的配置。两者在报告和文档里分别记录。

## 本章事实源

- [官方中文 README](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/README.zh.md)
- [官方开发指南](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/docs/development.zh.md)
- [官方 Web 组合包说明](https://github.com/deepseek-ai/deepseek-harness/blob/141eb6fef83422698aef7a981029e843e8161534/packages/bundle/web-app/README.zh.md)
