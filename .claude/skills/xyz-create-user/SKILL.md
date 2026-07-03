---
name: "xyz-create-user"
description: "在 xyz-mini 工作区中创建新用户：创建系统用户、建立 /xyz/home/{user} 目录、bind mount 到 /home/{user}、配置 fstab 自动挂载。触发词：创建用户xxx。"
---

# xyz-create-user

为 xyz-mini 工作区创建新用户并完成家目录挂载。

## 目标

在 `/xyz` 工作区中创建一个完整的新用户，包括：
1. 创建系统用户
2. 建立 `/xyz/home/{user}` 目录
3. bind mount 到 `/home/{user}`
4. 写入 `/etc/fstab` 实现开机自动挂载

## 何时使用

- 用户输入 **"创建用户xxx"** 时触发
- 需要在新机器上为团队成员创建独立用户
- 需要为不同项目/角色创建隔离的用户环境

## 前置假设

- `/xyz` 工作区已完成初始化（bash 启动链已配置）
- 当前通过 Warp SSH 连接到 remote 机器
- 有 sudo 权限（`sudo -s` 可用）

---

## 引导流程

### 步骤 1：收集输入

从用户输入中提取 `{user}`，若未明确指定则询问：

| 参数 | 说明 | 来源 |
|------|------|------|
| `{user}` | 新用户名 | 从 "创建用户xxx" 解析 |
| UID | 自动分配或指定 | 默认自动 |

确认信息并告知用户将执行的操作：

> 将创建用户 {user}，包括：
> 1. 创建系统用户
> 2. 建立 /xyz/home/{user}
> 3. bind mount 到 /home/{user}
> 4. 写入 /etc/fstab

### 步骤 2：检查现状

```bash
# 检查用户是否已存在
id {user} 2>/dev/null && echo "USER_EXISTS" || echo "USER_NOT_EXISTS"

# 检查 /xyz/home/{user} 是否存在
ls -ld /xyz/home/{user} 2>/dev/null && echo "XYZ_HOME_EXISTS" || echo "XYZ_HOME_NOT_EXISTS"

# 检查 /home/{user} 是否存在
ls -ld /home/{user} 2>/dev/null && echo "SYS_HOME_EXISTS" || echo "SYS_HOME_NOT_EXISTS"

# 检查是否已挂载
findmnt /home/{user} 2>/dev/null && echo "MOUNTED" || echo "NOT_MOUNTED"

# 检查 fstab 条目
grep "/xyz/home/{user}" /etc/fstab 2>/dev/null && echo "FSTAB_EXISTS" || echo "FSTAB_NOT_EXISTS"
```

- 若用户已存在 → 跳过步骤 3
- 若挂载已完成 → 跳过步骤 5-6

### 步骤 3：创建系统用户

```bash
# 创建用户（使用默认 shell /bin/bash）
sudo useradd -m -s /bin/bash {user}

# 验证
id {user}
getent passwd {user}
```

> `useradd -m` 会创建 `/home/{user}`，后续 bind mount 会覆盖它。
> 若需要指定 UID：`sudo useradd -m -u {uid} -s /bin/bash {user}`

### 步骤 4：准备 /xyz/home/{user}

**场景 A**：`/xyz/home/{user}` 不存在

```bash
sudo mkdir -p /xyz/home/{user}
sudo chown -R {user}:{user} /xyz/home/{user}
```

**场景 B**：`/xyz/home/{user}` 已存在

验证权限：

```bash
stat -c '%U:%G %a' /xyz/home/{user}
```

若属主不匹配，修正：

```bash
sudo chown -R {user}:{user} /xyz/home/{user}
```

**迁移 `/home/{user}` 中 useradd 自动生成的文件**：

```bash
# 复制系统创建时的骨架文件到工作区
sudo cp -a /home/{user}/. /xyz/home/{user}/ 2>/dev/null
ls -la /xyz/home/{user}/
```

### 步骤 5：配置自动挂载

检查并写入 `/etc/fstab`：

```bash
grep "/xyz/home/{user}" /etc/fstab || \
  printf '/xyz/home/{user} /home/{user} none bind 0 0\n' | sudo tee -a /etc/fstab
```

验证 fstab：

```bash
grep "/xyz/home/{user}" /etc/fstab
# 期望：/xyz/home/{user} /home/{user} none bind 0 0
```

### 步骤 6：执行挂载

```bash
sudo mount --bind /xyz/home/{user} /home/{user}
```

若 `/home/{user}` 已被 useradd 创建且挂载失败，先确保挂载点存在：

```bash
sudo mkdir -p /home/{user}
sudo mount --bind /xyz/home/{user} /home/{user}
```

### 步骤 7：验证

```bash
# 挂载验证
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS /home/{user}

# 用户环境验证
sudo -u {user} bash -lc 'echo "HOME=$HOME" && pwd && ls -la ~'

# 权限验证
stat -c '%U:%G %a' /home/{user}
```

### 步骤 8：持久化环境变量

```bash
sudo bash -c '. /xyz/etc/profile.d/bash/0000-lib.sh && . /xyz/etc/env/linux/environment.sh && xyzenv-store-path'
```

### 完成汇报

```
✅ 用户 {user} 创建完成
──────────────────────────────
系统用户：已创建（uid=N）
/xyz/home/{user}：已建立
挂载：/xyz/home/{user} → /home/{user} (bind)
fstab：已写入
/etc/environment：已持久化
──────────────────────────────
```

---

## 回滚方法

```bash
# 1. 卸载
sudo umount /home/{user}

# 2. 删除 fstab 条目
sudo sed -i '\|/xyz/home/{user}|d' /etc/fstab

# 3. 删除系统用户
sudo userdel -r {user}

# 4. 清理工作区目录（谨慎）
sudo rm -rf /xyz/home/{user}
```

---

## 注意事项

- 不要在已有重要数据的机器上对同名用户执行此流程。
- `useradd -m` 会自动复制 `/etc/skel` 骨架文件，bind mount 前需将其迁移到 `/xyz/home/{user}`。
- 如果用户已存在于系统中，只执行目录准备和挂载步骤。
- 本 skill 不涉及 SSH key、密码设置等安全配置，这些由用户手动完成。
