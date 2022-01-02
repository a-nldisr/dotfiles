#!/bin/bash

# Check environment
# shellcheck source=/dev/null
source ~/.checks

# Silence OSX zsh message:
export BASH_SILENCE_DEPRECATION_WARNING=1

# Source the files generated
for file in ~/.{path,dockerrc_${PLATFORM:?},employer}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		# shellcheck source=/dev/null
		source "$file"
	fi
done
unset file

# This is to enable Azure cli interactive without UTF-8 errors more info in azure-cli issues 4536
if [[ $(echo "$BASH_VERSION" | cut -d. -f1) -lt 4 ]]; then
  export LC_CTYPE=en
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

if [[ "$PLATFORM" == 'darwin' ]]; then
  if [[ "$PROCESSOR" == 'i386' ]]; then
    export GOOS="darwin"
    export GOARCH="amd64"
  elif [[ "$PROCESSOR" == 'arm' ]]; then
    export GOOS="darwin"
    export GOARCH="amd64"
  fi
elif [[ "$PLATFORM" == 'linux' ]]; then
  export GOOS="linux"
  export GOARCH="amd64"
fi

# This is set for packer builds
if [[ -f ~/.employer_files/.ansible_vault.txt ]]; then
  export VAULT_PASSWORD=~/.employer_files/.ansible_vault.txt
  else
  logger "No ansible vault password found"
fi

# Setting editor
export VISUAL=nvim
export EDITOR="$VISUAL"
LOCAL_IP="$(ipconfig getifaddr en0)"
export LOCAL_IP

export PATH=$PATH:$HOME/Library/Python/3.7/bin:/usr/local/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/rogierdikkes/Library/Python/3.6/bin:/usr/local/go/bin:/Users/rogierdikkes/go/bin:/usr/share/bcc/tools:/sbin:/usr/X11R6/bin/

# Adding Brew to path
eval "$(/opt/homebrew/bin/brew shellenv)"
source <(kubectl completion bash)

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

eval "$(thefuck --alias)"

# Print a message when opening a terminal
welcome() {
  uptime
  df -l -H | head -n2
  # shellcheck disable=SC1117
  echo -e "The IP is: \033[91;7m$LOCAL_IP\033[0m, directory: \033[91;7m$PWD\033[0m"
}

welcome
source ~/.bash_aliases