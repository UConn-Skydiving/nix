# modules/vm.nix
################################################################################
# Enables a local VM runner for fast iteration on the jonathan host config.
# Example usage:
# nix run .#vm
################################################################################

{ inputs, custom, ... }:
{
  den.aspects.jonathan.includes = [
    custom.vm._.gui
    # custom.vm._.tui
  ];

  perSystem =
    { pkgs, ... }:
    {
      packages.vm = pkgs.writeShellApplication {
        name = "vm";
        text =
          let
            host = inputs.self.nixosConfigurations.jonathan.config;
          in
          ''
            ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm "$@"
          '';
      };
    };
}
