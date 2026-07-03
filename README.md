# xyz-mini

一个面向 **AI 辅助开发**的工程化环境模板，与 [Warp Terminal](https://www.warp.dev/) 搭配使用时达到最佳体验。

## ✨ 推荐工作模式：Warp + SSH + /agent

```
本地 Warp
  └─ 配置 LLM Provider（一次）
  └─ SSH → 任意 remote 机器
      └─ cd /xyz
      └─ /agent "帮我安装 ripgrep"   ← AI 直接在 remote 操作
```

**核心优势**：
- 🖥️ **本地配置，远程生效** — 只在本地 Warp 配置一次 LLM Provider，SSH 进任何 remote 后 `/agent` 立即可用
- 📦 **remote 零安装** — remote 机器无需安装任何 AI agent，只需把本项目拷贝到 `/xyz`
- 📖 **约束即上下文** — AI 自动读取 `AGENTS.md`、`init/` 文档和 `.claude/skills/`，项目规则直接约束 AI 行为
- 🔁 **可迁移** — 换机器时拷贝 `/xyz`，重新运行 `xyz-init`，环境立即恢复

→ 详细说明见 [init/warp-usage.md](init/warp-usage.md)

## 🚀 快速开始

```bash
# 1. 拷贝项目到 remote 的 /xyz
rsync -avz --exclude='.git' xyz-mini/ user@remote:/xyz/

# 2. Warp SSH 连接
ssh user@remote
cd /xyz

# 3. 首次初始化（引导式）
/agent "执行 xyz-init skill"
```

`xyz-init` 会询问并依次完成：
- 配置 `/etc/bash.bashrc` 接入 xyz profile 启动链
- 将 `/xyz/home/{user}` 挂载为系统家目录

## 项目定位

本项目用于记录和复现开发环境：目录结构、安装步骤、环境变量、服务配置和 AI 协作规则。

- `/xyz` 是统一工程根目录（Linux 使用 `/xyz`，macOS 可映射为 `/idata`）
- `init/` 是知识库，镜像真实目录结构，每个目录都有对应说明文档
- `AGENTS.md` / `CLAUDE.md` 是 AI 操作约束入口，所有 AI 工具均受其约束
- `.claude/skills/` 提供标准化操作流程（安装、挂载、初始化等）

## 重要风险

本工程对系统 `$HOME` 有强约束，会改变默认预期，影响 SSH、GPG、GUI 应用等行为。

**本公开版只保留思想和模板，不建议直接用于生产机器。请先在测试环境验证。**

## 不包含的内容

- `home/<user>` 下的真实用户文件
- `var/` 下的数据库、缓存和日志
- 真实代理节点、证书、密钥、内网地址
- 除 Go、Rust、Java、Python、Node.js 之外的 SDK 记录

## 推荐阅读顺序

1. [init/warp-usage.md](init/warp-usage.md) — 工作模式说明
2. [AGENTS.md](AGENTS.md) — 项目规则和 AI 操作边界
3. [init/README.md](init/README.md) — 文档结构导航

