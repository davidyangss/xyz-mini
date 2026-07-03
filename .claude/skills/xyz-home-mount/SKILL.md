---
name: "xyz-home-mount"
description: "为 xyz-mini 工作区挂载用户目录：将 /xyz/home/{user} bind mount 到 /home/{user}，并写入 /etc/fstab 实现开机自动挂载。"
---

# xyz-home-mount

为 `/xyz` 工作区挂载用户家目录到系统标准位置。

## 目标

将工作区内的 `/xyz/home/{user}` 通过 `bind mount` 映射为系统的 `/home/{user}`，使系统用户直接使用工作区目录作为家目录。

## 何时使用

- 新机器初始化，需要把工作区用户目录接入系统
- 重建用户环境时，`/home/{user}` 指向错误或未挂载
- `/etc/fstab` 中缺失 bind mount 条目
- 用户要求为 xyz-mini 完成 home 的挂载

## 先读文档

在执行前应先阅读以下文档：

- `init/home/init.md` — home 目录约定与公开版约束
- `init/etc/init.md` — etc 目录结构说明
- `init/etc/profile.d/bash/init.md` — bash 启动链说明（挂载完成后需配合 bash 初始化）

## 前置假设

- 工作区根目录：`/xyz`（Linux 标准路径）
- 工作区用户目录：`/xyz/home/{user}`
- 系统家目录挂载点：`/home/{user}`
- 执行需要：root 或 sudo 权限
- 用户已存在于系统中（通过 `id {user}` 验证）

## 执行原则

- **先检查，再修改**：每步操作前先检查当前状态。
- **保护原有数据**：`/home/{user}` 如有内容，先复制到 `/xyz/home/{user}` 再 bind mount。
- **只用 bind mount**：不替换整个 `/home`，只操作单个用户目录。
- **明确说明变更范围**：每步执行前列出将修改的系统文件。
- **系统文件需要提权**：`/etc/fstab`、`mount` 操作均需 sudo。

---

## 标准流程

### 1. 收集输入

确认以下信息（用户未指定时使用括号内默认值）：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `{user}` | 目标系统用户名 | *(必填)* |
| `XYZ_ROOT` | 工作区根目录 | `/xyz` |
| 工作区家目录 | `{XYZ_ROOT}/home/{user}` | `/xyz/home/{user}` |
| 系统挂载点 | `/home/{user}` | `/home/{user}` |
| 数据迁移方式 | 先复制原 `/home/{user}`，再挂载 | 复制优先 |

### 2. 检查系统现状

执行前至少检查以下项：

```bash
# 用户是否存在
id {user}
getent passwd {user}

# 目录状态
ls -ld /xyz/home/{user}
ls -ld /home/{user}

# 挂载状态
findmnt /home/{user}
grep '/home/{user}' /etc/fstab

# 权限检查
stat -c '%U:%G %a' /xyz/home/{user} /home/{user}
```

记录以下事实：
- 用户是否存在
- `/xyz/home/{user}` 是否存在及权限
- `/home/{user}` 是否存在、是否已挂载、是否有内容
- `/etc/fstab` 中是否已有该用户的 bind mount 条目

### 3. 准备 `/xyz/home/{user}`

**场景 A**：`/xyz/home/{user}` 不存在

```bash
sudo mkdir -p /xyz/home/{user}
sudo chown -R {user}:{user} /xyz/home/{user}
```

**场景 B**：`/xyz/home/{user}` 已存在但 `/home/{user}` 有内容需要迁移

```bash
# 复制原有内容到工作区（保留权限、属性）
sudo rsync -aHAX /home/{user}/ /xyz/home/{user}/

# 验证复制结果
ls -la /xyz/home/{user}
```

复制后检查：
- 关键文件是否存在（如 `.bashrc`、`.profile`）
- 属主和权限是否正确

### 4. 配置自动挂载（/etc/fstab）

检查 `/etc/fstab` 是否已有该条目：

```bash
grep "/xyz/home/{user}" /etc/fstab
```

若不存在，追加：

```bash
printf '/xyz/home/{user} /home/{user} none bind 0 0\n' | sudo tee -a /etc/fstab
```

写入后验证：

```bash
grep "/xyz/home/{user}" /etc/fstab
```

期望输出：

```
/xyz/home/{user} /home/{user} none bind 0 0
```

### 5. 立即挂载

```bash
# 方式 A：重新挂载所有 fstab 条目（适合首次初始化）
sudo mount -a

# 方式 B：单独挂载（更安全，不影响其他挂载）
sudo mount --bind /xyz/home/{user} /home/{user}
```

> 若挂载失败（`/home/{user}` 不存在），先创建挂载点：
> ```bash
> sudo mkdir -p /home/{user}
> sudo chown {user}:{user} /home/{user}
> sudo mount --bind /xyz/home/{user} /home/{user}
> ```

### 6. 验证结果

执行以下检查确认挂载成功：

```bash
# 挂载点验证
findmnt /home/{user}
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS /home/{user}

# 用户环境验证
sudo -u {user} bash -lc 'echo $HOME && pwd'
sudo -u {user} bash -lc 'ls -la ~'

# fstab 条目验证
grep "/xyz/home/{user}" /etc/fstab
```

期望结果：
- `findmnt` 输出显示 `/home/{user}` 挂载源为 `/xyz/home/{user}`，类型为 `none`，选项包含 `bind`
- `sudo -u {user}` 命令能正常执行，`$HOME` 指向 `/home/{user}`
- `/etc/fstab` 包含正确的 bind mount 条目

---

## 回滚方法

挂载配置有问题时，按以下步骤回滚：

```bash
# 1. 卸载
sudo umount /home/{user}

# 2. 从 fstab 删除该条目（手动编辑）
sudo nano /etc/fstab
# 删除：/xyz/home/{user} /home/{user} none bind 0 0

# 3. 验证卸载
findmnt /home/{user}   # 应无输出
ls /home/{user}        # 应恢复原始内容（若之前有）
```

> **重要**：不要删除 `/xyz/home/{user}` 中已复制过去的数据。

---

## 注意事项

- **不要覆盖已有数据**：`/home/{user}` 有内容时必须先复制，再挂载。
- **不操作整个 `/home`**：只处理目标用户，不影响其他用户目录。
- **`/etc/environment` 不支持 shell 逻辑**：适合写简单变量，复杂初始化放 `profile.d`。
- **无法提权时**：告知用户在宿主机手动执行相关命令。
- **文档冲突时**：先与用户确认再继续。

---

## 交付格式

执行完成后输出包含以下信息的摘要：

- 目标用户名
- `/xyz/home/{user}` 状态（已创建 / 已存在）
- `/etc/fstab` 条目（是否已写入）
- `findmnt` 挂载验证结果（粘贴实际输出）
- 是否需要用户在宿主机手动执行命令
