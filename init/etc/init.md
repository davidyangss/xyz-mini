# /xyz/etc 说明

`/xyz/etc` 存放项目级配置模板、环境片段和服务配置示例。

## 子目录

- `env/linux/`：Linux 环境入口文件（`/etc/bash.bashrc` 模板及基础环境变量）。详见 [env/linux/init.md](env/linux/init.md)。
- `profile.d/bash/`：Bash 启动片段，由 `/etc/bash.bashrc` 调度加载，覆盖所有交互式 shell。详见 [profile.d/bash/init.md](profile.d/bash/init.md)。
- `opt/`：工具配置模板。
- `systemd/system/`：Linux systemd 服务示例。
- `launchd/`：macOS launchd plist 示例。

## 公开版约束

只提交模板，不提交真实密钥、代理、证书、服务地址或个人主机信息。
