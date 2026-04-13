# modules/dendritic.nix
################################################################################
# Wires flake-file and den dendritic modules into this flake.
# Keeps default input URLs overridable with mkDefault.
# There's no good reason to edit anything here.
################################################################################

{ inputs, lib, ... }:
{
  # We use flake-file to allow imports close to usage instead of in flake.nix.
  # flake.nix is auto generated upon running `nix run .#write-flake`. Must be
  # run when inputs change.
  flake-file.inputs.flake-file.url = lib.mkDefault "github:vic/flake-file";
  # Likewise, we use vic's library for dendritic pattern. This is a matter of 
  # opinion. It's reasonable to use basic dendritic flake-parts also.
  flake-file.inputs.den.url = lib.mkDefault "github:vic/den/latest";

  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];
}
