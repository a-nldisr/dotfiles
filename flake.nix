{
  description = "Nix flake setup for local LLM setups";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        pyDeps = pkgs: [
          (pkgs.python311.withPackages(ps: with ps; [
            requests
            pytest
          ]))
        ];

        uvxDeps = pkgs: [
          (pkgs.python311.withPackages(ps: with ps; [
            uvicorn
            fastapi
            typer
          ]))
          pkgs.uv
        ];

      in
      {
        devShells.default = pkgs.mkShell {
          packages = builtins.concatLists [
            (pyDeps pkgs)
            (uvxDeps pkgs)
          ];
        };

        devShells.uvx = pkgs.mkShell {
          packages = uvxDeps pkgs;
        };
      }
    );
}