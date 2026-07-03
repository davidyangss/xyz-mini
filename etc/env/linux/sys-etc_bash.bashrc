# System-wide .bashrc file for interactive bash(1) shells.
# Template: copy this content to /etc/bash.bashrc or soft-link via:
#   ln -sf /etc/bash.bashrc /xyz/etc/env/linux/sys-etc_bash.bashrc

# If not running interactively, don't do anything
[ -z "${PS1-}" ] && return

# check the window size after each command
shopt -s checkwinsize

# set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(< /etc/debian_chroot)
fi

if ! [ -n "${SUDO_USER-}" -a -n "${SUDO_PS1-}" ]; then
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found ] || [ -x /usr/share/command-not-found/command-not-found ]; then
	function command_not_found_handle {
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
		   /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
		else
		   printf "%s: command not found\n" "$1" >&2
		   return 127
		fi
	}
fi

# XYZ custom profile scripts
if [ -d /xyz/etc/profile.d/bash ]; then
  # 1. Load lib first (provides warn_if_env_set, write_environment_file, etc.)
  [ -r /xyz/etc/profile.d/bash/0000-lib.sh ] && . /xyz/etc/profile.d/bash/0000-lib.sh

  # 2. Load base environment variables (XYZ_ROOT, XYZ_HOME_ROOT, XYZ_OS)
  [ -r /xyz/etc/env/linux/environment.sh ] && . /xyz/etc/env/linux/environment.sh

  # 3. Load common profile scripts (exclude lib and platform-specific *.*.sh)
  while IFS= read -r i; do
    case "$i" in
      */0000-lib.sh) continue ;;
      */*.*.*.sh) continue ;;
    esac

    if [ -r "$i" ]; then
      . "$i"
    fi

    p="${i%.sh}.${XYZ_OS}.sh"
    if [ -r "$p" ]; then
      . "$p"
    fi
  done < <(find /xyz/etc/profile.d/bash -name "*.sh" 2>/dev/null | sort)
  unset i
  unset p
fi
