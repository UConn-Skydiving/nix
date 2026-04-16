# modules/inputs.nix
################################################################################
# Declares shared flake inputs for modules in this repository.
# Inputs can be declared near usage when practical, not just here.
################################################################################

{
  flake-file.inputs = {
    # Global nixpkgs channel used by follows = "nixpkgs".
    # Small advances more often so may require more builds than the equivalent
    # large channel. Small does NOT mean that it contains less packages, just
    # that less may be cached, and therefore may lead to longer build times.
    # We choose small to live on the bleeding-edge. Should build times become
    # prohibitively long, we could start our own cache.
    nixpkgs.url =
      "https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.xz";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
