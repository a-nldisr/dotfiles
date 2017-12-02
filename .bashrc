#!/bin/bash

# Check environment
source ~/.checks

for file in ~/.{path,dockerrc_${platform},}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
done
unset file
