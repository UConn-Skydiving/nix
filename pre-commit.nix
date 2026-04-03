{
  inputs,
  self,
  nixpkgs,
  systems,
}: let
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
        deadnix = {
          enable = true;
          settings.exclude = ["./hosts/*/hardware-configuration.nix"];
          settings.edit = true;
        };

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
        mdl.enable = true;
        denofmt.enable = true;

        # Linting for your git commit messages
        gitlint.enable = true;

        # find broken links
        # no internet access, so cannot run pre-commit. Instead should be handled by CI
        # lychee.enable = true;
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
}
