# Warp 使用说明

本项目与 [Warp Terminal](https://www.warp.dev/) 搭配使用时达到最佳体验。

## 为什么是最佳组合

| 特性 | 说明 |
|------|------|
| **本地配置，远程生效** | 在本地 Warp 配置 LLM Provider，SSH 到 remote 后 `/agent` 直接可用 |
| **无需 remote 安装** | Remote 机器无需安装任何 AI agent |
| **结构化工作区即上下文** | `/xyz` 的 `AGENTS.md`、`init/` 文档、`.claude/skills/` 自动成为 AI 上下文 |
| **降低环境要求** | Remote 只需 bash、sudo 和基础工具（curl、tar） |

## 工作流

```
本地机器（Warp）
  └─ 配置 LLM Provider（Settings → AI → 选择 Provider）
  └─ SSH → remote 机器
      └─ cd /xyz
      └─ /agent "..."   ← AI 直接在 remote 执行
```

## 首次设置

### 1. 本地 Warp 配置

打开 Warp → **Settings** → **AI**：
- 选择 LLM Provider（推荐 Anthropic / OpenAI）
- 配置 API Key
- 测试 `/agent` 功能（在本地任意目录输入 `/agent hello`）

### 2. 拷贝项目到 remote

将 `xyz-mini` 项目拷贝到 remote 机器的 `/xyz` 目录（必须是根目录下的 `/xyz`）：

```bash
# 方式 A：rsync
rsync -avz --exclude='.git' xyz-mini/ user@remote:/xyz/

# 方式 B：tar + scp
tar -czf xyz.tar.gz xyz-mini/
scp xyz.tar.gz user@remote:/tmp/
ssh user@remote "sudo tar -xzf /tmp/xyz.tar.gz -C / && sudo mv /xyz-mini /xyz"
```

### 3. 首次初始化

通过 Warp SSH 连接到 remote：

```bash
ssh user@remote
cd /xyz
/agent "执行 xyz-init skill"
```

`xyz-init` 会引导你完成：
- 配置 `/etc/bash.bashrc`（xyz-bash-setup）
- 挂载用户家目录（xyz-home-mount）

完成后重新登录或 `exec bash` 使配置生效。

## 日常使用

```bash
# Warp 本地
ssh user@remote
cd /xyz

# 直接对话
/agent "帮我安装 ripgrep"           # 触发 xyz-sdk-install
/agent "升级 go"                    # 触发 xyz-sdk-install 升级流程
/agent "查看当前挂载状态"

# 明确调用 skill
/agent "执行 xyz-sdk-install skill 安装 jq"
```

## 注意事项

- `/xyz` 必须是根目录下的 `/xyz`，路径写死在脚本和文档里
- Warp `/agent` 读取 `AGENTS.md`，所有项目约束（安装规则、受保护目录等）对 AI 自动生效
- Remote 机器只需完成一次 `xyz-init`；之后每次 SSH 进来直接 `/agent` 即可

