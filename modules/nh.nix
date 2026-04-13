# modules/nh.nix
################################################################################
# Exposes per-host and per-home build packages for nh.
#
# nh is the Nix CLI helper tool (for nixos, darwin, and home-manager workflows).
# In this code, den.lib.nh.denPackages generates wrapper commands that call nh
# for each Den host/home.
################################################################################

{ den, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
    };
}
