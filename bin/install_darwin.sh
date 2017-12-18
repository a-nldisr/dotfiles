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
                install_shellcheck
                install_exa
        )
	install_chrome
	install_firefox
	install_brave
	set_golangdirs
	install_golang	
	install_vscode
	install_sublime
	install_neovim
        install_virtualbox
        install_vagrant
        install_docker
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

set_basedirs() {
        mkdir ~/Git
        mkdir ~/go
        mkdir ~/Playground
        mkdir ~/Workplace
}

set_golangdirs() {
        echo "Setting general golang Playground directory"
        mkdir ~/Playground/golang
        mkdir ~/Playground/golang/src
        mkdir ~/Playground/golang/bin
        mkdir ~/Playground/golang/pkg

        echo "Setting general golang Workplace directory"
        mkdir ~/Workplace/golang
        mkdir ~/Workplace/golang/src
        mkdir ~/Workplace/golang/bin
        mkdir ~/Workplace/golang/pkg

        echo "Setting gopath directory up, this is the default GOPATH"
        mkdir ~/go/src
        mkdir ~/go/bin
        mkdir ~/go/pkg
}

install_golang() {
        export GO_VERSION=1.9
        export GO_SRC=/usr/local/go

        # Passing version
	if [[ ! -z "$1" ]]; then
		export GO_VERSION=$1
	fi

	# Purge old GO_SRC
	if [[ -d "$GO_SRC" ]]; then
		sudo rm -rf "$GO_SRC"
	fi

	# Subshell install go
	(
        # Darwin installer requires a path, thus we do not pipe this yet
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
	go get github.com/golang/lint/golint
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
        sudo /usr/sbin/installer -pkg /Volumes/Vagrant/vagrant.pkg -target / -verboseR
        hdiutil detach /Volumes/Vagrant/
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
        (
        curl --silent "https://download.docker.com/mac/stable/Docker.dmg" -o ~/Downloads/Docker.dmg
        hdiutil attach ~/Downloads/Docker.dmg
        sudo /usr/sbin/installer -pkg /Volumes/Docker/Docker.pkg -target / -verboseR
        hdiutil detach /Volumes/Docker
        )
}

# Brew Section, introduced this since docker really messed up network, sound, passing through arguments. One day Docker will be made great again

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

install_shellcheck() {
        check_brew
        brew install shellcheck
}

install_exa() {
        check_brew
        brew install exa
}

install_python3() {
        check_brew
        brew install python3
	install_pip
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

install_pip() {
        check_brew
        brew install pip
}

install_neovim() {
	check_brew
	brew install neovim
}

usage() {
	echo -e "This script installs my basic setup for a Macbook\n"
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
        echo "  docker                      - Installs Docker"
        echo "  shelltools                  - Installs shell tools"
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
	elif [[ $cmd == "ide"  ]]; then
		install_vscode
		install_sublime
		install_neovim
	elif [[ $cmd == "vm"  ]]; then
                install_virtualbox
	elif [[ $cmd == "vagrant"  ]]; then
                install_vagrant
	elif [[ $cmd == "docker"  ]]; then
                install_docker
	elif [[ $cmd == "shelltools"  ]]; then
                install_shellcheck
                install_exa
	else
		usage
	fi
}

main "$@"
