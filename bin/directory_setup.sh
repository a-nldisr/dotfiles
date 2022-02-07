#!/bin/bash

jupyter_dir(){
    echo "Creating jupyter directory"
    [[ -d "$HOME/jupyter" ]] || mkdir -p "$HOME/jupyter"
    [[ -d "$HOME/jupyter/notebooks" ]] || mkdir -p "$HOME/jupyter/notebooks"
}

main() {
    jupyter_dir
}

main