#!/bin/bash -x

set -euo pipefail

# bash /xyz/tools/backup/tar-xyz.sh

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

run_time=$(date "+%Y%m%d%H%M%S")
os_id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
os_version_id=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
os_version_codename=$(grep '^VERSION_CODENAME=' /etc/os-release | cut -d= -f2 | tr -d '"' || echo '')
os_label="${os_id}-${os_version_id}${os_version_codename:+-${os_version_codename}}"

xyz_tar="$(pwd)/xyz-${os_label}-${run_time}.tar"
xyz_tar_err="$(pwd)/xyz-${os_label}-${run_time}.errlog"
xyz_dir=$(realpath "${XYZ_ROOT:-/xyz}")

die () {
   echo "❌ $@"
   exit 1
}

full-backup () {
   set -euo pipefail
   cd "$xyz_dir"

   echo "✅ 🔍 Find $xyz_dir, tar to $xyz_tar ..."

   # ====================================================================
   # 💡 提示未来的自己：
   #    以下 -path / -name 匹配到的路径/文件会被 prune 排除在备份之外。
   #    如果需要剔除更多目录或文件（例如缓存、编译产物、大型数据目录），
   #    按现有格式在下方追加 -o -path "..." 或 -o -name "..." 即可。
   # ====================================================================
   sudo find . \
         \( \
            -path "./.git" \
            -o -name 'target' \
            -o -name 'build' \
            -o -name 'out' \
            -o -name 'node_modules' \
            -o -name 'vendor' \
            -o -name '.DS_Store' \
            -o -name '.TemporaryItems' \
            -o -type f -name 'xyz-*.tar' \
            -o -type f -name 'xyz-*.errlog' \
      \) -prune \
         -o \( -type f -o -type l \) -print0 \
      | sudo tar --ignore-failed-read --null -cvf "$xyz_tar" --files-from=- 2>"$xyz_tar_err" \
   && echo "✅ Created: $xyz_tar" \
   || die "Failed: $xyz_tar"
}

# 无参数时，执行全量备份
if [ $# -eq 0 ]; then
   full-backup && echo "✅ Done: $xyz_tar"
else
   for arg in "$@"; do
      $arg && echo "✅ Done: $arg"
   done
fi
