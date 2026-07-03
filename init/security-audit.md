# 安全审计清单

## 发布前必须检查

- [ ] 仓库中不存在 `.env`、私钥、证书、token。
- [ ] 仓库中不存在真实代理节点、内网 IP、远程主机名。
- [ ] `home/` 只包含 `.gitkeep` 或示例说明，不包含真实用户文件。
- [ ] `var/` 只包含 `.gitkeep` 或示例说明，不包含数据库、缓存、日志。
- [ ] `.claude/skills`、`.codex`、个人插件和本机配置没有进入仓库。
- [ ] SDK 文档只包含公开可复用的安装记录和模板。

## 辅助命令

```bash
grep -RInE 'token|secret|password|passwd|api[_-]?key|private key|BEGIN .*PRIVATE|ssh-rsa|github_pat|ghp_' .
find . -type f \( -name '*.db' -o -name '*.sqlite' -o -name '*.pem' -o -name '*.key' -o -name '.env' \)
```

