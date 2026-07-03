# /xyz/opt/sdk 说明

本目录记录 SDK 和开发工具链的安装方式、版本、环境变量、缓存路径和升级步骤。

## 公开版范围

只包含：

- [go.md](go.md)
- [rust.md](rust.md)
- [java/init.md](java/init.md)
- [python.md](python.md)
- [node.md](node.md)

其他工具应在私有仓库中维护，或作为独立示例按需添加。

## 记录要求

- macOS 和 Linux 分开记录。
- 写明安装来源：brew、apt、官方安装器或手动安装。
- 若有环境脚本，链接到 `/xyz/etc/profile.d/bash/`。
- 若有缓存目录，说明是否重定向到 `/xyz/var/`。
- 不写真实代理节点、内网地址或个人主机名。

