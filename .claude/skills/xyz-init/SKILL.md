---
name: "xyz-init"
description: "首次在新 remote 机器上初始化 /xyz 工作区：引导执行 xyz-bash-setup 和 xyz-home-mount，适配 Warp + SSH 工作流。"
---

# xyz-init

首次在新 remote 机器上初始化 `/xyz` 工作区的引导 skill。

## 目标

通过询问方式引导用户完成两个核心初始化步骤：
1. 配置系统 bash 启动链（`xyz-bash-setup`）
2. 挂载用户家目录（`xyz-home-mount`）

## 何时使用

- 刚将 xyz-mini 项目拷贝到新 remote 机器的 `/xyz` 目录
- 通过 Warp SSH 连接到 remote，`cd /xyz` 后首次运行 `/agent`
- 需要快速完成基础环境初始化

## 前置假设

- 项目已完整拷贝到 `/xyz`（不是其他路径）
- 当前通过 Warp SSH 连接到 remote 机器
- 有 sudo 权限（后续步骤需要）

## 已知问题

**Warp Remote + /agent 空屏**：通过 Warp 原生 SSH 连接 remote 后，执行 `/agent` 有较大概率出现空屏（无响应），这是 Warp 的已知故障。

**解决方案**：安装 [Warp SSH Extension](https://github.com/warpdotdev/Warp/blob/main/SSH_EXTENSION.md)，通过 extension 方式连接可稳定使用 `/agent`。

---

## 引导流程

### 开场确认

首先向用户确认当前状态：

> 我将引导你完成 /xyz 工作区的首次初始化，包括两个步骤：
> 1. 配置系统 bash 启动链
> 2. 挂载用户家目录
>
> 在开始前请确认：
> - [ ] 项目已拷贝到 /xyz
> - [ ] 当前用户有 sudo 权限（`sudo -s` 验证）
> - [ ] 目标用户名（将挂载 /home/{user}）

执行快速检查：

```bash
ls /xyz/etc/profile.d/bash/  # 确认工作区结构完整
whoami                        # 确认当前用户名
```

### 步骤 1：配置 bash 启动链

> **询问**：是否已配置过 /etc/bash.bashrc？（`grep "XYZ custom profile" /etc/bash.bashrc`）

- 若**未配置** → 执行 `xyz-bash-setup` skill
- 若**已配置** → 跳过，告知用户

执行 xyz-bash-setup 完成后，验证：

```bash
bash -ic 'echo "XYZ_ROOT=$XYZ_ROOT, XYZ_OS=$XYZ_OS"'
# 期望输出：XYZ_ROOT=/xyz, XYZ_OS=linux
```

### 步骤 2：挂载用户家目录

> **询问**：需要挂载哪个用户的家目录？（默认：当前用户 `$(whoami)`）

- 若**未挂载** → 执行 `xyz-home-mount` skill，传入用户名
- 若**已挂载**（`findmnt /home/{user}` 有输出）→ 跳过，告知用户

执行 xyz-home-mount 完成后，验证：

```bash
findmnt /home/{user}
sudo -u {user} bash -lc 'echo $HOME'
```

### 步骤 3：持久化环境变量

所有步骤完成后，执行 `xyzenv-store-path` 将 `XYZ_ROOT`、`XYZ_HOME_ROOT`、`XYZ_OS` 写入 `/etc/environment`：

```bash
sudo bash -c '. /xyz/etc/profile.d/bash/0000-lib.sh && . /xyz/etc/env/linux/environment.sh && xyzenv-store-path'
```

### 完成汇报

三步完成后，输出摘要：

```
✅ 初始化完成
──────────────────────────────
步骤 1 - bash.bashrc：已配置 / 已跳过
步骤 2 - home 挂载：/xyz/home/{user} → /home/{user} 已挂载 / 已跳过
步骤 3 - /etc/environment：已持久化 XYZ_ROOT/XYZ_HOME_ROOT/XYZ_OS
──────────────────────────────
下一步：重新登录或 exec bash 使配置生效
```

若任一步骤失败，说明失败原因并指向对应 skill 的回滚说明。
