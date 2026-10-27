{
  description = "My hermes wrapper";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    # Honcho memory provider, pinned to the commit the Hermes plugin catalog reviewed.
    honcho-src = {
      url = "github:plastic-labs/honcho/e2d2aba182862deeb846e5cd4a30a41bce0ed82a";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      hermes-agent,
      honcho-src,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib nixfmt;

      hermesBase = hermes-agent.packages.${system}.default;
      # Build plugin packages against the interpreter Hermes itself runs on.
      py = hermesBase.python.pkgs;

      honchoProvider = {
        # Value of memory.provider in config.yaml.
        name = "honcho";
        # Import name for the plugin. Must not be "honcho": that is the SDK's
        # top-level package, and a clash breaks `from honcho import Honcho`.
        module = "hermes_plugin_honcho";
        pluginDir = "${honcho-src}/hermes-plugin-honcho";
        sdkDir = "${honcho-src}/sdks/python";
      };

      projectMeta = dir: (lib.importTOML "${dir}/pyproject.toml").project;
      sdkMeta = projectMeta honchoProvider.sdkDir;
      pluginMeta = projectMeta honchoProvider.pluginDir;

      # httpx and pydantic already live in the sealed Hermes venv. Neither
      # package below propagates them, which keeps the Hermes collision check green.
      honcho-ai = py.buildPythonPackage {
        pname = sdkMeta.name;
        inherit (sdkMeta) version;
        pyproject = true;
        src = honchoProvider.sdkDir;
        build-system = [
          py.setuptools
          py.wheel
        ];
        dontCheckRuntimeDeps = true;
        doCheck = false;
      };

      # Upstream ships the plugin as a flat directory without build config.
      # Package it under its own import name and register the entry point
      # Hermes uses to discover pip-installed memory providers.
      honchoPluginPyproject = (pkgs.formats.toml { }).generate "pyproject.toml" {
        build-system = {
          requires = [ "setuptools" ];
          build-backend = "setuptools.build_meta";
        };
        project = {
          inherit (pluginMeta) name version;
          entry-points."hermes_agent.memory_providers".${honchoProvider.name} = honchoProvider.module;
        };
        tool.setuptools = {
          packages = [ honchoProvider.module ];
          package-data.${honchoProvider.module} = [ "plugin.yaml" ];
        };
      };

      honchoPluginSrc = pkgs.runCommand "${pluginMeta.name}-src" { } ''
        mkdir -p $out/${honchoProvider.module}
        cp ${honchoProvider.pluginDir}/*.py ${honchoProvider.pluginDir}/plugin.yaml $out/${honchoProvider.module}/
        cp ${honchoPluginPyproject} $out/pyproject.toml
      '';

      hermes-plugin-honcho = py.buildPythonPackage {
        pname = pluginMeta.name;
        inherit (pluginMeta) version;
        pyproject = true;
        src = honchoPluginSrc;
        build-system = [ py.setuptools ];
        doCheck = false;
      };

      hermes = hermesBase.override {
        extraPythonPackages = [
          honcho-ai
          hermes-plugin-honcho
        ];
      };

      # `nix fmt` formats only the tracked .nix files of this flake. The flake
      # lives inside the dotfiles repo, so formatting from the git root would
      # touch unrelated files. Explicit file arguments are passed straight through.
      formatter = pkgs.writeShellApplication {
        name = "nix-fmt";
        runtimeInputs = [
          nixfmt
          pkgs.git
          pkgs.findutils
        ];
        text = ''
          if [ "$#" -gt 0 ]; then
            exec nixfmt "$@"
          fi
          cd "''${PRJ_ROOT:-.}"
          git ls-files -z -- '*.nix' | xargs -0 --no-run-if-empty nixfmt
        '';
      };
    in
    {
      apps.${system} = {
        # Points at the overridden package; upstream's app would bypass the plugin.
        default = {
          type = "app";
          program = "${hermes}/bin/hermes";
        };
        hermes-skills = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "hermes-skills-setup" ''
            export PATH="${hermes}/bin:$PATH"
            exec ${pkgs.bash}/bin/bash ${./scripts/hermes-skills-setup.sh}
          ''}/bin/hermes-skills-setup";
        };
      };
      packages.${system} = {
        default = hermes;
        inherit honcho-ai hermes-plugin-honcho;
      };
      formatter.${system} = formatter;
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          hermes
          nixfmt
          pkgs.tmux
          pkgs.neovim
          pkgs.pass
        ];
      };
    };
}
