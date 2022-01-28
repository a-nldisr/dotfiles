#!/bin/bash

# Bash Aliases
alias pull="git pull"
alias push="git push"
alias k="kubectl"

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