# modules/aspects/defaults.nix
################################################################################
# Sets global defaults and shared includes for host/user/home generation.
# Uses explicit aspect paths only (no angle-bracket lookup syntax).
################################################################################

{ config, lib, den, custom, ... }:
{
  den.default = {
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
  };

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Enable host-user cross-providers when user contexts exist.
  den.ctx.user.includes = [ den._.mutual-provider ];

  den.default.includes = [
    den.provides.hostname
    den.provides.define-user
    (if config ? _module.args.CI then custom.ci-no-boot else { })
  ];
}
