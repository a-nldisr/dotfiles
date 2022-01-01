#!/bin/bash

# Make history usefull
HISTFILESIZE=10000000
export HISTFILESIZE=10000000
HISTSIZE=10000000
export HISTSIZE=10000000

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
HISTTIMEFORMAT="%d/%m/%y %T "
export HISTTIMEFORMAT="%d/%m/%y %T "

# Python override
alias python="python3"

# This is enabled to source bashrc on mac, else its ignored
# shellcheck source=/dev/null
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

# Enables Bash completion
if [ -f "$(brew --prefix)"/etc/bash_completion ]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix)/etc/bash_completion"
fi
# shellcheck source=/dev/null
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

if [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  # shellcheck source=/dev/null
  . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi