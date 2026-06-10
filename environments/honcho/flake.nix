{
  description = "honcho – memory infrastructure for stateful agents";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python311;
      in
      {
        devShells.default = pkgs.mkShell {
          name = "honcho";

          packages = [
            python
            pkgs.uv

            pkgs.postgresql_16
            pkgs.libpq

            pkgs.gcc
            pkgs.gnumake
            pkgs.pkg-config

            pkgs.rustc
            pkgs.cargo

            pkgs.cmake
            pkgs.arrow-cpp

            pkgs.openblas

            pkgs.redis

            pkgs.openssl

            pkgs.git
            pkgs.curl
          ];

          env = {
            UV_PYTHON = "${python}/bin/python3.11";

            PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" [
              pkgs.libpq
              pkgs.openssl.dev
              pkgs.openblas
            ];

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
              pkgs.libpq
              pkgs.openssl
              pkgs.openblas
              pkgs.stdenv.cc.cc.lib
            ];
          };

          shellHook = ''
            echo "honcho devShell (Python 3.11 + uv)"
            echo ""
            echo "First time setup:"
            echo "  cp .env.template .env          # fill in DB_CONNECTION_URI + LLM keys"
            echo "  uv sync                        # install all deps into .venv"
            echo "  uv run alembic upgrade head    # run migrations"
            echo ""
            echo "Run the server:"
            echo "  uv run fastapi dev src/main.py"
            echo ""
            echo "Run the deriver (separate terminal):"
            echo "  uv run python -m src.deriver"
            echo ""
          '';
        };
      }
    );
}
