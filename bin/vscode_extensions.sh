#!/bin/bash

# This installs the vscode extensions
# Overview of installed extensions can be found: code --list-extensions

install_ext_markdown() {
    code --install-extension DavidAnson.vscode-markdownlint
}

install_ext_markdown_preview() {
    code --install-extension shd101wyy.markdown-preview-enhanced
}

install_ext_htmlsnip() {
    code --install-extension abusaidm.html-snippets
}

install_ext_bettertoml() {
    code --install-extension bungcip.better-toml
}

install_ext_svgviewer() {
    code --install-extension cssho.vscode-svgviewer
}

install_ext_reactjssnip() {
    code --install-extension dsznajder.es7-react-js-snippets
}

install_ext_terraform_autocomplete() {
    code --install-extension erd0s.terraform-autocomplete
}

install_ext_jsontools() {
    code --install-extension eriklynd.json-tools
}

install_ext_beautify() {
    code --install-extension HookyQR.beautify
}

install_ext_difftool() {
    code --install-extension jinsihou.diff-tool
}

install_ext_ms_go() {
    code --install-extension ms-vscode.Go
}

install_ext_redhat_yaml() {
    code --install-extension redhat.vscode-yaml
}

install_ext_partialdiff() {
    code --install-extension ryu1kn.partial-diff
}

install_ext_jinjahtml() {
    code --install-extension samuelcolvin.jinjahtml
}

install_ext_ansiblecode() {
    code --install-extension vscoss.vscode-ansible
}

install_ext_reactnative() {
    code --install-extension vsmobile.vscode-react-native
}

install_ext_themecobalt() {
    code --install-extension wesbos.theme-cobalt2
}

install_ext_hcl() {
    code --install-extension wholroyd.HCL
}

install_ext_jinja() {
    code --install-extension wholroyd.jinja
}

install_ext_docker() {
    code --install-extension PeterJausovec.vscode-docker
}

install_ext_yaml() {
    code --install-extension adamvoss.yaml
}

install_ext_githistory() {
    code --install-extension donjayamanne.githistory
}

install_ext_gitlens() {
    code --install-extension eamodio.gitlens
}

install_ext_gitprojectmgr() {
    code --install-extension felipecaputo.git-project-manager
}

install_ext_ansible() {
    code --install-extension haaaad.ansible
}

install_ext_autocompletepath() {
    code --install-extension ionutvmi.path-autocomplete
}

install_ext_go() {
    code --install-extension lukehoban.Go
}

install_ext_gotheme() {
    code --install-extension mikegleasonjr.theme-go
}

install_ext_mspython() {
    code --install-extension ms-python.python
}

install_ext_vscodevim() {
    code --install-extension vscodevim.vim
}

install_ext_shellcheck() {
    code --install-extension timonwong.shellcheck
}

install_ext_terraform() {
    code --install-extension mauve.terraform
}

main() {
    install_ext_markdown
    install_ext_docker
    install_ext_yaml
    install_ext_githistory
    install_ext_gitlens
    install_ext_gitprojectmgr
    install_ext_ansible
    install_ext_autocompletepath
    install_ext_go
    install_ext_gotheme
    install_ext_mspython
    install_ext_vscodevim
    install_ext_shellcheck
    install_ext_terraform
    install_ext_htmlsnip
    install_ext_bettertoml
    install_ext_svgviewer
    install_ext_reactjssnip
    install_ext_terraform_autocomplete
    install_ext_jsontools
    install_ext_beautify
    install_ext_difftool
    install_ext_ms_go
    install_ext_redhat_yaml
    install_ext_markdown_preview
    install_ext_jinjahtml
    install_ext_partialdiff
    install_ext_ansiblecode
    install_ext_reactnative
    install_ext_jinja
    install_ext_hcl
    install_ext_themecobalt
}

main