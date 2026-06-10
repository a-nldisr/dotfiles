{
  description = "My hermes wrapper";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      hermes-agent,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      hermes = hermes-agent.packages.${system}.messaging;
    in
    {
      apps.${system} = {
        default = hermes-agent.apps.${system}.default;
        hermes-skills = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "hermes-skills-setup" ''
            export PATH="${hermes}/bin:$PATH"
            exec ${pkgs.bash}/bin/bash ${./scripts/hermes-skills-setup.sh}
          ''}/bin/hermes-skills-setup";
        };
      };
      packages.${system}.default = hermes;
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          hermes
          pkgs.tmux
          pkgs.neovim
        ];
      };
    };
}
