# Go on Linux.

export GOROOT="${XYZ_ROOT:-/xyz}/opt/linux/sdk/go"
export GOPATH="${XYZ_ROOT:-/xyz}/var/go"
path_prepend_or_replace "$GOROOT/bin"
path_prepend_or_replace "$GOPATH/bin"

