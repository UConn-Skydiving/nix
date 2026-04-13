# modules/namespace.nix
################################################################################
# Defines local den namespaces used by this repository.
# - custom: locally authored aspects
# - community: community-sourced aspects
# The true flag exposes it as a flake output (flake.denful.custom).
################################################################################

{ inputs, ... }:
{
  imports = [
    (inputs.den.namespace "custom" true)
    (inputs.den.namespace "community" true)
  ];
}
