# Rust 安装说明

## 基本信息

- 用途：Rust 编译器、Cargo 包管理器和 rustup 版本管理。
- 推荐安装方式：官方 rustup 脚本（Linux / macOS 统一推荐）。
- 当前版本：rustc 1.96.1，cargo 1.96.1，rustup 1.29.0

## Linux / macOS

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

> 直接执行会进入交互式安装。若要无交互安装：`curl ... | sh -s -- -y`

## 安装路径

- rustup 二进制：`$HOME/.cargo/bin/rustup`
- Rustup home：`$HOME/.rustup`
- Cargo home：`$HOME/.cargo`
- 工具链：`$HOME/.rustup/toolchains/`

## 环境配置

脚本位置：[../../../etc/profile.d/bash/rust.sh](../../../etc/profile.d/bash/rust.sh)

```bash
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
```

## 常用命令

```bash
rustup update              # 升级工具链
rustup toolchain list      # 查看已安装工具链
rustup default stable      # 设置默认工具链
rustc --version
cargo --version
```

## 升级步骤

```bash
rustup update
```

## 注意事项

- 不建议用 apt 的 `rustup` 包（版本滞后且与 `rustc`/`cargo` 包冲突），统一使用官方脚本。
- 若安装需要代理，临时设置 `https_proxy`/`http_proxy` 环境变量，不记录到仓库。
- 官方 rustup 需要 `cc`（C 编译器）来编译部分 crate，可通过 `sudo apt install build-essential` 安装。
