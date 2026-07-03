# Shared shell helpers for xyz environment.

function path-show() {
    echo $PATH | tr ':' '\n'
}

function user-home() {
    if [ "$XYZ_OS" = "macOS" ]; then
        echo "$XYZ_ROOT/users/$USER"
    else
        echo "$XYZ_ROOT/home/$USER"
    fi
}

warn_if_env_set() {
    local env_name="$1"
    local env_var="$2"

    local env_file="/etc/environment"
    local existing_value=""
    if [ -f "$env_file" ]; then
        existing_value="$(
            awk -F= -v key="$env_name" '
                /^[[:space:]]*#/ { next }
                index($0, "=") == 0 { next }
                {
                    name = $1
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
                    if (name != key) {
                        next
                    }

                    value = substr($0, index($0, "=") + 1)
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
                    found = 1
                }
                END {
                    if (found) {
                        print value
                    }
                }
            ' "$env_file"
        )"

        if [[ "$existing_value" == \"*\" && "$existing_value" == *\" ]]; then
            existing_value="${existing_value:1:-1}"
        elif [[ "$existing_value" == \'*\' && "$existing_value" == *\' ]]; then
            existing_value="${existing_value:1:-1}"
        fi

        if [ -n "$existing_value" ] && [ "$existing_value" != "$env_var" ]; then
            echo "Warn: $env_name=$existing_value 存在于 $env_file 中，与新值 $env_var 冲突，请手动决策 $env_file 中的变量值" >&2
            echo "Will: ${env_name}=${env_var}" >&2
        fi
    fi

    export "${env_name}=${env_var}"
}

write_environment_file() {
    local env_file="$1"
    local input_file=""
    local merged_file=""

    input_file="$(mktemp)" || return 1
    merged_file="$(mktemp)" || {
        rm -f "$input_file"
        return 1
    }

    cat > "$input_file"
    if [ -f "$env_file" ]; then
        sudo cat "$env_file" > "$merged_file" || {
            rm -f "$input_file" "$merged_file"
            return 1
        }
    fi

    awk '
        FNR == NR {
            if ($0 == "" || index($0, "=") == 0) {
                next
            }

            key = $0
            sub(/=.*/, "", key)
            vars[key] = $0
            order[++count] = key
            next
        }

        /^[[:space:]]*#/ || index($0, "=") == 0 {
            print
            next
        }

        {
            key = $0
            sub(/=.*/, "", key)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)

            if (key in vars) {
                if (!(key in written)) {
                    print vars[key]
                    written[key] = 1
                }
                next
            }

            print
        }

        END {
            for (i = 1; i <= count; i++) {
                key = order[i]
                if (!(key in written)) {
                    print vars[key]
                }
            }
        }
    ' "$input_file" "$merged_file" | sudo tee "$env_file" > /dev/null || {
        rm -f "$input_file" "$merged_file"
        return 1
    }

    rm -f "$input_file" "$merged_file"
}

path_prepend_or_replace() {
    local old_path="$1"
    if [ -z "$old_path" ]; then
        echo "required path" >&2
        return 1
    fi

    local new_path="${2}"
    if [ "$#" -ne 2 ]; then
        new_path="$old_path"
    fi

    # 1. 在首尾添加冒号，方便统一匹配格式
    # 2. 将 ":旧路径:" 替换为 ":新路径:"
    # 3. 去除首尾多余的冒号
    PATH=":$PATH:" \
        && PATH="${PATH//:$old_path:/:}" \
        && PATH="${PATH#:}" \
        && PATH="${PATH%:}"
    [ -n "$new_path" ] && PATH="${new_path}:${PATH}"
    PATH="${PATH//::/:}"

    export PATH
}

