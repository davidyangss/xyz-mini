# Node.js 安装说明

## 基本信息

- 用途：Node.js、npm、npx 和前端/脚本工具链。
- macOS 推荐安装方式：`brew install node` 或使用版本管理器。
- **Linux 安装方式（强制）**：禁止使用 `apt install nodejs`，必须使用 `n` 版本管理器手动安装到 `/xyz/opt/linux/sdk/node`。
- 当前版本：v24.18.0（LTS），npm 11.16.0

> 本规则遵循 [AGENTS.md](../../../AGENTS.md) 中的安装优先级约定：Linux 下 Node.js 强制使用方式 🥉（手动安装，通过 `n` 管理）。

## macOS

```bash
brew install node
node --version
npm --version
```

## Linux

```bash
mkdir -p /xyz/opt/linux/sdk/node/bin /xyz/var/npm-cache
export N_PREFIX=/xyz/opt/linux/sdk/node
export PATH="$N_PREFIX/bin:$PATH"

# 安装 n 版本管理器
curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n -o "$N_PREFIX/bin/n"
chmod +x "$N_PREFIX/bin/n"

# 安装 Node.js LTS
n lts
```

## 环境配置

脚本位置：[../../../etc/profile.d/bash/nodejs.linux.sh](../../../etc/profile.d/bash/nodejs.linux.sh)

```bash
export N_PREFIX="${XYZ_ROOT:-/xyz}/opt/linux/sdk/node"
path_prepend_or_replace "$N_PREFIX/bin"
export npm_config_cache="${XYZ_ROOT:-/xyz}/var/npm-cache"
```

当前 shell 快速生效：

```bash
source /xyz/etc/profile.d/bash/nodejs.linux.sh
hash -r  # 刷新命令缓存
```

## 验证

```bash
node --version
npm --version
n --version
n ls
```

## 升级

1. 确保环境变量已生效：`source /xyz/etc/profile.d/bash/nodejs.linux.sh`
2. 执行 `n lts` 安装最新 LTS 版本。
3. 更新本文档中的版本号。

## 常用命令

```bash
n lts           # 安装最新 LTS
n latest        # 安装最新版本
n ls            # 列出已安装版本
n rm <version>  # 删除指定版本
```

## 注意事项

- npm 缓存重定向到 `/xyz/var/npm-cache`，避免散落到用户目录。
- 不提交 `node_modules/`。
- 系统自带的 `/usr/bin/node` 版本较低，确保 PATH 中 `/xyz/opt/linux/sdk/node/bin` 优先。
