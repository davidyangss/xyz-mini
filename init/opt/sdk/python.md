# Python 安装说明

## 基本信息

- 用途：Python 运行时和脚本环境。
- macOS 推荐安装方式：`brew install python`。
- Linux 推荐安装方式：`apt install python3 python3-venv python3-pip`。
- 当前版本：按本机实际填写。

## macOS

```bash
brew install python
python3 --version
pip3 --version
```

## Linux

```bash
sudo apt update
sudo apt install python3 python3-venv python3-pip
python3 --version
```

## 虚拟环境

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

## 环境配置

公开版不强制重定向 Python 全局路径。建议项目级依赖使用 venv。

脚本位置：[../../../etc/profile.d/bash/python.sh](../../../etc/profile.d/bash/python.sh)

## 注意事项

- 不建议在系统 Python 中全局安装项目依赖。
- Linux 发行版可能启用 externally-managed environment，应优先使用 venv。

