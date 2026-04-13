# modules/aspects/custom/vm-bootable.nix
################################################################################
# Provides bootable installer variants for VM and USB media builds.
################################################################################

let
  installer = variant: {
    nixos =
      { modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/installer/cd-dvd/installation-cd-${variant}.nix")
        ];
      };
  };
in
{
  custom.vm-bootable.provides = {
    tui = installer "minimal";
    gui = installer "graphical-base";
  };
}
