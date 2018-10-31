#!/bin/bash

main() {
	check_requirements
	install_polyglot
}

check_requirements() {
	if [ ! -f ~/.vimrc ]; then
		echo "Please use \"install_darwin.sh vim\" first"
		exit 1
	fi
	echo "vimrc file is present, checking if git is present"
	if whereis git; then
		echo "Git present"
	else
		echo "Git not present, please install git through the install_darwin.sh script"
		exit 1
	fi
	if [ ! -d ~/.vim/bundle ]; then
		mkdir -p ~/.vim/bundle
	fi
}

install_polyglot() {
	if [ ! -d ~/.vim/bundle/vim-polyglot ]; then
		echo "Installing Polyglot"
		cd ~/.vim/bundle && \
		git clone https://github.com/sheerun/vim-polyglot
	fi
}

main

