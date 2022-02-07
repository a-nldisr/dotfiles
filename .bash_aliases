#!/bin/bash
# Bash Aliases

# Git
alias pull="git pull"
alias push="git push"

# Kubernetes
alias k="kubectl"

# pip
alias pip="pip3"

EMPLOYER_ALIAS_FILE="$HOME/.employer_files/.bash_aliases"
export EMPLOYER_ALIAS_FILE
if [ -f "$EMPLOYER_ALIAS_FILE" ];then
	# Since this file is outside the repo we use the /dev/null directive to prevent errors
	# shellcheck source=/dev/null
	source "$EMPLOYER_ALIAS_FILE"
else
	mkdir -p "$HOME/.employer_files"
	touch "$EMPLOYER_ALIAS_FILE"
fi