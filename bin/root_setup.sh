#!/bin/bash

# This script needs to run as root

set -e

check_sudo() {
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root."
		exit
	fi
}

check_sudo_user() {
    # This assumes SUDO_USER is set, which is default on mac. Else we assume there is only 1 user on this system. Its not perfect.
    if [ "$SUDO_USER" ]; then 
        USERNAME=$SUDO_USER
    else 
        USERNAME=$(find /Users/* -maxdepth 0 -printf "%f" -type d || echo "$USER")
    fi
}

setup_sudoers() {
    # I know what im doing, but when i don't lock my pc that one time in history... Please kick the shit out of me.
    { \
		echo -e 'Defaults	secure_path="/usr/local/go/bin:/Users/'${USERNAME}'/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'; \
		echo -e 'Defaults	env_keep += "ftp_proxy http_proxy https_proxy no_proxy GOPATH EDITOR"'; \
		echo -e "${USERNAME} ALL=(ALL) NOPASSWD:ALL"; \
		echo -e "${USERNAME} ALL=NOPASSWD: /usr/sbin/installer"; \
	} >> /etc/sudoers
}

main() {
    check_sudo
    check_sudo_user
    setup_sudoers
}

main