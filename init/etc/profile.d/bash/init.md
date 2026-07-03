# /xyz/etc/profile.d/bash 说明

## 目录定位

`/xyz/etc/profile.d/bash` 用于存放 Bash/Zsh 相关的启动片段，该目录下所有 `.sh` 文件会在 Shell 启动时按文件名排序后依次 source（两平台均生效）。

## 加载关系

加载逻辑由各平台入口文件统一调度：

- **Linux**：通过 `/etc/bash.bashrc` 追加 XYZ 加载块，覆盖**交互式登录 shell** 和**交互式非登录 shell**（Ubuntu 的登录 shell 默认会经过 `~/.profile` → `~/.bashrc` → `/etc/bash.bashrc` 链）。
- **macOS**：`/etc/zshenv` → `profile.d/bash/*.sh`

加载顺序由文件名决定（字典序），示例：`0000-lib.sh` → `go.sh`。每个共用脚本 `$i` 加载后，自动查找并加载 `${i%.sh}.${XYZ_OS}.sh`（如 `go.sh` 加载后加载 `go.linux.sh`）。

### Linux：/etc/bash.bashrc 修改内容

在系统 `/etc/bash.bashrc` 文件末尾追加以下代码块（**所有交互式 shell 的统一入口**）：

```bash
# XYZ custom profile scripts
if [ -d /xyz/etc/profile.d/bash ]; then
  # 1. Load lib first (provides warn_if_env_set, write_environment_file, etc.)
  [ -r /xyz/etc/profile.d/bash/0000-lib.sh ] && . /xyz/etc/profile.d/bash/0000-lib.sh

  # 2. Load base environment variables (XYZ_ROOT, XYZ_HOME_ROOT, XYZ_OS)
  [ -r /xyz/etc/env/linux/environment.sh ] && . /xyz/etc/env/linux/environment.sh

  # 3. Load common profile scripts (exclude lib and platform-specific *.*.sh)
  while IFS= read -r i; do
    case "$i" in
      */0000-lib.sh) continue ;;
      */*.*.*.sh) continue ;;
    esac

    if [ -r "$i" ]; then
      . "$i"
    fi

    p="${i%.sh}.${XYZ_OS}.sh"
    if [ -r "$p" ]; then
      . "$p"
    fi
  done < <(find /xyz/etc/profile.d/bash -name "*.sh" 2>/dev/null | sort)
  unset i
  unset p
fi
```

> 加载顺序有依赖关系：`0000-lib.sh` 必须先于 `environment.sh`（提供 `warn_if_env_set` 函数），`environment.sh` 必须先于其余脚本（提供 `$XYZ_ROOT` 等变量）。

### Linux：environment.sh 内容

创建 `/xyz/etc/env/linux/environment.sh`（公开版仅含基础三个变量）：

```bash
warn_if_env_set XYZ_ROOT /xyz
warn_if_env_set XYZ_HOME_ROOT /xyz/home
warn_if_env_set XYZ_OS linux

xyzenv-store-path() {
	write_environment_file /etc/environment <<EOF
XYZ_ROOT=$XYZ_ROOT
XYZ_HOME_ROOT=$XYZ_HOME_ROOT
XYZ_OS=$XYZ_OS
EOF
}
```

## 平台差异

| 项目 | macOS | Linux |
|------|-------|-------|
| Shell | Zsh | Bash |
| 入口文件 | `/etc/zshenv` | `/etc/bash.bashrc` |
| 平台特定脚本 | `*.macOS.sh` | `*.linux.sh` |

## 适合放置的内容

- Bash 工具函数库（如 `0000-lib.sh`）
- PATH 调整片段
- Shell 启动环境变量
- 与交互式 Bash 相关的初始化逻辑

## 使用约定

- 使用数字前缀控制加载顺序，例如 `0000-*.sh` 优先于其他文件
- 如某条配置依赖用户目录或特定系统路径，应明确写出依赖前提
- 敏感信息不要直接提交，使用模板或环境变量引用

## 脚本索引

### 核心脚本

- `0000-lib.sh`：公共函数库，提供 `path_prepend_or_replace`、`warn_if_env_set`、`write_environment_file`、`path-show` 等工具函数。

### SDK 环境脚本

| 脚本 | 平台 | SDK 文档 |
|------|------|----------|
| `go.sh` + `go.linux.sh` | 两平台 | [Go](../../../opt/sdk/go.md) |
| `java.sh` | Linux | [Java 生态](../../../opt/sdk/java/init.md) |
| `nodejs.sh` + `nodejs.linux.sh` | 两平台 | [Node.js](../../../opt/sdk/node.md) |
| `python.sh` | 两平台 | [Python](../../../opt/sdk/python.md) |
| `rust.sh` | 两平台 | [Rust](../../../opt/sdk/rust.md) |
