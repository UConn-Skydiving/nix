# modules/aspects/defaults.nix
################################################################################
# Sets global defaults and shared includes for host/user/home generation.
# Uses explicit aspect paths only (no angle-bracket lookup syntax).
################################################################################

{ config, lib, den, community, ... }:
{
  # den.default applies settings to all hosts, users, and homes. This is the
  # right place for stateVersion and other global policies.
  den.default = {
    nixos.system.stateVersion = "25.11";
    homeManager.home.stateVersion = "25.11";
  };

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Enable host-user cross-providers when user contexts exist.
  # https://den.oeiuwq.com/guides/batteries/#denprovidesmutual-provider
  # Allows hosts and users to contribute configuration to each other through
  # `.provides.`
  den.ctx.user.includes = [ den._.mutual-provider ];

  den.default.includes = [
    # Sets the system hostname as defined in den.hosts.<name>.hostName
    den.provides.hostname
    # Creates OS and home-level user account definitions:
    den.provides.define-user
    (if config ? _module.args.CI then community.ci-no-boot else { })
  ];
}
