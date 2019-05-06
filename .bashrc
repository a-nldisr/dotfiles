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
#export PYTHONPATH=/usr/local/lib/python2.7/site-packages
export GOOS="darwin"
export GOARCH="amd64"
# This is set for packer builds
VAULT_PASSWORD="$(cat ~/.employer_files/.ansible_vault.txt)"
export VAULT_PASSWORD
# Setting editor
export VISUAL=nvim
export EDITOR="$VISUAL"

export PATH=$HOME/Library/Python/3.7/bin:/usr/local/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/rogierdikkes/Library/Python/3.6/bin:/usr/local/go/bin:/Users/rogierdikkes/go/bin:/usr/share/bcc/tools:/sbin

alias privategit="cd ~/Git/private/"
alias gitdir="cd ~/Git"
alias bcard="cd ~/go/src/bitbucket.org/a-nldisr/bcard"
alias vim="nvim"

# Functions go here
gbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout "$(echo "$branch" | awk '{print $1}' | sed "s/.* //")"
}
