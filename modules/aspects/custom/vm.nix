# modules/aspects/custom/vm.nix
################################################################################
# Composes VM profiles for GUI and TUI workflows.
################################################################################

{ custom, ... }:
{
  custom.vm.provides = {
    gui.includes = [
      custom.vm
      custom.vm-bootable._.gui
      custom.xfce-desktop
    ];

    tui.includes = [
      custom.vm
      custom.vm-bootable._.tui
    ];
  };
}
