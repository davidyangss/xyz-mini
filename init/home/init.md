# /xyz/home 说明

`/xyz/home` 用来记录用户目录和 `$HOME` 相关约定。

## 公开版约束

- 不提交真实用户文件。
- 不提交 shell history、SSH 配置、Git 凭据、浏览器或应用数据。
- 示例统一使用 `/xyz/home/<user>`。

## 设计说明

把用户环境纳入 `/xyz` 的收益是备份边界清晰、迁移逻辑统一、AI 操作上下文集中。

代价是会改变系统默认 `$HOME` 预期，可能影响桌面环境、systemd user service、SSH、GPG、GUI 应用和第三方工具。教学时应明确这是高侵入设计。

