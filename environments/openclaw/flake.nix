{
  description = "OpenClaw - self-hosted AI assistant";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [ "openclaw-2026.5.7" ];
      };

      agentsecrets = pkgs.buildGoModule {
        pname = "agentsecrets";
        version = "0-unstable-ebf07d8";

        src = pkgs.fetchFromGitHub {
          owner = "The-17";
          repo = "agentsecrets";
          rev = "ebf07d8b4e879a0eea0f888205f040c800a8a3d9";
          sha256 = "08fkps0x45i16qhj710s2s71gs1ma6x4dlaznk7a0bbzjpzn4lnw";
        };

        vendorHash = "sha256-O9Gp2m6cF//gF+HeW7I16VnWHSZdrkY5GZoClfkPiNw=";

        subPackages = [ "cmd/agentsecrets" ];

        meta = {
          description = "Zero-knowledge secrets management CLI for AI agents";
          homepage = "https://github.com/The-17/agentsecrets";
          license = pkgs.lib.licenses.mit;
          mainProgram = "agentsecrets";
        };
      };

    in
    {
      packages.${system} = {
        openclaw = pkgs.openclaw;
        default = pkgs.openclaw;
        agentsecrets = agentsecrets;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.openclaw
          agentsecrets
        ];

        shellHook = ''
          export OPENCLAW_STATE_DIR="/home/tgif/Git/dotfiles/environments/openclaw"
          export OPENCLAW_CONFIG_PATH="/home/tgif/Git/dotfiles/environments/openclaw/openclaw.json"
        '';
      };
    };
}
