# /xyz/etc/env/linux 说明

## 目录定位

`/xyz/etc/env/linux` 用于存放 Linux 平台的环境配置入口文件。

## 入口文件

| 源文件 | 部署目标 | 说明 |
|--------|----------|------|
| `sys-etc_bash.bashrc` | `/etc/bash.bashrc` | Linux 全局 bash 入口，加载所有环境配置 |
| `environment.sh` | — | 基础环境变量定义，被 `sys-etc_bash.bashrc` 加载 |

## 加载关系

```
/etc/bash.bashrc
├── 1. source /xyz/etc/profile.d/bash/0000-lib.sh   (提供 warn_if_env_set 等函数)
├── 2. source /xyz/etc/env/linux/environment.sh      (设置 XYZ_ROOT, XYZ_HOME_ROOT, XYZ_OS)
└── 3. for each *.sh in /xyz/etc/profile.d/bash/:
        source $i
        source ${i%.sh}.linux.sh  (如存在)
```

> 加载顺序有依赖关系：`0000-lib.sh` 必须先于 `environment.sh`（前者提供 `warn_if_env_set` 函数），`environment.sh` 必须先于其余脚本（提供 `$XYZ_ROOT` 等变量）。

## 部署

### 方式 1：软链（推荐）

```bash
sudo ln -sf /xyz/etc/env/linux/sys-etc_bash.bashrc /etc/bash.bashrc
```

### 方式 2：追加内容

将 `sys-etc_bash.bashrc` 中的 XYZ 自定义部分（从 `# XYZ custom profile scripts` 开始）追加到系统的 `/etc/bash.bashrc` 末尾。

## 环境变量说明

### `environment.sh` 定义的变量

- `XYZ_ROOT`：工程根目录（`/xyz`）
- `XYZ_HOME_ROOT`：用户主目录根（`/xyz/home`）
- `XYZ_OS`：平台标识（`linux`）

### `xyzenv-store-path()` 函数

调用此函数可将上述三个环境变量持久化到 `/etc/environment`，供系统启动和 PAM session 读取。

## 适合放置的内容

- Linux 平台环境变量
- 需要在系统初始化时生效的配置片段
- 与运行环境准备相关的启动脚本或样板

## 使用约定

- 这里的内容偏"Linux 平台环境准备"，macOS 平台配置放在 `/xyz/etc/env/macOS/`
- 只需要管理两个入口文件：`environment.sh` 和 `sys-etc_bash.bashrc`
- 如需修改加载逻辑，直接编辑这两个文件即可
