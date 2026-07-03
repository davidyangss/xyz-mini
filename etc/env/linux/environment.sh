warn_if_env_set XYZ_ROOT /xyz
warn_if_env_set XYZ_HOME_ROOT /xyz/home
warn_if_env_set XYZ_OS linux

xyzenv-store-path() {
	write_environment_file /etc/environment <<EOF
XYZ_ROOT=$XYZ_ROOT
XYZ_HOME_ROOT=$XYZ_HOME_ROOT
XYZ_OS=$XYZ_OS
EOF
}
