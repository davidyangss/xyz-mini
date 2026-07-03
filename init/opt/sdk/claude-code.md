# Claude Code 安装说明

## 基本信息

- 用途：Anthropic 官方 AI 编码助手 CLI。
- 安装方式：官方 Native Install（推荐），自动更新。
- 当前版本：2.1.199

> 本项目 SDK 标准范围不包括 Claude Code；按需单独安装。

## Linux

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

安装位置：`~/.local/bin/claude`，支持后台自动更新。

## 环境配置

无需额外 PATH 配置（`~/.local/bin` 一般已在 PATH 中）。

若提示 `command not found: claude`：

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 配置可见性

配置文件 symlink 入口：

```bash
ls -l /xyz/etc/opt/claude-code/
# config -> /home/<user>/.claude
```

## 验证

```bash
claude --version
claude doctor
```

## 登录

```bash
claude
```

首次运行在浏览器中登录 Claude 账号（需 Pro/Max/Team/Enterprise 订阅）。

## 升级

Native Install 自动更新。手动触发：

```bash
claude update
```

## 注意事项

- 需要 Claude 付费订阅（Pro/Max/Team/Enterprise）。
- 配置文件位于 `~/.claude/`，含 `settings.json`、MCP 配置等。
- 不提交 `~/.claude/` 中的私钥和 token 到公开仓库。
