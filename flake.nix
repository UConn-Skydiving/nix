{
  inputs = {
    # The stable/large nixos packages channel. In general, living on the edge
    # is better, but there may be some cases to follow the slow channel as well.
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Use nixpkgs-unstable instead of master so that packages are more likely
    # to be cached already while still being as fresh as possible.
    # See https://discourse.nixos.org/t/differences-between-nix-channels/13998
    #nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Small channels (e.g. nixos-25.11-small, nixos-unstable-small) are identical
    # to large channels, but are updated as soon as Hydra has finished building a
    # defined set of commonly-used packages. Thus, users following these channels
    # will get faster updates but may need to build any packages they use from
    # outside the defined set themselves. These channels are intended to be used
    # for server setups, for example.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    disko,
    systems,
    self,
    ...
  } @ inputs: let
    # Helper for making nixOS system from common modules
    buildSystem = {
      hostname,
      system ? ["aarch64-linux"],
      additionalModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit (self) inputs outputs;
        };

        modules =
          [
            # A common pattern in the past was to use `inherit system`this pattern
            # has been deprecated since 23.11. We use new pattern in module system instead.
            {nixpkgs.hostPlatform = system;}

            # Enforce consistent host name.
            {networking.hostName = hostname;}

            ./hosts/${hostname}
          ]
          ++ additionalModules;
      };

    # git pre-commit-hooks
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    # Run the hooks with `nix fmt`.
    formatter = forEachSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (self.checks.${system}.pre-commit-check) config;
        inherit (config) package configFile;
        script = ''
          ${pkgs.lib.getExe package} run --all-files --config ${configFile}
        '';
      in
        pkgs.writeShellScriptBin "pre-commit-run" script
    );

    # Run the hooks in a sandbox with `nix flake check`.
    # Read-only filesystem and no internet access.
    checks = forEachSystem (system: {
      pre-commit-check = inputs.git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # Nix formatting (opinionated)
          alejandra.enable = true;

          # Nix linting - finds unused code
          deadnix.enable = true;

          # Nix linting - suggestions for better Nix code
          statix = {
            enable = true;
            settings.ignore = ["hosts/*/hardware-configuration.nix"];
          };

          # GitHub Actions validation
          actionlint.enable = true;

          # Security checks
          detect-private-keys.enable = true;
          trufflehog.enable = true;

          # File hygiene (non-opinionated)
          check-added-large-files.enable = true;
          check-merge-conflicts.enable = true;
          check-symlinks.enable = true;
          end-of-file-fixer.enable = true;
          trim-trailing-whitespace.enable = true;
          mixed-line-endings.enable = true;

          # Config file validation
          check-yaml.enable = true;
          check-json.enable = true;
          check-toml.enable = true;

          # Shell script quality
          shellcheck.enable = true;

          # Markdown linting
          markdownlint.enable = true;
          mdformat.enable = true;

          # Linting for your git commit messages
          gitlint.enable = true;
        };
      };
    });

    # Enter a development shell with `nix develop`.
    # The hooks will be installed automatically.
    # Or run pre-commit manually with `nix develop -c pre-commit run --all-files`
    devShells = forEachSystem (system: {
      default = let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
      in
        pkgs.mkShell {
          inherit shellHook;
          buildInputs = enabledPackages;
        };
    });

    nixosConfigurations = {
      jonathan = buildSystem {
        hostname = "jonathan";
        system = "aarch64-linux";
        additionalModules = [disko.nixosModules.disko];
      };
    };
  };
}
