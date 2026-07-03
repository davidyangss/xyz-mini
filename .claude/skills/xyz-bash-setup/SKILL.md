---
name: "xyz-bash-setup"
description: "为 xyz-mini 工作区配置 Bash 启动链：/etc/bash.bashrc，覆盖所有交互式 shell 场景（登录 + 非登录）。"
---

# xyz-bash-setup

为 Linux 系统配置 Bash 启动链，确保**交互式登录 shell** 和**交互式非登录 shell** 都能加载 xyz profile。

Ubuntu 的登录 shell 默认会经过 `~/.profile` → `~/.bashrc` → `/etc/bash.bashrc` 链，因此只需在 `/etc/bash.bashrc` 中追加一个 XYZ 加载块即可覆盖所有交互式 shell 场景，无需额外的 `/etc/profile.d/xyz.sh` 入口。

## 何时使用

- 新机器初始化，bash 启动链尚未接入 xyz profile
- 重装系统或迁移到新 Linux 主机后
- 需要验证当前配置是否符合 xyz 约定

## 先读文档（必读）

- `init/etc/profile.d/bash/init.md` — 加载逻辑、顺序依赖、平台差异和脚本索引
- `etc/env/linux/environment.sh` — 基础环境变量定义模板

## 前置假设

- 工作区根目录：`/xyz`（Linux 标准路径）
- 操作需要 sudo 权限
- `/xyz/etc/profile.d/bash/` 目录已存在并有可用脚本

---

## 标准流程

### 1. 检查现状

```bash
# 检查 bash.bashrc
grep -n "XYZ custom profile" /etc/bash.bashrc && echo "BASHBC_CONFIGURED" || echo "BASHBC_NOT_CONFIGURED"

# 确认工作区文件完整
ls -la /xyz/etc/profile.d/bash/
ls -la /xyz/etc/env/linux/environment.sh
```

- 已配置 → 跳到步骤 6 验证
- 未配置 → 继续步骤 2

### 2. 备份现有文件

```bash
# 备份 bash.bashrc（仅在需要修改时）
sudo cp /etc/bash.bashrc /etc/bash.bashrc.backup.$(date +%Y%m%d)
ls -lh /etc/bash.bashrc*
```

### 3. 配置 /etc/bash.bashrc（所有交互式 shell 的统一入口）

追加以下加载块到 `/etc/bash.bashrc` 末尾：

```bash
sudo tee -a /etc/bash.bashrc > /dev/null <<'EOF'

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
EOF
```

### 4. 注释 ~/.bash_profile / ~/.profile 中的重叠配置

`xyz-bash.sh` 管理的 PATH、PS1、别名、dircolors 等配置可能在用户的 `~/.bash_profile` 或 `~/.profile` 中已有定义。为避免冲突和重复加载，需将重叠部分注释掉。

```bash
for rc in "$HOME/.bash_profile" "$HOME/.profile"; do
  [ -f "$rc" ] || continue
  [ -r "$rc" ] || continue

  # 备份
  cp "$rc" "$rc.xyz-backup.$(date +%Y%m%d)"

  # 注释重叠的配置块和单行配置
  awk '
    # 块：~/.local/bin 或 ~/bin 的 PATH if 块
    /^\s*if\s+\[.*\$HOME\/(\.local\/)?bin\s*\]/ {
      in_block = 1
      print "# [xyz-bash disabled by xyz-profile] " $0
      next
    }
    in_block {
      print "# [xyz-bash disabled by xyz-profile] " $0
      if (/^\s*fi\s*$/) in_block = 0
      next
    }

    # 块：dircolors if 块
    /^\s*if\s+\[.*dircolors/ {
      in_dc = 1
      print "# [xyz-bash disabled by xyz-profile] " $0
      next
    }
    in_dc {
      print "# [xyz-bash disabled by xyz-profile] " $0
      if (/^\s*fi\s*$/) in_dc = 0
      next
    }

    # 单行：color_prompt / force_color_prompt / PS1
    /color_prompt|force_color_prompt/ { print "# [xyz-bash disabled by xyz-profile] " $0; next }
    /^PS1=/ { print "# [xyz-bash disabled by xyz-profile] " $0; next }

    # 单行：alias ls/grep 带 --color
    /alias (ls|grep|fgrep|egrep)=.*--color/ { print "# [xyz-bash disabled by xyz-profile] " $0; next }

    # 单行：常用别名 ll, la, l, alert
    /^alias (ll|la|l|alert)=/ { print "# [xyz-bash disabled by xyz-profile] " $0; next }

    { print }
  ' "$rc" > "$rc.tmp" && mv "$rc.tmp" "$rc"
done
```

> **注意**：此脚本覆盖常见重叠模式（PATH 块、dircolors 块、PS1、color_prompt、彩色别名、常用别名）。若 profile 中包含自定义复杂结构（如 `case` 语句内的 PS1 设置），请手动检查。

```bash
# 查看被注释的内容
grep "xyz-bash disabled" ~/.bash_profile ~/.profile 2>/dev/null || echo "无重叠配置"
```

### 5. 写入 /etc/environment（非交互式 shell 静态变量）

```bash
sudo bash -c '. /xyz/etc/profile.d/bash/0000-lib.sh && . /xyz/etc/env/linux/environment.sh && xyzenv-store-path'
```

### 6. 验证结果

**语法检查**：

```bash
bash -n /etc/bash.bashrc && echo "bash.bashrc 语法通过"
```

**交互式非登录 shell 测试**：

```bash
bash -ic 'echo "XYZ_ROOT=$XYZ_ROOT, XYZ_OS=$XYZ_OS"'
# 期望：XYZ_ROOT=/xyz, XYZ_OS=linux
```

**登录 shell 测试**：

```bash
bash -lc 'echo "XYZ_ROOT=$XYZ_ROOT, XYZ_OS=$XYZ_OS"'
# 期望：XYZ_ROOT=/xyz, XYZ_OS=linux
```

---

## 回滚方法

```bash
# 恢复 bash.bashrc
sudo cp /etc/bash.bashrc.backup.YYYYMMDD /etc/bash.bashrc

# 恢复用户 profile 文件
cp ~/.bash_profile.xyz-backup.YYYYMMDD ~/.bash_profile 2>/dev/null || true
cp ~/.profile.xyz-backup.YYYYMMDD ~/.profile 2>/dev/null || true

# 验证回滚
grep "XYZ custom profile" /etc/bash.bashrc    # 应无输出
grep "xyz-bash disabled" ~/.bash_profile ~/.profile 2>/dev/null || echo "用户 profile 已恢复"
```

---

## 注意事项

- **加载顺序有依赖**：`0000-lib.sh` 必须先于 `environment.sh`，`environment.sh` 必须先于其他脚本。
- **非交互式 shell**：不加载 bash.bashrc，仅能通过 `/etc/environment` 获取静态变量（`XYZ_ROOT` 等）。
- **macOS 不适用**：macOS 使用 Zsh，入口为 `/etc/zshenv`，本 skill 仅适用 Linux。
- **幂等性**：执行前检查是否已配置，不可重复追加。
- **不写入私密信息**：bash.bashrc 是全局可读文件，不硬编码 token、密码。
