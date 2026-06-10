{
  description = "Dotfiles maintenance shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixfmt-rfc-style;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Editors / Navigation
            neovim
            fzf
            ripgrep

            # Git
            git
            pre-commit
            lazygit

            # Nix tooling
            nixfmt-rfc-style
            nil
            nix-tree

            # Data / Scripting
            jq
            yq
            shellcheck

            # Shell
            direnv
            tmux
          ];

          shellHook = ''
            echo "dotfiles shell ready"
          '';
        };
      }
    );
}
