# modules/aspects/jonathan.nix
################################################################################
# Host aspect for jonathan.
# Derived from template host/user examples, but scoped to host-level system
# packages for a non-multi-user setup today.
################################################################################

{
  den.aspects.jonathan = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.hello
          pkgs.vim
        ];
      };
  };
}
