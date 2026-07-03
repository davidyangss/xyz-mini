---
name: "xyz-sdk-install"
description: "为 xyz-mini 工作区安装或升级 SDK/工具/软件，遵守安装优先级规则（包管理器 > 官方 > 手动），同步更新 SDK 文档、环境脚本和 profile.d 索引。"
---

# xyz-sdk-install

为 `/xyz` 工作区安装或升级 SDK、开发工具或命令行软件，并同步维护相关文档。

## 目标

1. 按优先级选择安装方式：**包管理器（brew/apt） > 官方推荐 > 手动安装**
2. 遵守项目约束：默认使用官方路径（`~/.local`、`~/.config`），手动安装时遵守 `opt/` + `etc/` 分离
3. 记录安装信息到 SDK 文档（`init/opt/sdk/XXX.md`），**必须创建/更新**
4. 创建环境脚本（可选，若需要 PATH 或环境变量）
5. 更新 profile.d 索引（若创建了环境脚本）
6. 支持升级场景：优先查找已有 SDK 文档，按推荐方式升级

## 何时使用

- 用户要求"安装 XXX"或"安装软件 XXX"
- 用户要求"升级 XXX"或"更新 XXX"
- 需要为工作区新增开发工具链或命令行工具
- 需要记录已安装软件的版本和路径

## 先读文档（必读）

- `CLAUDE.md` 或 `AGENTS.md` — **软件安装规则**章节（包含安装优先级、配置路径约定、文档同步要求）
- `init/opt/sdk/init.md` — SDK 文档记录要求和公开版范围
- `init/etc/profile.d/bash/init.md` — 环境脚本索引格式和更新规则
- 已有 SDK 示例：`init/opt/sdk/go.md`、`rust.md`、`node.md` 等

## 前置假设

- 工作区根目录：`/xyz`（Linux）或用户指定的根路径
- 目标平台：macOS 或 Linux（通过 `uname` 或用户指定）
- 执行权限：部分操作需要 sudo（系统包管理器、手动安装到系统目录）
- 已有基础工具：`curl`/`wget`、`tar`、`ln`

---

## 标准流程

### 步骤 0：区分安装 vs 升级

检查是否已有 SDK 文档：

```bash
# 检查 SDK 文档是否存在
ls -la init/opt/sdk/{XXX}.md
ls -la init/opt/sdk/{XXX}/init.md
```

- **若存在** → 这是**升级任务**，跳到**步骤 7（升级流程）**
- **若不存在** → 这是**安装任务**，继续步骤 1

### 步骤 1：收集输入

确认以下信息（用户未指定时使用括号内默认值）：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `{XXX}` | 软件名（小写，如 `jq`、`ripgrep`） | *(必填)* |
| 目标平台 | macOS 或 Linux | 当前平台（`uname -s`） |
| 用途说明 | 一句话描述这个工具的用途 | *(询问用户)* |

### 步骤 2：确定安装方式

按以下优先级决策，**选择第一个可用的方式**：

#### 🥇 方式 A：包管理器（首选）

**macOS → brew**：
```bash
# 检查是否有 brew 包
brew search {XXX}
brew info {XXX}
# 若有，安装
brew install {XXX}
# GUI 应用
brew install --cask {XXX}
```

**Linux → apt（优先）/ yum / apk**：
```bash
# Debian/Ubuntu
apt-cache search {XXX}
sudo apt install {XXX}
# RHEL/CentOS
yum search {XXX}
sudo yum install {XXX}
```

包管理器安装后：
- **二进制文件**由包管理器管理，路径无需手动指定
- **配置文件**使用官方默认位置（通常 `~/.config/{XXX}` 或 `~/.{XXX}`）
- → 直接进入**步骤 4（配置文件处理）**

#### 🥈 方式 B：官方推荐安装（包管理器无此包时）

使用官方提供的安装脚本、安装器或包（如 `.sh`、`.pkg`、`.deb`、`.rpm`、`.AppImage` 等）：

```bash
# 示例：官方安装脚本
curl -fsSL https://example.com/install.sh | sh
# 或官方二进制包
curl -fsSL https://releases.example.com/{XXX}-linux-amd64.tar.gz -o /tmp/{XXX}.tar.gz
```

**判断默认安装位置**：
- 若官方默认安装到 `~/.local/bin`、`/usr/local/bin`、`~/.config/{XXX}` 等 → **使用默认位置**，不要强制重定向
- 记录实际安装路径（`which {XXX}`）
- → 进入**步骤 4（配置文件处理）**

#### 🥉 方式 C：手动安装（brew/apt 和官方均不可用时）

严格遵守项目路径约定：

| 类型 | macOS 路径 | Linux 路径 |
|------|-----------|-----------|
| 二进制 / 解压包 | `/xyz/opt/macos/sdk/{XXX}` | `/xyz/opt/linux/sdk/{XXX}` |
| 可执行文件（link）| `/xyz/bin/{XXX}` 或加入 PATH | `/xyz/bin/{XXX}` 或加入 PATH |
| 配置文件 | `/xyz/etc/opt/{XXX}/` | `/xyz/etc/opt/{XXX}/` |

```bash
# Linux 手动安装示例
sudo mkdir -p /xyz/opt/linux/sdk/{XXX}
curl -fsSL <download-url> -o /tmp/{XXX}.tar.gz
sudo tar -C /xyz/opt/linux/sdk/{XXX} -xzf /tmp/{XXX}.tar.gz
rm /tmp/{XXX}.tar.gz
```

→ 继续**步骤 3（手动配置运行环境）**

### 步骤 3：手动配置运行环境（仅方式 C 需要）

创建环境脚本，将二进制目录加入 PATH：

```bash
# /xyz/etc/profile.d/bash/{XXX}.sh（Linux 示例）
export {XXX}_HOME="${XYZ_ROOT}/opt/linux/sdk/{XXX}"
path_prepend_or_replace "${XXX_HOME}/bin"
```

验证可执行：

```bash
source /xyz/etc/profile.d/bash/0000-lib.sh
source /xyz/etc/env/linux/environment.sh
source /xyz/etc/profile.d/bash/{XXX}.sh
{XXX} --version
```

### 步骤 4：配置文件处理

**判断配置文件位置**：

| 场景 | 配置路径 | 操作 |
|------|---------|------|
| 官方有默认路径（`~/.config/{XXX}` 等） | 使用官方默认 | 在 `/xyz/etc/opt/{XXX}/` 创建指向官方路径的说明或 symlink |
| 无官方默认（手动安装，方式 C） | `/xyz/etc/opt/{XXX}/` | 直接在此创建配置文件 |

**当使用官方默认配置路径时，在 etc 中创建可见引用**：

```bash
# 在 /xyz/etc/opt/{XXX}/ 下创建 symlink 指向实际配置（使 etc 可见）
mkdir -p /xyz/etc/opt/{XXX}
# 若官方配置在 ~/.config/{XXX}/config.yaml
ln -sf ~/.config/{XXX}/config.yaml /xyz/etc/opt/{XXX}/config.yaml
# 或整个目录
ln -sf ~/.config/{XXX} /xyz/etc/opt/{XXX}/config
```

> **原则**：symlink 方向是 `/xyz/etc/opt/{XXX}/ → 实际配置路径`，使 etc 成为统一的"配置入口视图"，不移动实际文件。

### 步骤 5：创建 SDK 文档（**必须**）

**无论哪种安装方式，都必须创建** `/xyz/init/opt/sdk/{XXX}.md`。

参考 `init/opt/sdk/go.md` 格式，至少包含以下章节：

```markdown
# {XXX} 安装说明

## 基本信息

- 用途：[一句话描述]
- macOS 安装方式：[brew install {XXX} / 官方安装器 / 手动安装]
- Linux 安装方式：[apt install {XXX} / 官方脚本 / 手动安装]
- 当前版本：[记录实际安装版本，如 v1.2.3]

## macOS

[具体安装命令和步骤]

## Linux

[具体安装命令和步骤]

## 环境配置（可选 — 仅手动安装或需要 PATH 时）

脚本位置：[../../../etc/profile.d/bash/{XXX}.sh](../../../etc/profile.d/bash/{XXX}.sh)

```bash
[环境脚本内容，如 export PATH 等]
```

## 验证

```bash
{XXX} --version
# 或其他验证命令
```

## 升级步骤

macOS: `brew upgrade {XXX}`
Linux: `apt upgrade {XXX}` 或 [官方升级方式]

## 注意事项

[配置路径、缓存位置、已知问题等]
```

创建后验证：

```bash
ls -lh init/opt/sdk/{XXX}.md
cat init/opt/sdk/{XXX}.md
```

### 步骤 6：更新 profile.d 索引（若创建了环境脚本）

若在步骤 3 创建了 `etc/profile.d/bash/{XXX}.sh`，必须同步更新索引：

打开 `init/etc/profile.d/bash/init.md`，在 **SDK 环境脚本** 表格中新增一行：

```markdown
| `{XXX}.sh` + `{XXX}.linux.sh` | 两平台 | [{XXX}](../../../opt/sdk/{XXX}.md) |
```

或（若只有单平台）：

```markdown
| `{XXX}.sh` | Linux | [{XXX}](../../../opt/sdk/{XXX}.md) |
```

验证：

```bash
grep "{XXX}" init/etc/profile.d/bash/init.md
```

---

## 步骤 7：升级流程（当 SDK 文档已存在时）

<thinking>

This is the upgrade scenario - when the user says "upgrade XXX" and the SDK doc already exists.
</thinking>

从**步骤 0** 进入本流程时，SDK 文档已存在，说明软件已安装过。

**7.1 读取已有 SDK 文档**

```bash
cat init/opt/sdk/{XXX}.md
```

重点查看：
- **当前版本**：记录的版本号
- **升级步骤**章节：若文档中已记录推荐升级方式，优先使用

**7.2 按安装方式执行升级**

根据文档中记录的安装方式：

| 安装方式 | 升级命令 |
|---------|---------|
| brew | `brew upgrade {XXX}` |
| apt | `sudo apt update && sudo apt upgrade {XXX}` |
| 官方脚本 | 重新运行官方安装脚本，或查看官方升级文档 |
| 手动安装 | 下载新版本，解压覆盖到相同目录（先备份旧版本） |

**7.3 验证升级**

```bash
{XXX} --version
```

对比升级前后版本号。

**7.4 更新 SDK 文档中的版本号**

编辑 `init/opt/sdk/{XXX}.md`，更新 **当前版本** 字段：

```markdown
- 当前版本：v2.0.0（升级于 2026-07-03）
```

<thinking>

Good, I've added the upgrade flow. Now I need to add the verification section, notes, and delivery format to complete the skill.
</thinking>

**7.5 测试环境脚本（若有）**

若有环境脚本，重新 source 并验证：

```bash
source /xyz/etc/profile.d/bash/{XXX}.sh
{XXX} --version
echo $PATH | grep {XXX}
```

---

## 验证清单

安装完成后，逐项确认：

- [ ] `{XXX} --version` 输出正确版本
- [ ] `which {XXX}` 返回预期路径
- [ ] 若有配置文件：`ls /xyz/etc/opt/{XXX}/` 可见（symlink 或实际文件）
- [ ] `init/opt/sdk/{XXX}.md` 已创建，版本号已填写
- [ ] 若有环境脚本：`init/etc/profile.d/bash/init.md` 已更新对应条目

---

## 注意事项

1. **安装优先级不可颠倒**：必须先尝试包管理器，再尝试官方方式，最后才手动安装。
2. **尊重官方默认路径**：若官方推荐 `~/.local` 或 `~/.config`，不要强制重定向到 `/xyz`。
3. **symlink 方向**：`/xyz/etc/opt/{XXX}/ → 实际配置路径`（使 etc 成为可见入口，而不是移动文件）。
4. **SDK 文档必须创建**：无论哪种安装方式，都必须有 `init/opt/sdk/{XXX}.md`。
5. **版本号必须填写**：不能留空"按本机实际填写"，必须记录实际版本（`{XXX} --version`）。
6. **公开版约束**：不写真实代理节点、内网地址、个人主机名或私钥。
7. **升级前先查文档**：若 SDK 文档已存在，优先按文档中"升级步骤"执行。
8. **手动安装需 sudo**：安装到 `/xyz/opt/` 时需要 sudo 权限（若 `/xyz` 由 root 管理）。

---

## 交付格式

执行完成后输出包含以下信息的摘要：

### 安装场景

- 软件名称：`{XXX}`
- 安装方式：brew / apt / 官方脚本 / 手动安装到 `/xyz/opt/{platform}/sdk/{XXX}`
- 当前版本：`{XXX} --version` 输出
- 二进制路径：`which {XXX}` 输出
- 配置文件位置：实际路径 + 是否在 `/xyz/etc/opt/{XXX}/` 有 symlink
- SDK 文档路径：`init/opt/sdk/{XXX}.md`（已创建/已更新）
- 环境脚本路径：`etc/profile.d/bash/{XXX}.sh`（若有）
- profile.d 索引：是否已更新

### 升级场景

- 软件名称：`{XXX}`
- 升级前版本：[从文档读取]
- 升级后版本：`{XXX} --version` 输出
- 升级方式：brew upgrade / apt upgrade / 官方脚本 / 手动覆盖
- SDK 文档：版本号已更新为 [新版本]
