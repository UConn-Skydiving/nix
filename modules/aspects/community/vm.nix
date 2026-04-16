# modules/aspects/community/vm.nix
################################################################################
# Composes VM profiles for GUI and TUI workflows.
################################################################################

{ community, ... }:
{
  community.vm.provides = {
    gui.includes = [
      community.vm
      community.vm-bootable._.gui
      community.xfce-desktop
    ];

    tui.includes = [
      community.vm
      community.vm-bootable._.tui
    ];
  };
}
