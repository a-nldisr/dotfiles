#!/bin/bash

# This is enabled to source bashrc on mac, else its ignored
# shellcheck source=/dev/null
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi 

# Enables Bash completion
if [ -f "$(brew --prefix)"/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi