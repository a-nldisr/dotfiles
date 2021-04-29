#!/bin/bash

# Macbook download and install packages

install_all() {
        # Added only known working functions here
        set_basedirs
	install_brew
	install_python3
        # Subshell
        (
                install_ansible
                install_shelltools
        )
	install_chrome
	install_firefox
	install_brave
	set_golangdirs
	install_golang	
	install_vscode
	install_sublime
	install_neovim
	install_pathogen
        install_virtualbox
        install_vagrant
        install_docker
        install_terraform
        install_azurecli
        install_keepassyc
        install_dcoscli
        install_packer
}

# This installs brew, i tried so hard to put everything in containers but on mac its gimped
install_brew() {
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

install_vscode() {
        # Could only get vscode with a redirect
        echo "Downloading vscode"
        curl --silent -L https://go.microsoft.com/fwlink/?LinkID=620882 -o ~/Downloads/vscode.zip
        echo "Download complete"
        # Place the .app file directly in the Applications folder
        echo "Placing vscode in Applications folder"
        sudo unzip ~/Downloads/vscode.zip -d /Applications/
        # Place the code command to open files with
        ln -s /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code /usr/local/bin/code
}

install_sublime() {
        echo "Downloading sublime"
        export SUBLIME_VER=203143
        curl --silent "https://download.sublimetext.com/Sublime%20Text%20Build%${SUBLIME_VER}.dmg" -o ~/Downloads/sublime.dmg
        echo "Download complete, installing sublime"
        hdiutil attach ~/Downloads/sublime.dmg
        sudo cp -Rf /Volumes/Sublime\ Text/Sublime\ Text.app /Applications
        echo "Detaching volume"
        hdiutil detach /Volumes/Sublime\ Text/
        echo "Installation complete"
}

install_keepassyc() {
        echo "Downloading KeepassXC"
        export KEEPASSXC_VER=2.2.2
        curl --silent -L https://github.com/keepassxreboot/keepassxc/releases/download/${KEEPASSXC_VER}/KeePassXC-${KEEPASSXC_VER}.dmg -o ~/Downloads/keepass.dmg
        echo "Download complete, installing sublime"
        hdiutil attach ~/Downloads/keepass.dmg
        sudo cp -Rf /Volumes/KeePassXC/KeePassXC.app /Applications
        echo "Detaching volume"
        hdiutil detach /Volumes/KeepassXC/
        echo "Installation complete"
}

install_viscosity() {
        echo "TODO, before i forget"
}

install_brave() {
        echo "Downloading Brave browser"
        curl --silent -L https://laptop-updates.brave.com/latest/osx -o ~/Downloads/brave.dmg
        echo "Download complete, installing Brave"
        hdiutil attach ~/Downloads/brave.dmg
        sudo cp -Rf /Volumes/Brave/Brave.app /Applications
        echo "Detaching volume"
        hdiutil detach /Volumes/Brave
        echo "Installation complete"
}

install_firefox() {
        echo "Downloading Firefox"
        curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US" -o ~/Downloads/firefox.dmg
        echo "Download complete, installing"
        hdiutil attach ~/Downloads/firefox.dmg
        sudo cp -Rf /Volumes/Firefox/Firefox.app /Applications
        echo "Firefox installation is complete"
        hdiutil detach /Volumes/Firefox
        echo "Cleaned up"
}

install_chrome() {
        echo "Downloading Google Chrome"
        curl --silent https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg -o ~/Downloads/googlechrome.dmg
        echo "Download complete, installing chrome"

        hdiutil attach ~/Downloads/googlechrome.dmg
        sudo cp -Rf /Volumes/Google\ Chrome/Google\ Chrome.app /Applications
        echo "Chrome installation is complete"
        hdiutil detach /Volumes/Google\ Chrome
}

install_packer() {
        export PACKER_VER=1.3.2
        echo "Downloading Packer"
        curl --silent https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_darwin_amd64.zip -o ~/Downloads/packer.zip
        sudo unzip ~/Downloads/packer.zip -d /usr/local/bin/
        sudo chmod +x /usr/local/bin/packer
}

set_basedirs() {
        mkdir ~/Git/{private,work,test}
}

set_golangdirs() {
        if [[ ! -d ~/Playground/golang ]]; then
                echo "Setting general golang Playground directory"
                mkdir -p ~/Playground/golang/{src,bin,pkg}
        fi

        if [[ ! -d ~/Workplace/golang ]]; then
                echo "Setting general golang Workplace directory"
                mkdir -p ~/Workplace/golang/{src,bin,pkg}
        fi

        if [[ ! -d ~/go/ ]]; then
                echo "Setting gopath directory up, this is the default GOPATH"
                mkdir -p ~/go/{src,bin,pkg}
        fi
}

check_golang() {
        if command -v go &>/dev/null; then
            echo "Checking requirements: Go... ok"
        else 
            echo "Installing requirements..."
            install_golang          
        fi
}

install_golang() {
	export GO_VERSION
        GO_VERSION=$(curl -sSL "https://golang.org/VERSION?m=text")
        export GO_SRC=/usr/local/go
	GO_VERSION=${GO_VERSION#go}
	echo -e "Installing ${GO_VERSION}"

        # You can pass version
	if [[ -n "$1" ]]; then
		export GO_VERSION=$2
	fi

	# Purge old GO_SRC
	if [[ -d "$GO_SRC" ]]; then
		sudo rm -rf "$GO_SRC"
	fi

	# Subshell install go
	(
        # Darwin installer requires a path
	curl --silent https://storage.googleapis.com/golang/go"${GO_VERSION}".darwin-amd64.pkg -o ~/Downloads/go"${GO_VERSION}".darwin-amd64.pkg 
        sudo /usr/sbin/installer -pkg ~/Downloads/go"${GO_VERSION}".darwin-amd64.pkg -target / -verboseR
	local user="$USER"
	# rebuild stdlib for faster builds
	sudo chown -R "${user}" /usr/local/go/pkg
	CGO_ENABLED=0 go install -a -installsuffix cgo std
	)

        # Subshell install cmdline tools
	(
	set -x
	set +e
        echo "Installing golang linter"
	go get github.com/golang/lint/golint
        echo "Installing golang language server"
        go get golang.org/x/tools/cmd/gopls
	go get golang.org/x/tools/cmd/cover
	go get golang.org/x/review/git-codereview
	go get golang.org/x/tools/cmd/goimports
	go get golang.org/x/tools/cmd/gorename
	go get golang.org/x/tools/cmd/guru
        go get github.com/derekparker/delve/cmd/dlv
        )
}

install_vagrant() {
        check_virtualbox
	export VAGRANT_VER=2.0.0
        # Subshell install Vagrant
        (
        curl --silent "https://releases.hashicorp.com/vagrant/${VAGRANT_VER}/vagrant_${VAGRANT_VER}_x86_64.dmg" -o ~/Downloads/vagrant_${VAGRANT_VER}_x86_64.dmg
        hdiutil attach ~/Downloads/vagrant_${VAGRANT_VER}_x86_64.dmg
        sudo /usr/sbin/installer -pkg /Volumes/Vagrant/vagrant.pkg -target / -verboseR -allowUntrusted
        hdiutil detach /Volumes/Vagrant/
        # Its possible that Mac OSX blocks virtual box. You then need to remove the warning from Settings > Privacy & security and allow Oracle in the general tab.
        )
}

install_virtualbox() {
        # Installation of virtualbox and extension pack
        export VIRTUALBOX_VER=5.1.26
        # Since 1 version number wasn't enough
        export VIRTUALBOX_VER2=117224 
        # Subshell install virtualbox
        (
        curl --silent "http://download.virtualbox.org/virtualbox/${VIRTUALBOX_VER}/VirtualBox-${VIRTUALBOX_VER}-${VIRTUALBOX_VER2}-OSX.dmg" -o ~/Downloads/VirtualBox-${VIRTUALBOX_VER}-${VIRTUALBOX_VER2}-OSX.dmg
        hdiutil attach ~/Downloads/VirtualBox-${VIRTUALBOX_VER}-${VIRTUALBOX_VER2}-OSX.dmg
        sudo /usr/sbin/installer -pkg /Volumes/VirtualBox/VirtualBox.pkg -target / -verboseR
        hdiutil detach /Volumes/VirtualBox/
        )

        # Installation of virtualbox extension pack
        (
        curl --silent "http://download.virtualbox.org/virtualbox/${VIRTUALBOX_VER}/Oracle_VM_VirtualBox_Extension_Pack-${VIRTUALBOX_VER}-${VIRTUALBOX_VER2}.vbox-extpack" -o ~/Downloads/Oracle_VM_VirtualBox_Extension_Pack-${VIRTUALBOX_VER}-${VIRTUALBOX_VER2}.vbox-extpack
        VBoxManage extpack install --replace ~/Downloads/Oracle_VM_VirtualBox_Extension_Pack-${VIRTUALBOX_VER}-${VIRTUALBOX_VER2}.vbox-extpack
        )
}

install_docker() {
        # Subshell install Docker
        echo "Installing Docker"
        (
        curl --silent "https://download.docker.com/mac/stable/Docker.dmg" -o ~/Downloads/Docker.dmg
        hdiutil attach ~/Downloads/Docker.dmg
        sudo cp -Rf /Volumes/Docker/Docker.app /Applications
        hdiutil detach /Volumes/Docker
        )
        echo "Installation done, you need to start Docker to do post-intall setup"
}

install_dcoscli() {
        export DCOSCLI_VER=1.8
        # Subshell install dcoscli
        (
        curl --silent "https://downloads.dcos.io/binaries/cli/darwin/x86-64/dcos-${DCOSCLI_VER}/dcos" -o /usr/local/bin/dcos
        chmod +x /usr/local/bin/dcos
        )
}

# Brew Section, introduced this since docker really messed up network, sound, passing through arguments. One day Docker will be made great again
# All brew installs have a check_brew call to ensure this doesnt fail somewhere

check_brew() {
        if command -v brew &>/dev/null; then
            echo "Checking requirements: Brew... ok"
        else 
            echo "Installing requirements..."
            install_brew           
        fi
}

check_virtualbox() {
        if command -v VirtualBox &>/dev/null; then
            echo "Checking requirements: VirtualBox... ok"
        else 
            echo "Installing requirements..."
            install_virtualbox           
        fi
}

install_delve() {
        # Delve must be installed after Go
        check_brew
        check_golang
        brew install go-delve/delve/delve
}

install_shellcheck() {
        check_brew
        brew install shellcheck
}

install_coreutils() {
	check_brew
	brew install coreutils
}

install_fzf() {
	check_brew
	brew install fzf
}

install_ncdu() {
        check_brew
        brew install ncdu
}

install_exa() {
        check_brew
        brew install exa
}

install_python3() {
        check_brew
        brew install python3
	setup_python
}

install_terraform() {
        check_brew
        brew install terraform
}

install_azurecli() {
        check_brew
        brew install azure-cli
}

install_ansible() {
        if command -v python3 &>/dev/null; then
            echo "Installing ansible"
        else
	    echo "Installing requirements..."
            install_python3
        fi
        check_brew
        brew install ansible
}

install_bashcompletion() {
	brew install bash-completion
}

set_updatedb() {
        echo "Setting symlink for updatedb"
        ln -s /usr/libexec/locate.updatedb /usr/local/bin/updatedb
        echo "Done"
}

set_locate() {
        echo "Allowing locate command"
        sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
}

install_neovim() {
	check_brew
	brew install neovim
}

install_pathogen() {
	echo "Installing vim pathogen"
	if [ ! -d ~/.vim/autoload ]; then
	  mkdir -p ~/.vim/autoload ~/.vim/bundle
	fi
	curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

	if [ ! -f ~/.vimrc ]; then
		echo "No vimrc file found, creating it"
		echo "execute pathogen#infect()" > ~/.vimrc
		echo "syntax on" >> ~/.vimrc
		echo "filetype plugin indent on" >> ~/.vimrc
	else
		echo "vimrc file found, checking for required line"
		if grep -Fxq "execute pathogen#infect()" ~/.vimrc; then
			echo "Pathogen correctly setup"
		else
			echo "Adding pathogen line in vimrc file"
	                echo "execute pathogen#infect()" >> ~/.vimrc
		fi
	fi
}

install_iterm2() {
	check_brew
	brew install homebrew/cask/iterm2
}

install_chezmoi() {
	check_brew
	brew install twpayne/taps/chezmoi
}

install_shelltools() {
        install_shellcheck
        install_exa
        set_locate
        set_updatedb
	install_iterm2
	install_fzf
	install_coreutils
}

# Setup for a python developer environment

setup_python() {
        check_brew
        # Subshell
        (
        brew install pex
        brew install tox
        brew install pants
        brew install pip
        )
}

usage() {
	echo -e "This script installs my basic setup for a Macbook\\n"
	echo "Usage:"
        echo "  all                         - Installs all working tools"
	echo "  base                        - Sets basics such as paths"
	echo "  python                      - Installs Python 3"
        echo "  ansible                     - Installs Ansible"
        echo "  browsers                    - Installs Browsers"
	echo "  golang                      - Installs Golang"
	echo "  ide                         - Installs IDEs"
        echo "  vm                          - Installs VirtualBox"
        echo "  vagrant                     - Installs Vagrant"
        echo "  terraform                   - Installs Terraform"
        echo "  docker                      - Installs Docker"
        echo "  shelltools                  - Installs shell tools"
        echo "  security                    - Installs security tools"
        echo "  dcoscli                     - Installs dcos-cli"
}

main() {
	local cmd=$1

	if [[ -z "$cmd" ]]; then
		usage
		exit 1
	fi
        if [[ $cmd == "all" ]]; then
		install_all
        elif [[ $cmd == "base" ]]; then
		set_basedirs
	elif [[ $cmd == "python" ]]; then
		install_python3
	elif [[ $cmd == "ansible" ]]; then
		install_ansible
	elif [[ $cmd == "browser" ]]; then
		install_chrome
		install_firefox
		install_brave
        elif [[ $cmd == "golang" ]]; then
		set_golangdirs
		install_golang
	elif [[ $cmd == "ide" ]]; then
		install_vscode
		install_sublime
	elif [[ $cmd == "vim" ]]; then
		install_neovim
		install_pathogen
	elif [[ $cmd == "vm" ]]; then
                install_virtualbox
	elif [[ $cmd == "vagrant" ]]; then
                install_vagrant
	elif [[ $cmd == "docker" ]]; then
                install_docker
        elif [[ $cmd == "terraform" ]]; then
                install_terraform
        elif [[ $cmd == "packer" ]]; then
                install_packer
        elif [[ $cmd == "azure" ]]; then
                install_azurecli
        elif [[ $cmd == "dcoscli" ]]; then
                install_dcoscli
	elif [[ $cmd == "shelltools" ]]; then
                install_shellcheck
                install_exa
                set_locate
                set_updatedb
		install_iterm2
		install_fzf
		install_coreutils
		install_chezmoi
	elif [[ $cmd == "security" ]]; then
		install_keepassyc
	else
		usage
	fi
}

main "$@"