# /xyz Workspace Guide

本文件与 [AGENTS.md](AGENTS.md) 保持同义，用于兼容 Claude Code 等工具。若修改本文件，应同步修改 `AGENTS.md`。

## 项目定位

- 工程根目录因平台而异：
  - **macOS**：可使用 `/idata` 作为本机根目录，并在文档中映射为 `/xyz`。
  - **Linux**：使用 `/xyz`。
- 文档中统一使用 `/xyz` 作为泛指路径，实际执行时替换为当前平台的根目录。
- 本项目用于记录开发环境的目录结构、安装步骤、环境约定、服务配置和 AI 协作边界。

## 核心文档入口

```text
AGENTS.md / CLAUDE.md
  -> init/README.md
    -> init/init.md
      -> init/ai-guide.md
        -> 各目录 init.md 或 SDK 文档
```

修改不熟悉的目录前，应先阅读 `init/` 中对应的说明文档。

## 受保护目录

以下路径默认视为私有或高风险内容，不应在公开仓库中包含真实文件：

| 路径 | 说明 |
|---|---|
| `/xyz/home/<user>/` | 用户主目录和真实个人文件 |
| `/xyz/users/<user>/` | macOS 用户目录映射 |
| `/xyz/clouds/` | 云盘挂载点 |
| `/xyz/var/` | 运行数据、数据库、缓存、日志 |
| `/xyz/etc/opt/*/secret*` | 任何可能包含密钥的配置 |

公开版只保留 `.gitkeep`、模板和文档，不提交真实数据。

## AI 操作要求

- 修改目录前先读对应 `init.md`。
- 安装或记录新软件时，同步更新 SDK 文档、环境脚本和 profile.d 索引。
- 不执行未确认的 `rm`、`sudo`、force push 等高风险操作。
- 不把私钥、token、证书、代理节点、真实主机名写入文档。
- 本公开版不包含个人 skills；AI 不应假设 `.claude/skills` 存在。

## 软件安装规则（硬约束）

以下规则是项目强制约定，AI 和人工操作均须遵守。

### 1. 安装方式优先级

按以下顺序选择，**选第一个可用方式**，不可跳级：

| 优先级 | macOS | Linux |
|--------|-------|-------|
| 🥇 首选 | `brew install` / `brew install --cask` | `apt install` / `yum install` |
| 🥈 次选 | 官方安装脚本、`.pkg`、官方二进制包 | 官方安装脚本、`.deb`、`.rpm`、官方二进制包 |
| 🥉 最后 | 手动解压到 `/xyz/opt/macos/sdk/XXX` | 手动解压到 `/xyz/opt/linux/sdk/XXX` |

### 2. 路径约定

**默认安装（brew/apt/官方）**：
- 遵守官方默认路径，不强制重定向。
- 若官方默认为 `~/.local/bin`、`~/.config/XXX`、`/usr/local/bin` 等，**直接使用**。

**手动安装（方式 🥉）**：
- 二进制 / 解压包 → `/xyz/opt/{macos|linux}/sdk/XXX`
- 配置文件 → `/xyz/etc/opt/XXX/`

### 3. 配置文件可见性

在 `/xyz/etc/opt/XXX/` 下建立统一入口：

- **默认安装**：创建 symlink 指向实际路径（`ln -sf ~/.config/XXX/ /xyz/etc/opt/XXX/config`）
- **手动安装**：配置文件直接放 `/xyz/etc/opt/XXX/`

### 4. 文档同步（必须）

安装新软件 `XXX` 后，必须维护以下文件关系：

```text
init/opt/sdk/XXX.md          ← 必须创建，记录安装方式、版本、升级步骤
  <-> etc/profile.d/bash/XXX.sh        （若需要 PATH / 环境变量）
  <-> init/etc/profile.d/bash/init.md  （若创建了环境脚本，必须更新索引）
```

若有服务或配置：

```text
etc/systemd/system/XXX.service   （Linux 后台服务）
etc/launchd/XXX.plist            （macOS 后台服务）
etc/opt/XXX/                     （配置文件或 symlink 入口）
```

`init/opt/sdk/XXX.md` 至少记录：
- 安装方式（brew/apt/官方/手动）
- 实际安装版本
- 升级步骤
- 配置文件和二进制路径

### 5. 升级规则

升级软件 `XXX` 时：
1. 优先查找 `init/opt/sdk/XXX.md` 中的**升级步骤**章节。
2. 按文档记录的方式升级，不擅自改变安装方式。
3. 升级后更新文档中的版本号。

本公开版 SDK 范围限定为 Go、Rust、Java、Python、Node.js。

