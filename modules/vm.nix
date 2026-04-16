# modules/vm.nix
################################################################################
# Enables a local VM runner for fast iteration on the jonathan host config.
# Example usage:
# nix run .#vm
################################################################################

{ inputs, community, ... }:
{
  den.aspects.jonathan.includes = [
    # community.vm._.gui
    community.vm._.tui
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
