# modules/aspects/custom/autologin.nix
################################################################################
# Context-aware autologin helper for desktop systems.
# Applies only when a user context exists and a display manager is enabled.
################################################################################

{
  custom.autologin =
    { user, ... }:
    {
      nixos =
        { config, lib, ... }:
        lib.mkIf config.services.displayManager.enable {
          services.displayManager.autoLogin.enable = true;
          services.displayManager.autoLogin.user = user.userName;
        };
    };
}
