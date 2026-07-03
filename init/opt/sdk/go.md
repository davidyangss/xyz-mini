# Go 安装说明

## 基本信息

- 用途：Go 语言工具链。
- macOS 安装方式：`brew install go`。
- **Linux 安装方式（强制）**：禁止使用 `apt install golang-go`，必须采用手动解压方式，安装到 `/xyz/opt/linux/sdk/go`。
- 当前版本：go1.23.9（2025-05-01）

> 本规则遵循 [AGENTS.md](../../../AGENTS.md) 中的安装优先级约定：Linux 下 Go 强制使用方式 🥉（手动解压）。

## macOS

```bash
brew install go
go version
```

brew 会处理 PATH，通常不需要额外设置 `GOROOT`。

## Linux

```bash
mkdir -p /xyz/opt/linux/sdk /xyz/var/go

# 下载 tarball（如需代理：export https_proxy=http://127.0.0.1:7897）
curl -fsSL https://go.dev/dl/go1.23.9.linux-amd64.tar.gz -o /tmp/go.tar.gz

# 解压到 SDK 目录
sudo rm -rf /xyz/opt/linux/sdk/go
sudo tar -C /xyz/opt/linux/sdk -xzf /tmp/go.tar.gz
```

## 环境配置

脚本位置：[../../../etc/profile.d/bash/go.linux.sh](../../../etc/profile.d/bash/go.linux.sh)

```bash
export GOROOT="${XYZ_ROOT:-/xyz}/opt/linux/sdk/go"
export GOPATH="${XYZ_ROOT:-/xyz}/var/go"
path_prepend_or_replace "$GOROOT/bin"
path_prepend_or_replace "$GOPATH/bin"
```

当前 shell 快速生效：

```bash
source /xyz/etc/profile.d/bash/go.linux.sh
```

## 验证

```bash
go version
go env GOROOT
go env GOPATH
```

## 升级

1. 从 https://go.dev/dl/ 查询最新版本。
2. 重复「Linux」安装步骤，替换版本号。
3. 更新本文档中的版本号。

## 注意事项

- 本机同时存在旧版系统 Go（`/usr/local/go/bin/go`），部署时确保 PATH 中 `/xyz/opt/linux/sdk/go/bin` 优先。
- Go 模块缓存默认在 `$GOPATH/pkg/mod`。
- 如需模块代理，使用 `go env -w GOPROXY=<proxy>,direct`，不要把私有代理写入公开仓库。
