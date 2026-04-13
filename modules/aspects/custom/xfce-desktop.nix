# modules/aspects/custom/xfce-desktop.nix
################################################################################
# Enables a minimal XFCE desktop stack.
################################################################################

{
  custom.xfce-desktop.nixos =
    { lib, ... }:
    {
      services.xserver = {
        enable = true;
        desktopManager = {
          xterm.enable = false;
          xfce.enable = true;
        };
      };

      services.displayManager = {
        defaultSession = lib.mkDefault "xfce";
        enable = true;
      };
    };
}
