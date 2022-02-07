#!/bin/bash

# Macbook download and install packages

install_all() {
        setup_requirements
        # Added only known working functions here
        set_basedirs
	install_brew
	install_python3
        # Subshell
        (
                install_shelltools
                install_devtools
        )
	install_browsers
	set_golangdirs
	install_golang
	install_vscode
	install_sublime
	install_pathogen
        install_automation
        install_azurecli
        install_keepassyc
        install_packer
        install_kubernetes
        message_finish
}

# This installs brew, i tried so hard to put everything in containers but on mac its gimped
install_brew() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    	eval "$(/opt/homebrew/bin/brew shellenv)"
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
        sudo ln -s /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code /usr/local/bin/code
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
        brew install --cask keepassxc
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
        export PACKER_VER=1.7.8
        echo "Downloading Packer"
        curl --silent https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_darwin_amd64.zip -o ~/Downloads/packer.zip
        sudo unzip ~/Downloads/packer.zip -d /usr/local/bin/
        sudo chmod +x /usr/local/bin/packer
}

set_basedirs() {
        mkdir ~/Git/{private,work,test,0to1}
        mkdir ~/Documents/{work,test,0to1}
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
        setup_requirements
	export GO_VERSION
        # Get the latest version
        GO_VERSION=$(curl -sSL "https://golang.org/VERSION?m=text")
        export GO_SRC=/usr/local/go
	GO_VERSION=${GO_VERSION#go}
	echo -e "Installing ${GO_VERSION}"
        echo -e "For ${PLATFORM} and ${PROCESSOR}"

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
	curl --silent https://dl.google.com/go/go"${GO_VERSION}"."${PLATFORM}"-"${PROCESSOR}".pkg -o ~/Downloads/go"${GO_VERSION}"."${PLATFORM}"-"${PROCESSOR}".pkg
        echo -e installing  ~/Downloads/go"${GO_VERSION}"."${PLATFORM}"-"${PROCESSOR}".pkg
        sudo /usr/sbin/installer -pkg ~/Downloads/go"${GO_VERSION}"."${PLATFORM}"-"${PROCESSOR}".pkg -target / -verboseR

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
	go install github.com/golang/lint/golint@latest
        echo "Installing golang language server"
        go install golang.org/x/tools/cmd/gopls@latest
	go install golang.org/x/tools/cmd/cover@latest
	go install golang.org/x/review/git-codereview@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install golang.org/x/tools/cmd/gorename@latest
	go install golang.org/x/tools/cmd/guru@latest
        go install github.com/derekparker/delve/cmd/dlv@latest
        )
}

# Brew Section, introduced this since docker really messed up network, sound, passing through arguments. One day Docker will be made great again
# All brew installs have a check_brew call to ensure this doesnt fail somewhere

check_brew() {
        if command -v brew &>/dev/null; then
            echo "Checking requirements: Brew... ok"
        else
            echo "Installing requirements: Brew..."
            install_brew
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

install_7zip() {
        check_brew
        brew install p7zip
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

install_pulumi() {
        check_brew
        brew install pulumi
}

install_bashcompletion() {
	brew install bash-completion@2
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

install_minikube() {
        echo -e "Installing Minikube"
        curl --silent -L https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64 -o ~/Downloads/minikube-darwin-arm64
        sudo install ~/Downloads/minikube-darwin-arm64 /usr/local/bin/minikube
}

install_kubectl() {
        check_brew
        brew install kubernetes-cli
}

install_kubectx() {
        check_brew
        brew install kubectx
}

setup_kubectl() {
        kubectl completion bash >/usr/local/etc/bash_completion.d/kubectl
        mkdir -p ~/.kube
}

install_postman() {
        check_brew
        brew install --cask postman
}

message_finish() {
        echo "Installation finished."
        echo "Please install xcode manually via the Appstore."
}

# Functions that are to organize functions into categories.

install_shelltools() {
        install_shellcheck
        install_neovim
        install_exa
        set_locate
        set_updatedb
	install_iterm2
	install_fzf
	install_coreutils
	install_chezmoi
        install_bashcompletion
        install_7zip
}

install_kubernetes() {
        install_minikube
        install_kubectl
        install_kubectx
        setup_kubectl
}

install_browsers() {
        install_firefox
        install_chrome
        install_brave
}

install_automation() {
        install_ansible
        install_terraform
        install_pulumi
}

install_devtools() {
        install_neovim
        install_postman
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

setup_requirements(){
        # We source the checks so we can use $PROCESSOR etc.
        #shellcheck disable=SC1090
        source ~/.checks
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
        setup_requirements
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
		install_browsers
        elif [[ $cmd == "golang" ]]; then
		set_golangdirs
		install_golang
	elif [[ $cmd == "ide" ]]; then
		install_vscode
		install_sublime
	elif [[ $cmd == "vim" ]]; then
		install_neovim
		install_pathogen
        elif [[ $cmd == "terraform" ]]; then
                install_terraform
        elif [[ $cmd == "packer" ]]; then
                install_packer
        elif [[ $cmd == "azure" ]]; then
                install_azurecli
        elif [[ $cmd == "kubernetes" ]]; then
                install_kubernetes
	elif [[ $cmd == "shelltools" ]]; then
                install_shelltools
	elif [[ $cmd == "security" ]]; then
		install_keepassyc
	else
		usage
	fi
}

main "$@"