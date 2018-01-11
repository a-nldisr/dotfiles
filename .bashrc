#!/bin/bash

# Check environment
# shellcheck source=/dev/null
source ~/.checks

for file in ~/.{path,dockerrc_${platform:?},employer}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
done
unset file

# This is to enable Azure cli interactive without UTF-8 errors more info in azure-cli issues 4536
export LC_CTYPE=en

alias gitdir="cd ~/Git"
