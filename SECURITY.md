# Security Policy

## 永远不要提交

- 私钥、证书、token、cookie、session、API key。
- `.env`、真实 `config.toml`、真实代理配置、真实 SSH 配置。
- shell history、浏览器配置、云盘挂载内容。
- 数据库文件、日志文件、缓存目录。
- 真实用户名、内网地址、远程主机名、公司或家庭网络信息。

## 发布前检查

```bash
grep -RInE 'token|secret|password|passwd|api[_-]?key|private key|BEGIN .*PRIVATE|ssh-rsa|github_pat|ghp_' .
find . -type f \( -name '*.db' -o -name '*.sqlite' -o -name '*.pem' -o -name '*.key' -o -name '.env' \)
```

检查命令只能作为辅助，不能替代人工审阅。

