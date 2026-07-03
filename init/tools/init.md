# /xyz/tools 说明

`/xyz/tools` 用于集中管理自建工具和辅助脚本。

公开版不包含私有自动化脚本。新增脚本时应说明用途、输入输出、依赖和安全边界。

## tools/backup/

### tar-xyz.sh

**用途**：对整个 `/xyz`（或 `$XYZ_ROOT`）目录进行全量 tar 备份，输出至当前工作目录。

**运行方式**：

```bash
bash /xyz/tools/backup/tar-xyz.sh
```

**输出文件**：
- `xyz-{os_label}-{timestamp}.tar` — tar 归档文件
- `xyz-{os_label}-{timestamp}.errlog` — 备份过程的 stderr 日志

**排除项**（不进入 tar）：`.git`、`target`、`build`、`out`、`node_modules`、`vendor`、`.DS_Store`、`.TemporaryItems`、已有的 `xyz-*.tar` 和 `xyz-*.errlog`

**依赖**：`bash`、`sudo`、`find`、`tar`、`/etc/os-release`（Linux）

**安全边界**：仅读取文件系统，不上传、不删除数据。需要 sudo 读取受限目录。

