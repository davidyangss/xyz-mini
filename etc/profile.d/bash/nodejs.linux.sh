# Node.js on Linux, managed by n.

export N_PREFIX="${XYZ_ROOT:-/xyz}/opt/linux/sdk/node"
path_prepend_or_replace "$N_PREFIX/bin"
export npm_config_cache="${XYZ_ROOT:-/xyz}/var/npm-cache"

