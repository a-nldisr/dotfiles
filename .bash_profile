#!/bin/bash

# This is enabled to source bashrc on mac, else its ignored
# shellcheck source=/dev/null
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi 

# Enables Bash completion
if [ -f "$(brew --prefix)"/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Make history usefull
HISTFILESIZE=10000000
HISTSIZE=10000000

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
HISTTIMEFORMAT="%d/%m/%y %T "